# Remote state in GCS
# The bucket must be created before running terraform init.
# See terraform/README.md for bootstrap instructions.
terraform {
  backend "gcs" {
    # Bucket name is set per-environment via -backend-config
    # e.g. terraform init -backend-config="bucket=little-helpers-tfstate-staging"
    prefix = "terraform/state"
  }
}
