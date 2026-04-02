#!/usr/bin/env bash
# Bootstrap script: creates the GCS bucket for Terraform remote state.
# Run once per environment before `terraform init`.
#
# Usage: ./bootstrap.sh <project-id> <environment>
# Example: ./bootstrap.sh little-helpers-staging staging

set -euo pipefail

PROJECT_ID="${1:?Usage: ./bootstrap.sh <project-id> <environment>}"
ENVIRONMENT="${2:?Usage: ./bootstrap.sh <project-id> <environment>}"
BUCKET_NAME="little-helpers-tfstate-${ENVIRONMENT}"
REGION="europe-north1"

echo "Creating GCS bucket gs://${BUCKET_NAME} in project ${PROJECT_ID}..."

gcloud storage buckets create "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --uniform-bucket-level-access \
  --public-access-prevention

# Enable versioning for state recovery
gcloud storage buckets update "gs://${BUCKET_NAME}" --versioning

echo "Bucket gs://${BUCKET_NAME} created with versioning enabled."
echo ""
echo "Next steps:"
echo "  cd terraform"
echo "  terraform init -backend-config=environments/${ENVIRONMENT}/backend.hcl"
echo "  terraform plan -var-file=environments/${ENVIRONMENT}/terraform.tfvars"
