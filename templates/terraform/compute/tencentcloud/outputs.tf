output "instance_id" {
  description = "CVM instance ID."
  value       = tencentcloud_instance.this.id
}

output "public_ip" {
  description = "Public IPv4 address. Feed this to the Cloudflare DNS template or the Ansible inventory."
  value       = tencentcloud_instance.this.public_ip
}

output "private_ip" {
  description = "Private IPv4 address."
  value       = tencentcloud_instance.this.private_ip
}

output "ssh_user" {
  description = "Default login user for Tencent Cloud Ubuntu images."
  value       = "ubuntu"
}
