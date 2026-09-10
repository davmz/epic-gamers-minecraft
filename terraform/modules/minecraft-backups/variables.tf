variable "NAME" {
  description = "Name used for Minecraft backup resources"
  type        = string
}

variable "CLUSTER_NAME" {
  description = "EKS cluster name"
  type        = string
}

variable "NAMESPACE" {
  description = "Kubernetes namespace used by the backup workload"
  type        = string
}

variable "SERVICE_ACCOUNT_NAME" {
  description = "Kubernetes service account used by the backup workload"
  type        = string
}

variable "RETENTION_DAYS" {
  description = "Number of days Minecraft backups are retained in S3"
  type        = number
}

variable "TAGS" {
  description = "Tags applied to supported AWS resources"
  type        = map(string)
}