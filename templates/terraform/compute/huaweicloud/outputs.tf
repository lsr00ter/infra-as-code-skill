output "instance_id" {
  description = "ECS instance ID."
  value       = huaweicloud_compute_instance.this.id
}

output "public_ip" {
  description = "EIP address. Feed this to the Cloudflare DNS template or the Ansible inventory."
  value       = huaweicloud_vpc_eip.this.address
}

output "private_ip" {
  description = "Private IPv4 address."
  value       = huaweicloud_compute_instance.this.access_ip_v4
}

output "ssh_user" {
  description = "Default login user for Huawei Cloud Ubuntu public images."
  value       = "root"
}
