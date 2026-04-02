output "supabase_url_secret_id" {
  description = "Secret Manager secret ID for Supabase URL"
  value       = google_secret_manager_secret.supabase_url.secret_id
}

output "supabase_anon_key_secret_id" {
  description = "Secret Manager secret ID for Supabase Anon Key"
  value       = google_secret_manager_secret.supabase_anon_key.secret_id
}
