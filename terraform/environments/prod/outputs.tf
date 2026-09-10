output "minecraft_backup_bucket_name" {
  description = "S3 bucket used for Minecraft backups"
  value       = module.minecraft_backups.bucket_name
}

output "minecraft_backup_iam_role_arn" {
  description = "IAM role used by the Minecraft backup workload"
  value       = module.minecraft_backups.iam_role_arn
}