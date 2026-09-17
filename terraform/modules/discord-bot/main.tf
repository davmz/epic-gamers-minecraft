# ---------------------------------------------------------
# ECR REPOSITORY
# ---------------------------------------------------------

resource "aws_ecr_repository" "this" {
  name                 = "${var.NAME}-discord-bot"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.TAGS
}

# ---------------------------------------------------------
# ECR LIFECYCLE
# ---------------------------------------------------------

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1

        description = "Keep the latest 10 Discord bot images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ---------------------------------------------------------
# CURRENT AWS ACCOUNT / REGION
# ---------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ---------------------------------------------------------
# FARGATE POD EXECUTION ROLE
# ---------------------------------------------------------

data "aws_iam_policy_document" "fargate_pod_execution_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "eks-fargate-pods.amazonaws.com"
      ]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:eks:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:fargateprofile/${var.EKS_CLUSTER_NAME}/*"
      ]
    }
  }
}

resource "aws_iam_role" "fargate_pod_execution" {
  name = "${var.NAME}-discord-bot-fargate"

  assume_role_policy = data.aws_iam_policy_document.fargate_pod_execution_assume_role.json

  tags = var.TAGS
}

resource "aws_iam_role_policy_attachment" "fargate_pod_execution" {
  role = aws_iam_role.fargate_pod_execution.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}

# ---------------------------------------------------------
# EKS FARGATE PROFILE
# ---------------------------------------------------------

resource "aws_eks_fargate_profile" "discord_bot" {
  cluster_name           = var.EKS_CLUSTER_NAME
  fargate_profile_name   = "${var.NAME}-discord-bot"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn
  subnet_ids             = var.PRIVATE_SUBNET_IDS

  selector {
    namespace = "discord-bot"
  }

  tags = var.TAGS

  depends_on = [
    aws_iam_role_policy_attachment.fargate_pod_execution
  ]
}