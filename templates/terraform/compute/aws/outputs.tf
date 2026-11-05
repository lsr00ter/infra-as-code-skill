output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IPv4 address. Feed this to the Cloudflare DNS template or the Ansible inventory."
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "Private IPv4 address."
  value       = aws_instance.this.private_ip
}

output "ssh_user" {
  description = "Default login user for the Ubuntu image."
  value       = "ubuntu"
}
