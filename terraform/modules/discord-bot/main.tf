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