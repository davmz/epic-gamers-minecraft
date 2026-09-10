output "ebs_csi_role_arn" {
  description = "IAM role ARN used by the EBS CSI driver"
  value       = aws_iam_role.ebs_csi.arn
}

output "ebs_csi_addon_version" {
  description = "Installed EBS CSI driver add-on version"
  value       = aws_eks_addon.ebs_csi.addon_version
}

output "pod_identity_agent_version" {
  description = "Installed EKS Pod Identity Agent add-on version"
  value       = aws_eks_addon.pod_identity_agent.addon_version
}