# Artifact Registry for Docker images
resource "google_artifact_registry_repository" "app" {
  project       = var.project_id
  location      = var.region
  repository_id = "little-helpers-${var.environment}"
  format        = "DOCKER"
  description   = "Container images for Little Helpers Dash (${var.environment})"
}

# Cloud Run service
resource "google_cloud_run_v2_service" "app" {
  project  = var.project_id
  name     = "little-helpers-${var.environment}"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.service_account

    scaling {
      min_instance_count = 0
      max_instance_count = var.environment == "production" ? 10 : 2
    }

    containers {
      # Placeholder image — replaced by CI/CD on first deploy
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "256Mi"
        }
        cpu_idle = true
      }

      env {
        name = "VITE_SUPABASE_URL"
        value_source {
          secret_key_ref {
            secret  = var.secret_supabase_url_id
            version = "latest"
          }
        }
      }

      env {
        name = "VITE_SUPABASE_ANON_KEY"
        value_source {
          secret_key_ref {
            secret  = var.secret_supabase_anon_key_id
            version = "latest"
          }
        }
      }

      env {
        name  = "NODE_ENV"
        value = var.environment == "production" ? "production" : "development"
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

# Allow unauthenticated access (public website)
resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  name     = google_cloud_run_v2_service.app.name
  location = var.region
  role     = "roles/run.invoker"
  member   = "allUsers"
}
