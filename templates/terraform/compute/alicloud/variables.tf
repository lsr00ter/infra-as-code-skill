variable "region" {
  description = "Alibaba Cloud region, for example cn-hangzhou."
  type        = string
}

variable "name" {
  description = "Name prefix for every resource."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}$", var.name))
    error_message = "Use 2-31 lowercase letters, digits, or hyphens, starting with a letter."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the vSwitch. Must sit inside vpc_cidr."
  type        = string
  default     = "10.10.1.0/24"
}

variable "instance_type" {
  description = "ECS instance type. The zone is chosen from zones that offer this type."
  type        = string
  default     = "ecs.t6-c1m2.large"
}

variable "root_volume_size" {
  description = "System disk size in GiB."
  type        = number
  default     = 40
}

variable "internet_bandwidth_out" {
  description = "Outbound public bandwidth in Mbit/s. A value above 0 assigns a public IP."
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
