output "repository_name" {
  description = "Discord bot ECR repository name"
  value       = aws_ecr_repository.this.name
}

output "repository_url" {
  description = "Discord bot ECR repository URL"
  value       = aws_ecr_repository.this.repository_url
}

output "fargate_profile_name" {
  description = "Discord bot EKS Fargate profile name"
  value       = aws_eks_fargate_profile.discord_bot.fargate_profile_name
}

output "fargate_pod_execution_role_arn" {
  description = "Discord bot Fargate Pod execution IAM role ARN"
  value       = aws_iam_role.fargate_pod_execution.arn
}

output "coredns_fargate_profile_name" {
  description = "CoreDNS EKS Fargate profile name"
  value       = aws_eks_fargate_profile.coredns.fargate_profile_name
}