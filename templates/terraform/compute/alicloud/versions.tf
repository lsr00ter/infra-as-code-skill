terraform {
  required_version = ">= 1.6"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 2.1"
    }
  }
}

# Credentials come from the environment (ALIBABA_CLOUD_ACCESS_KEY_ID /
# ALIBABA_CLOUD_ACCESS_KEY_SECRET, or ALIBABA_CLOUD_PROFILE). Never set them here.
provider "alicloud" {
  region = var.region
}
