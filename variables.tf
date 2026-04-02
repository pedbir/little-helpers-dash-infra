variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "europe-north1"
}

variable "environment" {
  description = "Environment name (staging or production)"
  type        = string
  validation {
    condition     = contains(["staging", "production"], var.environment)
    error_message = "Environment must be 'staging' or 'production'."
  }
}

variable "domain" {
  description = "Custom domain for the app"
  type        = string
  default     = "childroutine.app"
}

variable "supabase_url" {
  description = "Supabase project URL (stored in Secret Manager)"
  type        = string
  sensitive   = true
}

variable "supabase_anon_key" {
  description = "Supabase anonymous/public key (stored in Secret Manager)"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format for WIF"
  type        = string
  default     = "pedbir/little-helpers-dash-infra"
}

variable "alert_email" {
  description = "Email address for monitoring alert notifications"
  type        = string
  default     = "alerts@childroutine.app"
}
