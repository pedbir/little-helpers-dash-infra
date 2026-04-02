output "cloud_run_url" {
  description = "Cloud Run service URL"
  value       = module.cloud_run.service_url
}

output "cloud_run_sa_email" {
  description = "Cloud Run service account email"
  value       = module.iam.cloud_run_sa_email
}

output "deployer_sa_email" {
  description = "CI/CD deployer service account email"
  value       = module.iam.deployer_sa_email
}

output "artifact_registry_repo" {
  description = "Artifact Registry repository URL"
  value       = module.cloud_run.artifact_registry_repo
}

output "uptime_check_id" {
  description = "Monitoring uptime check ID"
  value       = module.monitoring.uptime_check_id
}
