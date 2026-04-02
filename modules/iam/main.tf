# Cloud Run service account - runs the frontend container
resource "google_service_account" "cloud_run" {
  project      = var.project_id
  account_id   = "cloud-run-${var.environment}"
  display_name = "Cloud Run Service Account (${var.environment})"
  description  = "Least-privilege SA for Cloud Run frontend service"
}

# CI/CD deployer service account - used by GitHub Actions
resource "google_service_account" "deployer" {
  project      = var.project_id
  account_id   = "deployer-${var.environment}"
  display_name = "CI/CD Deployer (${var.environment})"
  description  = "SA for automated deployments via GitHub Actions"
}

# Cloud Run SA: minimal permissions (read secrets, write logs)
resource "google_project_iam_member" "cloud_run_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "cloud_run_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Deployer SA: deploy to Cloud Run, push to Artifact Registry
resource "google_project_iam_member" "deployer_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

# Deployer needs to act as the Cloud Run SA when deploying
resource "google_service_account_iam_member" "deployer_acts_as_cloud_run" {
  service_account_id = google_service_account.cloud_run.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.deployer.email}"
}
