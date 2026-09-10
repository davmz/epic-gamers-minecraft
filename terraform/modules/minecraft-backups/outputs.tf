output "bucket_name" {
  description = "S3 bucket used for Minecraft backups"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the Minecraft backup S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "iam_role_arn" {
  description = "IAM role used by the Minecraft backup pod"
  value       = aws_iam_role.this.arn
}