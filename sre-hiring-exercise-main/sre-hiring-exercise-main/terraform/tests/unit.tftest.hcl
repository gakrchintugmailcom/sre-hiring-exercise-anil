# Unit tests for the OzLTD Terraform module.
# Uses mock_provider "aws" so no credentials or real infrastructure are needed.
#
# Run with:
#   cd terraform
#   terraform init -backend=false
#   terraform test

mock_provider "aws" {}

variables {
  app_name    = "ozltd-api"
  environment = "dev"
}

# ── Test 1: S3 bucket name follows the naming convention ──────────────────────

run "bucket_name_follows_convention" {
  command = plan

  assert {
    condition     = aws_s3_bucket.artefacts.bucket == "ozltd-api-dev-artefacts"
    error_message = "S3 bucket name should follow the pattern <app_name>-<environment>-artefacts"
  }
}

# ── Test 2: IAM role name follows the naming convention ───────────────────────

run "iam_role_name_follows_convention" {
  command = plan

  assert {
    condition     = aws_iam_role.app.name == "ozltd-api-dev-role"
    error_message = "IAM role name should follow the pattern <app_name>-<environment>-role"
  }
}

# ── Test 3: S3 versioning is enabled ─────────────────────────────────────────

run "s3_versioning_is_enabled" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.artefacts.versioning_configuration[0].status == "Enabled"
    error_message = "S3 bucket versioning should be set to Enabled"
  }
}

# ── Test 4: Common tags are applied to the S3 bucket ─────────────────────────

run "common_tags_are_applied" {
  command = plan

  assert {
    condition     = aws_s3_bucket.artefacts.tags["Application"] == "ozltd-api"
    error_message = "Application tag is missing or has the wrong value"
  }

  assert {
    condition     = aws_s3_bucket.artefacts.tags["Environment"] == "dev"
    error_message = "Environment tag is missing or has the wrong value"
  }

  assert {
    condition     = aws_s3_bucket.artefacts.tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag should be set to 'terraform'"
  }
}

# ── Test 5: Naming logic works for a different environment ────────────────────

run "bucket_name_reflects_environment" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition     = aws_s3_bucket.artefacts.bucket == "ozltd-api-prod-artefacts"
    error_message = "S3 bucket name should reflect the environment variable"
  }
}
