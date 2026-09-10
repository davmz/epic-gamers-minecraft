variable "NAME" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "KUBERNETES_VERSION" {
  description = "Kubernetes version for the EKS cluster. Null allows AWS to use its default supported version."
  type        = string
  default     = null
}

variable "PRIVATE_SUBNET_IDS" {
  description = "Private subnet IDs used by the EKS cluster and managed node group"
  type        = list(string)
}

variable "NODE_INSTANCE_TYPES" {
  description = "EC2 instance types used by the EKS managed node group"
  type        = list(string)
}

variable "NODE_CAPACITY_TYPE" {
  description = "Capacity type for the managed node group"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition = contains(
      ["ON_DEMAND", "SPOT"],
      var.NODE_CAPACITY_TYPE
    )

    error_message = "NODE_CAPACITY_TYPE must be either ON_DEMAND or SPOT."
  }
}

variable "NODE_DESIRED_SIZE" {
  description = "Desired number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "NODE_MIN_SIZE" {
  description = "Minimum number of EKS worker nodes"
  type        = number
  default     = 1
}

variable "NODE_MAX_SIZE" {
  description = "Maximum number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "NODE_DISK_SIZE" {
  description = "Root EBS disk size in GiB for EKS worker nodes"
  type        = number
  default     = 30
}

variable "TAGS" {
  description = "Tags applied to EKS resources"
  type        = map(string)
  default     = {}
}