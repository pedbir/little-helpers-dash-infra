variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tfstate_bucket" {
  description = "GCS bucket name for Terraform state"
  type        = string
}
