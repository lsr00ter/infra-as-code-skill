variable "zone_name" {
  description = "Cloudflare zone (apex domain), for example example.com."
  type        = string
}

variable "records" {
  description = <<-EOT
    DNS records keyed by a stable identifier. The key is only used as the
    Terraform address, so renaming a key replaces the record.
    name is the full record name, for example "app.example.com", or "@" for the apex.
  EOT
  type = map(object({
    name    = string
    type    = string
    content = string
    ttl     = optional(number, 1) # 1 means "automatic" in Cloudflare.
    proxied = optional(bool, false)
    comment = optional(string, "Managed by Terraform")
  }))

  validation {
    condition     = alltrue([for r in values(var.records) : contains(["A", "AAAA", "CNAME", "TXT", "MX"], r.type)])
    error_message = "type must be one of A, AAAA, CNAME, TXT, MX. Add more types here when needed."
  }

  validation {
    condition     = alltrue([for r in values(var.records) : !r.proxied || contains(["A", "AAAA", "CNAME"], r.type)])
    error_message = "Only A, AAAA, and CNAME records can be proxied."
  }
}
