terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

provider "google" {
  project = "soccer-table-site"
  region  = "us-central1"
}

# Enable the APIs for the project
resource "google_project_service" "apis" {
  for_each = toset([
    "firestore.googleapis.com", # Firestore Database
    "run.googleapis.com", # Cloud Run for the API
    "identitytoolkit.googleapis.com", # Identity Platform for users
    "artifactregistry.googleapis.com", # To store container images
    "cloudbuild.googleapis.com"        # For automated deployments later
  ])
  service = each.key
}