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