# LNRS: GitHub Actions CI/CD Take-Home Exercise

## What is this

You've got a small Python service and a Terraform module. Neither has a CI/CD pipeline. Your job is to build one.

Expect it to take around 3 hours.

## The scenario

You've just joined the platform team at OzLTD. A junior dev shipped a health-check API and some Terraform, but nobody ever set up a pipeline. That's yours to sort out now.

## What's in the repo

```
.
├── README.md
├── app/
│   ├── app.py
│   ├── requirements.txt
│   ├── requirements-dev.txt
│   ├── tests/
│   │   └── test_app.py
│   └── Dockerfile
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── tests/
│       └── unit.tftest.hcl   ← pre-written unit tests, must pass in CI
└── .github/
    └── workflows/
        └── ci.yml            ← this is where you'll work
```

## What to do

### 1. Fork & set up

Fork the repo to your own GitHub account and keep it public. We'll look at it directly. All your pipeline work goes in `.github/workflows/`.

### 2. CI pipeline for the app

Fill in `ci.yml` so it runs on every push to any branch and every PR targeting `main`.

| Step | What's needed |
|------|-------------|
| Lint | Run `flake8` against `app/` |
| Unit Tests | Run `pytest`, save results as a workflow artifact |
| Docker Build | Build the image from `app/Dockerfile` |
| Docker Scan | Scan for HIGH/CRITICAL vulns using [Trivy](https://github.com/aquasecurity/trivy-action), report only, don't fail the build |
| Docker Push | On push to `main` only, push to GHCR tagged with the short commit SHA |

Hard rules:
- Jobs run in order using `needs:`
- Secrets go in `${{ secrets.* }}`, never hardcoded
- Lint and test run in parallel

### 3. Terraform validation

Add a job (or a separate workflow) to validate the Terraform. Run it on every push.

| Step | What's needed |
|------|-------------|
| Format check | `terraform fmt -check -recursive` |
| Init | `terraform init -backend=false` |
| Validate | `terraform validate` |
| Unit tests | `terraform test`, runs `terraform/tests/unit.tftest.hcl`, no AWS credentials needed. This must pass. Do not use `continue-on-error`. |
| Lint | `tflint --init && tflint --recursive` |
| Security scan | Run [checkov](https://github.com/bridgecrewio/checkov) or Trivy (IaC mode), upload SARIF results |

Use path filters so it only runs when something under `terraform/` actually changed.

### 4. Before you submit

Tick these off:

- [ ] Every job has a `timeout-minutes`
- [ ] Every step has a `name:`
- [ ] Env vars are defined at workflow or job level, not scattered everywhere
- [ ] At least one job uses a matrix (e.g. test against Python 3.12 and 3.13)
- [ ] The Docker push is gated, doesn't run on PRs from forks

### 5. Bonus

None of this is required, but if you did any of it we'll want to talk about it:

- Reusable workflow: pull the Docker steps out into `.github/workflows/docker-build.yml` and call it from `ci.yml`
- Dependabot: set up `dependabot.yml` to keep Actions versions current
- Release workflow: trigger on `v*` tags, push a release image and create a GitHub Release with auto-generated notes
- OIDC auth: ditch the long-lived credentials and use GitHub's OIDC provider instead
- Failure notifications: ping a Slack or Teams webhook when a push to `main` fails

## What we're looking at

| Area | What we care about |
|------|-----------------|
| Does it work | Workflows run without errors |
| Pipeline design | Jobs ordered sensibly, parallel where it makes sense, no pointless steps |
| Security | Secrets handled correctly, no hardcoded values, least-privilege thinking |
| Readability | Clear names, consistent formatting |
| Terraform | Clean, validated, passes security checks |
| Judgement | Caching, artifact retention, timeouts. Did you think about them? |

## Submitting

Send us the repo URL before we meet and make sure it's public. We'll go through it together in the interview so be ready to walk through your decisions.

If something tripped you up, leave a note in `NOTES.md`. Knowing how you think through a problem matters more to us than a perfect result.

## Running it locally

```bash
# Run the app
cd app
pip install -r requirements.txt
python app.py

# Run tests
pip install -r requirements-dev.txt
pytest tests/ -v

# Validate Terraform
cd terraform
terraform init -backend=false
terraform validate

# Run Terraform unit tests (no AWS credentials needed)
terraform test

# Build the Docker image
docker build -t ozltd-api:local app/
```

## Questions

Email us before you start if something's genuinely unclear. We're not after perfection, we're after good judgement.
