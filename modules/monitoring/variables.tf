variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cloud_run_url" {
  description = "Cloud Run service URL for uptime checks"
  type        = string
}

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
}
