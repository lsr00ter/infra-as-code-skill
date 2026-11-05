data "cloudflare_zone" "this" {
  filter = {
    name = var.zone_name
  }
}

resource "cloudflare_dns_record" "this" {
  for_each = var.records

  zone_id = data.cloudflare_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  # Cloudflare forces TTL to automatic (1) on proxied records.
  ttl     = each.value.proxied ? 1 : each.value.ttl
  proxied = each.value.proxied
  comment = each.value.comment
}
