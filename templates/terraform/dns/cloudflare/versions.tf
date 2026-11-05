terraform {
  required_version = ">= 1.6"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# The API token comes from the environment (CLOUDFLARE_API_TOKEN).
# Scope it to Zone:DNS:Edit on the target zone only. Never set it here.
provider "cloudflare" {}
