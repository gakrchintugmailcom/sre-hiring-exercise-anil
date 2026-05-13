locals {
  name_prefix = "${var.app_name}-${var.environment}"

  common_tags = {
    Application = var.app_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# S3 bucket for application artefacts
resource "aws_s3_bucket" "artefacts" {
  bucket = "${local.name_prefix}-artefacts"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "artefacts" {
  bucket = aws_s3_bucket.artefacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# NOTE: public access block is missing, fix it as part of the exercise
# resource "aws_s3_bucket_public_access_block" ...

# IAM role for the application workload
resource "aws_iam_role" "app" {
  name = "${local.name_prefix}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy" "app_s3" {
  name = "${local.name_prefix}-s3-policy"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          aws_s3_bucket.artefacts.arn,
          "${aws_s3_bucket.artefacts.arn}/*"
        ]
      }
    ]
  })
}
