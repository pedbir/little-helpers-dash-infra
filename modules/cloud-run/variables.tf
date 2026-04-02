variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "service_account" {
  description = "Service account email for Cloud Run"
  type        = string
}

variable "secret_supabase_url_id" {
  description = "Secret Manager secret ID for Supabase URL"
  type        = string
}

variable "secret_supabase_anon_key_id" {
  description = "Secret Manager secret ID for Supabase Anon Key"
  type        = string
}
