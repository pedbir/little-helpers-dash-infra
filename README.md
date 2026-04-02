# Little Helpers Dash — Infrastructure

GCP infrastructure for [Little Helpers Dash](https://github.com/pedbir/little-helpers-dash), managed via Terraform.

The application code (including Dockerfile and nginx.conf) lives in the app repo. This repo contains only infrastructure-as-code.

## Architecture

- **Cloud Run** — serves the static frontend (nginx container)
- **Artifact Registry** — stores Docker images
- **Secret Manager** — holds Supabase credentials
- **IAM** — least-privilege service accounts for Cloud Run and CI/CD

## Environments

| Environment | Project ID | Domain |
|---|---|---|
| staging | `little-helpers-staging` | `staging.childroutine.app` |
| production | `little-helpers-production` | `childroutine.app` |

## Setup

### 1. Bootstrap remote state (once per environment)

```bash
chmod +x bootstrap.sh
./bootstrap.sh <project-id> <environment>
```

### 2. Initialize Terraform

```bash
terraform init -backend-config=environments/staging/backend.hcl
```

### 3. Plan and apply

```bash
# Secrets must be passed via env vars or a .tfvars file (never commit secrets)
terraform plan \
  -var-file=environments/staging/terraform.tfvars \
  -var="supabase_url=https://xxx.supabase.co" \
  -var="supabase_anon_key=eyJ..."

terraform apply \
  -var-file=environments/staging/terraform.tfvars \
  -var="supabase_url=https://xxx.supabase.co" \
  -var="supabase_anon_key=eyJ..."
```

## Modules

| Module | Purpose |
|---|---|
| `modules/iam` | Service accounts and IAM bindings |
| `modules/secret-manager` | Supabase secrets in GCP Secret Manager |
| `modules/cloud-run` | Cloud Run service + Artifact Registry |

## Cost Notes

- Cloud Run scales to zero — no cost when idle
- Artifact Registry charges per GB stored
- Secret Manager: first 6 versions free, $0.06/version/month after
