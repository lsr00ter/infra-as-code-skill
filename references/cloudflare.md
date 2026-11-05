# Cloudflare DNS

- Terraform provider: `cloudflare/cloudflare`, pinned `~> 5.0`
- Template: `templates/terraform/dns/cloudflare`

## Credentials

Set `CLOUDFLARE_API_TOKEN` in the environment. Create the token with the "Edit zone DNS" template and limit it to the target zone. Cloudflare considers the global API key (`CLOUDFLARE_API_KEY` with `CLOUDFLARE_EMAIL`) legacy, so do not use it.

## Resources in the template

`cloudflare_zone` (data source) and `cloudflare_dns_record`.

## Pitfalls

- Provider v5 renamed `cloudflare_record` to `cloudflare_dns_record` and `value` to `content`. Examples written for v4 do not work.
- In v5 the `cloudflare_zone` data source takes a `filter = { name = ... }` object and exposes `zone_id`.
- `ttl` is required in v5. `1` means "automatic".
- `name` takes the full record name (`app.example.com`). Use `@` for the apex.
- Proxied records always use the automatic TTL, and Cloudflare does not let you change it. The template sends `1` for proxied records so the configuration matches what Cloudflare stores.
- Only records used for IP address resolution (A, AAAA, CNAME) can be proxied.
- Records created in the dashboard are not managed by Terraform until you import them (`terraform import`). Creating a record that already exists in the zone either fails or adds a second record with the same name, depending on the type, so check the zone before the first apply.

## Linking to compute

Put the compute template's `public_ip` output in the `content` field of an A record. In one root module, reference it directly: `content = module.web.public_ip`.
