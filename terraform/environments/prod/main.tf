# ---------------------------------------------------------
# VPC
# ---------------------------------------------------------

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

# ---------------------------------------------------------
# EKS
# ---------------------------------------------------------

module "eks" {
  source = "../../modules/eks"

  NAME = "egm-prod"

  # EKS control plane keeps both AZs
  CLUSTER_SUBNET_IDS = module.vpc.private_subnet_ids

  # Minecraft worker node is pinned to the AZ containing the EBS volume
  NODE_SUBNET_IDS = [
    module.vpc.private_subnet_ids_by_az["us-east-1a"]
  ]

  NODE_INSTANCE_TYPES = [
    "m7i-flex.xlarge"
  ]

  NODE_CAPACITY_TYPE = "ON_DEMAND"

  NODE_DESIRED_SIZE = 1
  NODE_MIN_SIZE     = 1
  NODE_MAX_SIZE     = 2

  NODE_DISK_SIZE = 30

  TAGS = {
    project = "epic-gamers-minecraft"
  }
}

# ---------------------------------------------------------
# EBS CSI
# ---------------------------------------------------------

module "ebs_csi" {
  source = "../../modules/ebs-csi"

  NAME               = "egm-prod"
  CLUSTER_NAME       = module.eks.cluster_name
  KUBERNETES_VERSION = module.eks.cluster_version

  TAGS = {
    project = "epic-gamers-minecraft"
  }
}

# ---------------------------------------------------------
# MINECRAFT BACKUPS
# ---------------------------------------------------------

module "minecraft_backups" {
  source = "../../modules/minecraft-backups"

  NAME                 = "egm-prod"
  CLUSTER_NAME         = module.eks.cluster_name
  NAMESPACE            = "minecraft"
  SERVICE_ACCOUNT_NAME = "minecraft-backup"
  RETENTION_DAYS       = 90

  TAGS = {
    project = "epic-gamers-minecraft"
  }
}

# ---------------------------------------------------------
# DISCORD BOT
# ---------------------------------------------------------

module "discord_bot" {
  source = "../../modules/discord-bot"

  NAME = "egm-prod"

  EKS_CLUSTER_NAME = "egm-prod"

  PRIVATE_SUBNET_IDS = module.vpc.private_subnet_ids

  TAGS = {
    project = "epic-gamers-minecraft"
  }
}

# ---------------------------------------------------------
# GITHUB ACTIONS - EKS ACCESS
# ---------------------------------------------------------

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = "egm-prod"
  principal_arn = "arn:aws:iam::740901968217:role/epic-gamers-minecraft-github-oidc-test"

  type = "STANDARD"

  tags = {
    project = "epic-gamers-minecraft"
  }
}

resource "aws_eks_access_policy_association" "github_actions_discord_bot" {
  cluster_name  = "egm-prod"
  principal_arn = aws_eks_access_entry.github_actions.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type = "namespace"

    namespaces = [
      "discord-bot"
    ]
  }
}