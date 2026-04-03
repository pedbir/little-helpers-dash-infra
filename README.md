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

## Setup

### 1. Bootstrap remote state (once per environment)

```bash
chmod +x bootstrap.sh
./bootstrap.sh little-helpers-staging staging
./bootstrap.sh little-helpers-production production
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
  -var="supabase_url=https://yikuadwqsxcfqypxvrxa.supabase.co" \
  -var="supabase_anon_key=<from-supabase-dashboard>"

terraform apply \
  -var-file=environments/staging/terraform.tfvars \
  -var="supabase_url=https://yikuadwqsxcfqypxvrxa.supabase.co" \
  -var="supabase_anon_key=<from-supabase-dashboard>"
```

### 4. Configure GitHub repo variables (after terraform apply)

After applying, Terraform outputs the values needed for GitHub Actions:

```bash
terraform output github_actions_setup
```

Set these as GitHub repository variables:

| Variable | Source |
|---|---|
| `WIF_PROVIDER` | `terraform output wif_provider_name` |
| `DEPLOYER_SA` | `terraform output deployer_sa_email` |

## CI/CD

- **`deploy.yml`** — Deploys to Cloud Run on push to `main` or manual dispatch. Uses WIF for keyless auth.
- **`terraform-plan.yml`** — Runs `terraform plan` on PRs that touch `.tf` files and posts the plan as a PR comment.

## Modules

| Module | Purpose |
|---|---|
| `modules/iam` | Service accounts and IAM bindings |
| `modules/secret-manager` | Supabase secrets in GCP Secret Manager |
| `modules/cloud-run` | Cloud Run service + Artifact Registry |
| `modules/wif` | Workload Identity Federation for GitHub Actions |
| `modules/monitoring` | Uptime checks and alert policies |

## Cost Notes

- Cloud Run scales to zero — no cost when idle
- Artifact Registry charges per GB stored
- Secret Manager: first 6 versions free, $0.06/version/month after
- Monitoring: uptime checks free up to 100/month, alerting free
