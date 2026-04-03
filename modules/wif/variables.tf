variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository (owner/repo format)"
  type        = string
}

variable "deployer_sa_email" {
  description = "Deployer service account email to grant WIF access"
  type        = string
}
