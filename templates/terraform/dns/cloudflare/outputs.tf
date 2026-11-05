output "zone_id" {
  description = "Cloudflare zone ID."
  value       = data.cloudflare_zone.this.zone_id
}

output "records" {
  description = "Created records keyed like var.records."
  value = {
    for k, r in cloudflare_dns_record.this : k => {
      id      = r.id
      name    = r.name
      type    = r.type
      content = r.content
      proxied = r.proxied
    }
  }
}
