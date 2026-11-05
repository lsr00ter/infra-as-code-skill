terraform {
  required_version = ">= 1.6"

  required_providers {
    tencentcloud = {
      source  = "tencentcloudstack/tencentcloud"
      version = "~> 1.83"
    }
  }
}

# Credentials come from the environment (TENCENTCLOUD_SECRET_ID /
# TENCENTCLOUD_SECRET_KEY). Never set them here.
provider "tencentcloud" {
  region = var.region
}
