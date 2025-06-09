# -----------------------------------------------------------------------------
# Project Variables
# This file defines all the configurable input variables for the infrastructure.
# Centralizing them here makes the main.tf file cleaner and allows for easier
# configuration of different environments (e.g., dev, staging, prod).
# -----------------------------------------------------------------------------

variable "gcp_project_id" {
  description = "The GCP Project ID to deploy all resources into."
  type        = string
  default     = "soccer-table-site"
}

variable "gcp_region" {
  description = "The primary GCP region for resources like Cloud Run and Artifact Registry."
  type        = string
  default     = "us-central1"
}

variable "gcp_multi_region" {
  description = "The multi-region for high-availability services like Firestore (e.g., 'nam5' for North America, 'eur3' for Europe)."
  type        = string
  default     = "nam5"
}

variable "cloud_run_service_name" {
  description = "The name of the backend Cloud Run service."
  type        = string
  default     = "soccer-api"
}

variable "artifact_repo_name" {
  description = "The name of the Artifact Registry repository for Docker images."
  type        = string
  default     = "soccer-site-repo"
}

variable "github_owner" {
  description = "The GitHub username or organization that owns the source code repository."
  type        = string
  default     = "lakunma"
}

variable "github_repo_name" {
  description = "The name of the GitHub repository."
  type        = string
  default     = "soccer-table-site"
}

variable "github_app_installation_id" {
  description = "The GitHub App installation ID for Cloud Build integration. You can find this in your GitHub App settings."
  type        = number
  sensitive   = true
}

variable "github_oauth_token" {
  description = "GitHub OAuth token for repository access. Generate this from GitHub Settings > Developer settings > Personal access tokens."
  type        = string
  sensitive   = true
}