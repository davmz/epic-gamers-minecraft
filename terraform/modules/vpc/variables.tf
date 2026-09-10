variable "NAME" {
  description = "Name prefix for VPC resources"
  type        = string
}

variable "CIDR_BLOCK" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "PUBLIC_SUBNETS" {
  description = "Public subnet configuration"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "PRIVATE_SUBNETS" {
  description = "Private subnet configuration"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "ENABLE_NAT_GATEWAY" {
  description = "Whether to create a NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

variable "TAGS" {
  description = "Common tags applied to resources"
  type        = map(string)
  default     = {}
}