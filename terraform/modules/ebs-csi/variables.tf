variable "NAME" {
  description = "Name prefix used for EBS CSI resources"
  type        = string
}

variable "CLUSTER_NAME" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "KUBERNETES_VERSION" {
  description = "Kubernetes version of the EKS cluster"
  type        = string
}

variable "TAGS" {
  description = "Tags applied to EBS CSI resources"
  type        = map(string)
  default     = {}
}