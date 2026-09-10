terraform {
  backend "s3" {
    bucket       = "epic-gamers-minecraft-tfstate-davmz"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}