module "vpc" {
  source = "../../modules/vpc"

  NAME       = "egm-prod"
  CIDR_BLOCK = "10.0.0.0/16"

  PUBLIC_SUBNETS = {
    us-east-1a = {
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    }

    us-east-1b = {
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  }

  PRIVATE_SUBNETS = {
    us-east-1a = {
      cidr = "10.0.11.0/24"
      az   = "us-east-1a"
    }

    us-east-1b = {
      cidr = "10.0.12.0/24"
      az   = "us-east-1b"
    }
  }

  ENABLE_NAT_GATEWAY = true

  TAGS = {
    project = "epic-gamers-minecraft"
  }
}