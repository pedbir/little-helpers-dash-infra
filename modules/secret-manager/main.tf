# Supabase URL
resource "google_secret_manager_secret" "supabase_url" {
  project   = var.project_id
  secret_id = "supabase-url-${var.environment}"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "supabase_url" {
  secret      = google_secret_manager_secret.supabase_url.id
  secret_data = var.supabase_url
}

# Supabase Anon Key
resource "google_secret_manager_secret" "supabase_anon_key" {
  project   = var.project_id
  secret_id = "supabase-anon-key-${var.environment}"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "supabase_anon_key" {
  secret      = google_secret_manager_secret.supabase_anon_key.id
  secret_data = var.supabase_anon_key
}

# Grant Cloud Run SA access to read secrets
resource "google_secret_manager_secret_iam_member" "cloud_run_reads_supabase_url" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.supabase_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cloud_run_sa}"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_reads_supabase_anon_key" {
  project   = var.project_id
  secret_id = google_secret_manager_secret.supabase_anon_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.cloud_run_sa}"
}
