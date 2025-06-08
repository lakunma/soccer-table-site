# -----------------------------------------------------------------------------
# Main Infrastructure Configuration
# This file defines the core GCP resources for the soccer site project.
# It uses variables defined in variables.tf to make the configuration reusable.
# -----------------------------------------------------------------------------

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Enable the necessary APIs for the project to function.
resource "google_project_service" "apis" {
  project = var.gcp_project_id
  for_each = toset([
    "firestore.googleapis.com", # Firestore Database
    "run.googleapis.com", # Cloud Run for the API
    "identitytoolkit.googleapis.com", # Identity Platform for users
    "artifactregistry.googleapis.com", # To store container images
    "cloudbuild.googleapis.com", # For automated deployments
    "secretmanager.googleapis.com"     # Required by Cloud Build Triggers for GitHub connections.
  ])
  service = each.key
}

# Create the Firestore Database instance in Native mode.
resource "google_firestore_database" "database" {
  project                     = var.gcp_project_id
  name                        = "(default)"
  location_id                 = var.gcp_multi_region
  type                        = "FIRESTORE_NATIVE"
  delete_protection_state = "DELETE_PROTECTION_DISABLED" # Use ENABLED for production
  app_engine_integration_mode = "DISABLED"
}

# Create a repository in Artifact Registry to store our Docker images.
resource "google_artifact_registry_repository" "repository" {
  project       = var.gcp_project_id
  location      = var.gcp_region
  repository_id = var.artifact_repo_name
  description   = "Docker repository for soccer site API"
  format        = "DOCKER"
}


# --- CI/CD Permissions ---
# Grants the Cloud Build service account the necessary permissions to deploy our app.

# First, get a data reference to our project to access its details.
data "google_project" "project" {
  project_id = var.gcp_project_id
}

# Create a local variable for the Cloud Build service account email to avoid repetition.
locals {
  cloud_build_sa_email = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

# 1. Grant Cloud Build permission to push images to our Artifact Registry repository.
resource "google_artifact_registry_repository_iam_member" "build_pusher" {
  project    = google_artifact_registry_repository.repository.project
  location   = google_artifact_registry_repository.repository.location
  repository = google_artifact_registry_repository.repository.name
  role       = "roles/artifactregistry.writer"
  member     = local.cloud_build_sa_email
}


# 2. Grant Cloud Build permission to deploy new revisions to our Cloud Run service.
resource "google_cloud_run_service_iam_member" "build_deployer" {
  project  = google_cloud_run_v2_service.api.project
  location = google_cloud_run_v2_service.api.location
  service = google_cloud_run_v2_service.api.name # <<< CORRECT ARGUMENT NAME, CORRECT VALUE
  role     = "roles/run.admin"
  member   = local.cloud_build_sa_email
}

# 3. Grant Cloud Build permission to act as an IAM Service Account User (required for deployments).
resource "google_project_iam_member" "build_service_account_user" {
  project = var.gcp_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = local.cloud_build_sa_email
}


# --- CI/CD Trigger ---
# This trigger connects our GitHub repository to Cloud Build,
# automating deployment on every push to the main branch.

# In infrastructure/main.tf
#
# ---- FULLY MANAGED GITHUB CONNECTION AND TRIGGER ----
# This is the definitive, robust solution.

# 1. We now define the GitHub connection itself in Terraform.
#    This removes the manual step and solves the race condition.
resource "google_cloudbuildv2_connection" "primary_github_connection" {
  project  = var.gcp_project_id
  location = var.gcp_region
  name     = "github-lakunma"

  github_config {}
  # This empty block is the correct syntax.
}


# # 2. The trigger now explicitly depends on the connection resource above.
# resource "google_cloudbuild_trigger" "backend_deploy" {
#   project     = var.gcp_project_id
#   name        = "deploy-backend-on-main-push"
#   description = "Deploys the backend API to Cloud Run when code is pushed to the main branch"
#   location    = var.gcp_region
#
#   repository_event_config {
#     # CRITICAL CHANGE: We now reference the connection and repository using outputs
#     # from the connection resource itself, creating an explicit dependency.
#     repository = "projects/${var.gcp_project_id}/locations/${var.gcp_region}/connections/${google_cloudbuildv2_connection.primary_github_connection.name}/repositories/${var.github_full_repo_name}"
#
#     push {
#       branch = "^main$"
#     }
#   }
#
#   filename = "cloudbuild.yaml"
#
#   substitutions = {
#     _SERVICE_NAME = var.cloud_run_service_name
#     _REGION       = var.gcp_region
#     _REPO_NAME    = var.artifact_repo_name
#   }
#
#   # The explicit dependency on the connection resource is now key.
#   depends_on = [
#     google_cloudbuildv2_connection.primary_github_connection,
#     google_project_iam_member.build_service_account_user,
#     google_cloud_run_service_iam_member.build_deployer,
#     google_artifact_registry_repository_iam_member.build_pusher
#   ]
# }

# --- Cloud Run Service Definition ---
# This block defines the Cloud Run service itself. We create it with a
# placeholder image. The CI/CD pipeline will then take over and deploy
# our actual application image to this service. This solves the "chicken-and-egg"
# problem of applying IAM permissions before the service exists.
resource "google_cloud_run_v2_service" "api" {
  project = var.gcp_project_id
  name    = var.cloud_run_service_name
  location = var.gcp_region

  # This allows unauthenticated (public) access, same as the gcloud flag.
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      # Use a standard public placeholder image for the initial creation.
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}