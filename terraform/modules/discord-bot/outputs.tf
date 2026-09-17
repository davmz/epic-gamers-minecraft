output "repository_name" {
  description = "Discord bot ECR repository name"
  value       = aws_ecr_repository.this.name
}

output "repository_url" {
  description = "Discord bot ECR repository URL"
  value       = aws_ecr_repository.this.repository_url
}