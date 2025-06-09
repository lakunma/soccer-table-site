# -----------------------------------------------------------------------------
# Outputs
# This file defines the output values that will be displayed after terraform apply.
# These are useful for getting important information about the created resources.
# -----------------------------------------------------------------------------

output "cloud_run_service_url" {
  description = "The URL of the deployed Cloud Run service."
  value       = google_cloud_run_v2_service.api.uri
}

output "artifact_registry_repository" {
  description = "The full name of the Artifact Registry repository for Docker images."
  value       = "${google_artifact_registry_repository.repository.location}-docker.pkg.dev/${google_artifact_registry_repository.repository.project}/${google_artifact_registry_repository.repository.repository_id}"
}

output "github_connection_name" {
  description = "The name of the GitHub connection created for Cloud Build."
  value       = google_cloudbuildv2_connection.github_connection.name
}

output "build_trigger_name" {
  description = "The name of the Cloud Build trigger."
  value       = google_cloudbuild_trigger.backend_deploy.name
}

output "firestore_database_name" {
  description = "The name of the Firestore database."
  value       = google_firestore_database.database.name
}

# Note: The installation_uri output has been removed as it's no longer available
# in Google Provider version 6+. GitHub connection authorization must be done
# manually through the GCP Console.