variable "region" {
  description = "Tencent Cloud region, for example ap-guangzhou."
  type        = string
}

variable "name" {
  description = "Name prefix for every resource."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.name))
    error_message = "Use 2-21 lowercase letters, digits, or hyphens, starting with a letter. The key pair name limits the length."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet. Must sit inside vpc_cidr."
  type        = string
  default     = "10.10.1.0/24"
}

variable "instance_type" {
  description = "CVM instance type."
  type        = string
  default     = "S5.MEDIUM4"
}

variable "root_volume_size" {
  description = "System disk size in GiB."
  type        = number
  default     = 50
}

variable "internet_bandwidth_out" {
  description = "Outbound public bandwidth in Mbit/s."
  type        = number
  default     = 5
}

variable "ssh_public_key" {
  description = "OpenSSH public key installed on the instance."
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to reach port 22. No default, so SSH is never opened to the world by accident."
  type        = list(string)

  validation {
    condition     = length(var.ssh_allowed_cidrs) > 0 && alltrue([for c in var.ssh_allowed_cidrs : can(cidrhost(c, 0))])
    error_message = "Provide at least one valid CIDR, for example 203.0.113.10/32."
  }
}

variable "tags" {
  description = "Tags applied to every taggable resource."
  type        = map(string)
  default = {
    ManagedBy = "terraform"
  }
}
