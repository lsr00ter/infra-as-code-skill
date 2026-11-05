terraform {
  required_version = ">= 1.6"

  required_providers {
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.100"
    }
  }
}

# Credentials come from the environment (HW_ACCESS_KEY / HW_SECRET_KEY).
# Never set them here.
provider "huaweicloud" {
  region = var.region
}
