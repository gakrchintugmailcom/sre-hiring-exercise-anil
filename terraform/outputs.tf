output "app_role_arn" {
  description = "ARN of the application IAM role"
  value       = aws_iam_role.app.arn
}

output "artefact_bucket_name" {
  description = "Name of the S3 artefact bucket"
  value       = aws_s3_bucket.artefacts.bucket
}
