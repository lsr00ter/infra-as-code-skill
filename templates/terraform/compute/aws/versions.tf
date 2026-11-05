terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Credentials come from the environment (AWS_PROFILE, or
# AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY). Never set them here.
provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}
