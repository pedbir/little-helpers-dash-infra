# Little Helpers Dash — Infrastructure

GCP infrastructure for [Little Helpers Dash](https://github.com/pedbir/little-helpers-dash), managed via Terraform.

The application code (including Dockerfile and nginx.conf) lives in the app repo. This repo contains only infrastructure-as-code.

## Architecture

- **Cloud Run** — serves the static frontend (nginx container)
- **Artifact Registry** — stores Docker images
- **Secret Manager** — holds Supabase credentials
- **IAM** — least-privilege service accounts for Cloud Run and CI/CD
- **WIF** — Workload Identity Federation for keyless GitHub Actions auth
- **Monitoring** — uptime checks, latency alerts, 5xx error rate alerts

## Environments

| Environment | Project ID | Domain | Supabase Region |
|---|---|---|---|
| staging | `little-helpers-staging` | `staging.childroutine.app` | Central EU (Frankfurt) |
| production | `little-helpers-production` | `childroutine.app` | Central EU (Frankfurt) |

Supabase project: `little-helpers` (ref: `yikuadwqsxcfqypxvrxa`)

## Making Changes

Infrastructure is already bootstrapped and applied for both environments. To make changes:

### 1. Create a branch and modify Terraform files

The `terraform-plan.yml` workflow will automatically run `terraform plan` on your PR and post the results as a comment.

### 2. Apply changes

```bash
# Initialize with the target environment backend
terraform init -backend-config=environments/staging/backend.hcl

# Plan and review
terraform plan -var-file=environments/staging/terraform.tfvars \
  -var="supabase_url=$SUPABASE_URL" \
  -var="supabase_anon_key=$SUPABASE_ANON_KEY"

# Apply
terraform apply -var-file=environments/staging/terraform.tfvars \
  -var="supabase_url=$SUPABASE_URL" \
  -var="supabase_anon_key=$SUPABASE_ANON_KEY"
```

Repeat with `environments/production/` for production changes.

## CI/CD

- **`terraform-plan.yml`** — Runs `terraform plan` on PRs that touch `.tf` files and posts the plan as a PR comment.
- **App deploys** — The Cloud Run deploy workflow lives in the [app repo](https://github.com/pedbir/little-helpers-dash).

### GitHub Repository Variables

These are already configured:

| Variable | Description |
|---|---|
| `WIF_PROVIDER` | Workload Identity Federation provider resource name |
| `DEPLOYER_SA` | CI/CD deployer service account email |

To verify or update: `terraform output github_actions_setup`

## Modules

| Module | Purpose |
|---|---|
| `modules/iam` | Service accounts and IAM bindings |
| `modules/secret-manager` | Supabase secrets in GCP Secret Manager |
| `modules/cloud-run` | Cloud Run service + Artifact Registry |
| `modules/wif` | Workload Identity Federation for GitHub Actions |
| `modules/monitoring` | Uptime checks and alert policies |

## Initial Setup Reference

These steps were already completed. Kept here for reference only.

<details>
<summary>Bootstrap (done)</summary>

```bash
# Create GCS state buckets (once per environment)
./bootstrap.sh little-helpers-staging staging
./bootstrap.sh little-helpers-production production
```
</details>

## Cost Notes

- Cloud Run scales to zero — no cost when idle
- Artifact Registry charges per GB stored
- Secret Manager: first 6 versions free, $0.06/version/month after
- Monitoring: uptime checks free up to 100/month, alerting free
