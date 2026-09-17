output "minecraft_backup_bucket_name" {
  description = "S3 bucket used for Minecraft backups"
  value       = module.minecraft_backups.bucket_name
}

output "minecraft_backup_iam_role_arn" {
  description = "IAM role used by the Minecraft backup workload"
  value       = module.minecraft_backups.iam_role_arn
}

output "discord_bot_ecr_repository_name" {
  description = "Discord bot ECR repository name"
  value       = module.discord_bot.repository_name
}

output "discord_bot_ecr_repository_url" {
  description = "Discord bot ECR repository URL"
  value       = module.discord_bot.repository_url
}

output "discord_bot_fargate_profile_name" {
  description = "Discord bot EKS Fargate profile name"
  value       = module.discord_bot.fargate_profile_name
}

output "discord_bot_fargate_pod_execution_role_arn" {
  description = "Discord bot Fargate Pod execution IAM role ARN"
  value       = module.discord_bot.fargate_pod_execution_role_arn
}

output "coredns_fargate_profile_name" {
  description = "CoreDNS EKS Fargate profile name"
  value       = module.discord_bot.coredns_fargate_profile_name
}