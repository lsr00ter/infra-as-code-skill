data "tencentcloud_availability_zones_by_product" "cvm" {
  product = "cvm"
}

# Latest Ubuntu 24.04 public image.
data "tencentcloud_images" "ubuntu" {
  image_type       = ["PUBLIC_IMAGE"]
  image_name_regex = "^Ubuntu Server 24.04"
}

locals {
  zone = data.tencentcloud_availability_zones_by_product.cvm.zones[0].name
  # Key pair names allow only letters, digits, and underscores.
  key_name = replace("${var.name}_key", "-", "_")
}

resource "tencentcloud_vpc" "this" {
  name       = "${var.name}-vpc"
  cidr_block = var.vpc_cidr
  tags       = var.tags
}

resource "tencentcloud_subnet" "this" {
  name              = "${var.name}-subnet"
  vpc_id            = tencentcloud_vpc.this.id
  cidr_block        = var.subnet_cidr
  availability_zone = local.zone
  tags              = var.tags
}

resource "tencentcloud_security_group" "this" {
  name        = "${var.name}-sg"
  description = "SSH ingress for ${var.name}"
  tags        = var.tags
}

resource "tencentcloud_security_group_rule_set" "this" {
  security_group_id = tencentcloud_security_group.this.id

  dynamic "ingress" {
    for_each = var.ssh_allowed_cidrs

    content {
      action      = "ACCEPT"
      cidr_block  = ingress.value
      protocol    = "TCP"
      port        = "22"
      description = "SSH"
    }
  }

  egress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    protocol    = "ALL"
    port        = "ALL"
    description = "All outbound"
  }
}

resource "tencentcloud_key_pair" "this" {
  key_name   = local.key_name
  public_key = var.ssh_public_key
}

resource "tencentcloud_instance" "this" {
  instance_name              = var.name
  hostname                   = var.name
  availability_zone          = local.zone
  image_id                   = data.tencentcloud_images.ubuntu.images[0].image_id
  instance_type              = var.instance_type
  vpc_id                     = tencentcloud_vpc.this.id
  subnet_id                  = tencentcloud_subnet.this.id
  orderly_security_groups    = [tencentcloud_security_group.this.id]
  key_ids                    = [tencentcloud_key_pair.this.id]
  system_disk_type           = "CLOUD_PREMIUM"
  system_disk_size           = var.root_volume_size
  allocate_public_ip         = true
  internet_charge_type       = "TRAFFIC_POSTPAID_BY_HOUR"
  internet_max_bandwidth_out = var.internet_bandwidth_out
  tags                       = var.tags
}
