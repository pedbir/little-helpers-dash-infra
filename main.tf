# Enable required GCP APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
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

  project_id     = var.project_id
  environment    = var.environment
  tfstate_bucket = var.tfstate_bucket

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

# Workload Identity Federation - GitHub Actions auth
module "wif" {
  source = "./modules/wif"

  project_id        = var.project_id
  github_repo       = var.github_repo
  deployer_sa_email = module.iam.deployer_sa_email

  depends_on = [google_project_service.apis]
}

# Monitoring - Uptime checks and alerting
module "monitoring" {
  source = "./modules/monitoring"

  project_id    = var.project_id
  environment   = var.environment
  cloud_run_url = module.cloud_run.service_url
  alert_email   = var.alert_email

  depends_on = [module.cloud_run]
}
