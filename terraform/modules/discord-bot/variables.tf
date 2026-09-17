variable "NAME" {
  description = "Name used for Discord bot AWS resources"
  type        = string
}

variable "EKS_CLUSTER_NAME" {
  description = "EKS cluster name"
  type        = string
}

variable "PRIVATE_SUBNET_IDS" {
  description = "Private subnet IDs used by the Discord bot Fargate profile"
  type        = list(string)
}

variable "TAGS" {
  description = "Tags applied to supported AWS resources"
  type        = map(string)
}