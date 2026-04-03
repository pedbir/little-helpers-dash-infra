output "provider_name" {
  description = "Full WIF provider resource name (use as WIF_PROVIDER in GitHub vars)"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "pool_name" {
  description = "WIF pool resource name"
  value       = google_iam_workload_identity_pool.github.name
}
