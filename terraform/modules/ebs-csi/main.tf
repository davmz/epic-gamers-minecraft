# ---------------------------------------------------------
# EBS CSI IAM Role
# ---------------------------------------------------------

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "ebs_csi" {
  name               = "${var.NAME}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = var.TAGS
}


# ---------------------------------------------------------
# EBS CSI IAM Policy
# ---------------------------------------------------------

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}


# ---------------------------------------------------------
# Determine Compatible Add-on Versions
# ---------------------------------------------------------

data "aws_eks_addon_version" "pod_identity_agent" {
  addon_name         = "eks-pod-identity-agent"
  kubernetes_version = var.KUBERNETES_VERSION
  most_recent        = true
}

data "aws_eks_addon_version" "ebs_csi" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.KUBERNETES_VERSION
  most_recent        = true
}


# ---------------------------------------------------------
# EKS Pod Identity Agent
# ---------------------------------------------------------

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name  = var.CLUSTER_NAME
  addon_name    = "eks-pod-identity-agent"
  addon_version = data.aws_eks_addon_version.pod_identity_agent.version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.TAGS
}


# ---------------------------------------------------------
# AWS EBS CSI Driver
# ---------------------------------------------------------

resource "aws_eks_addon" "ebs_csi" {
  cluster_name  = var.CLUSTER_NAME
  addon_name    = "aws-ebs-csi-driver"
  addon_version = data.aws_eks_addon_version.ebs_csi.version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  pod_identity_association {
    service_account = "ebs-csi-controller-sa"
    role_arn        = aws_iam_role.ebs_csi.arn
  }

  tags = var.TAGS

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_iam_role_policy_attachment.ebs_csi
  ]
}