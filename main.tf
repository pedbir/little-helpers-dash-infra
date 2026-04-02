# Enable required GCP APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
  ])

  project = var.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

# IAM - Service accounts and permissions
module "iam" {
  source = "./modules/iam"

  project_id  = var.project_id
  environment = var.environment

  depends_on = [google_project_service.apis]
}

# Secret Manager - App secrets
module "secrets" {
  source = "./modules/secret-manager"

  project_id        = var.project_id
  environment       = var.environment
  supabase_url      = var.supabase_url
  supabase_anon_key = var.supabase_anon_key
  cloud_run_sa      = module.iam.cloud_run_sa_email

  depends_on = [google_project_service.apis]
}

# Cloud Run - Frontend hosting
module "cloud_run" {
  source = "./modules/cloud-run"

  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  service_account = module.iam.cloud_run_sa_email
  secret_supabase_url_id      = module.secrets.supabase_url_secret_id
  secret_supabase_anon_key_id = module.secrets.supabase_anon_key_secret_id

  depends_on = [google_project_service.apis]
}
