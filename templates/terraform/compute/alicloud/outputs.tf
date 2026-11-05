output "instance_id" {
  description = "ECS instance ID."
  value       = alicloud_instance.this.id
}

output "public_ip" {
  description = "Public IPv4 address. Feed this to the Cloudflare DNS template or the Ansible inventory."
  value       = alicloud_instance.this.public_ip
}

output "private_ip" {
  description = "Private IPv4 address."
  value       = alicloud_instance.this.primary_ip_address
}

output "ssh_user" {
  description = "Default login user for the Ubuntu system image."
  value       = "root"
}
