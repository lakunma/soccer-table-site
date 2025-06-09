# -----------------------------------------------------------------------------
# Main Infrastructure Configuration
# -----------------------------------------------------------------------------

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.38"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# --- Core GCP Setup ---

# Enable necessary APIs
resource "google_project_service" "apis" {
  project = var.gcp_project_id
  for_each = toset([
    "firestore.googleapis.com",
    "run.googleapis.com",
    "identitytoolkit.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "secretmanager.googleapis.com"
  ])
  service                    = each.key
  disable_dependent_services = true
}

# Create Firestore Database
resource "google_firestore_database" "database" {
  project                     = var.gcp_project_id
  name                        = "(default)"
  location_id                 = var.gcp_multi_region
  type                        = "FIRESTORE_NATIVE"
  delete_protection_state     = "DELETE_PROTECTION_DISABLED"
  app_engine_integration_mode = "DISABLED"
  depends_on = [
    google_project_service.apis
  ]
}

# Create Artifact Registry for Docker images
resource "google_artifact_registry_repository" "repository" {
  project       = var.gcp_project_id
  location      = var.gcp_region
  repository_id = var.artifact_repo_name
  description   = "Docker repository for soccer site API"
  format        = "DOCKER"
  depends_on = [
    google_project_service.apis
  ]
}

# --- Cloud Run Service Definition ---
resource "google_cloud_run_v2_service" "api" {
  project  = var.gcp_project_id
  name     = var.cloud_run_service_name
  location = var.gcp_region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
  depends_on = [
    google_project_service.apis
  ]
}

# --- Data Sources ---

data "google_project" "project" {
  project_id = var.gcp_project_id
}

# --- Local Variables ---

locals {
  # Cloud Build v1 service account (for builds and deployments)
  cloud_build_v1_sa_email = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
  # Cloud Build v2 service account (for GitHub connections)
  cloud_build_v2_sa_email = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}

# --- Secret Management for GitHub Integration ---

resource "google_secret_manager_secret" "github_token" {
  project   = var.gcp_project_id
  secret_id = "github-oauth-token"

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "github_token" {
  secret         = google_secret_manager_secret.github_token.id
  secret_data_wo = var.github_oauth_token
}

# --- CI/CD Permissions ---

# Grant Cloud Build v1 permission to push to Artifact Registry
resource "google_artifact_registry_repository_iam_member" "build_v1_artifact_writer" {
  project    = google_artifact_registry_repository.repository.project
  location   = google_artifact_registry_repository.repository.location
  repository = google_artifact_registry_repository.repository.name
  role       = "roles/artifactregistry.writer"
  member     = local.cloud_build_v1_sa_email
}

# Grant Cloud Build v1 permission to deploy to Cloud Run
resource "google_cloud_run_service_iam_member" "build_v1_run_deployer" {
  project  = google_cloud_run_v2_service.api.project
  location = google_cloud_run_v2_service.api.location
  service  = google_cloud_run_v2_service.api.name
  role     = "roles/run.admin"
  member   = local.cloud_build_v1_sa_email
}

# Grant Cloud Build v1 permission to act as Service Account User
resource "google_project_iam_member" "build_v1_service_account_user" {
  project = var.gcp_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = local.cloud_build_v1_sa_email
}

# Grant Cloud Build v2 permission to access GitHub token secret
resource "google_secret_manager_secret_iam_member" "build_v2_secret_accessor" {
  project   = var.gcp_project_id
  secret_id = google_secret_manager_secret.github_token.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = local.cloud_build_v2_sa_email
}

# --- CI/CD GitHub Integration and Trigger ---

# Create the GitHub connection using the working configuration
resource "google_cloudbuildv2_connection" "github_connection" {
  project  = var.gcp_project_id
  location = var.gcp_region
  name     = "github-connection-${var.github_owner}"

  github_config {
    app_installation_id = var.github_app_installation_id
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github_token.id
    }
  }

  depends_on = [
    google_project_service.apis,
    google_secret_manager_secret_iam_member.build_v2_secret_accessor
  ]
}

# Link the GitHub repository to the connection
resource "google_cloudbuildv2_repository" "github_repo_link" {
  project           = var.gcp_project_id
  location          = google_cloudbuildv2_connection.github_connection.location
  name              = "${var.github_owner}-${var.github_repo_name}"
  parent_connection = google_cloudbuildv2_connection.github_connection.id
  remote_uri        = "https://github.com/${var.github_owner}/${var.github_repo_name}.git"
}

# Create the build trigger - simplified version
resource "google_cloudbuild_trigger" "backend_deploy" {
  project  = var.gcp_project_id
  name     = "deploy-backend-on-main-push"
  location = var.gcp_region

  repository_event_config {
    repository = google_cloudbuildv2_repository.github_repo_link.id
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"

  substitutions = {
    _SERVICE_NAME = var.cloud_run_service_name
    _REGION       = var.gcp_region
    _REPO_NAME    = var.artifact_repo_name
  }
}