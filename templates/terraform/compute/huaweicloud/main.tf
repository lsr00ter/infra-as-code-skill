data "huaweicloud_availability_zones" "available" {}

locals {
  zone = data.huaweicloud_availability_zones.available.names[0]
}

data "huaweicloud_compute_flavors" "this" {
  availability_zone = local.zone
  performance_type  = "normal"
  cpu_core_count    = var.cpu_core_count
  memory_size       = var.memory_size
}

# Latest Ubuntu 24.04 public image.
data "huaweicloud_images_image" "ubuntu" {
  name_regex  = "^Ubuntu 24.04"
  visibility  = "public"
  most_recent = true
}

resource "huaweicloud_vpc" "this" {
  name = "${var.name}-vpc"
  cidr = var.vpc_cidr
  tags = var.tags
}

resource "huaweicloud_vpc_subnet" "this" {
  name              = "${var.name}-subnet"
  vpc_id            = huaweicloud_vpc.this.id
  cidr              = var.subnet_cidr
  gateway_ip        = cidrhost(var.subnet_cidr, 1)
  availability_zone = local.zone
  tags              = var.tags
}

resource "huaweicloud_networking_secgroup" "this" {
  name                 = "${var.name}-sg"
  description          = "SSH ingress for ${var.name}"
  delete_default_rules = true
}

resource "huaweicloud_networking_secgroup_rule" "ssh" {
  for_each = toset(var.ssh_allowed_cidrs)

  security_group_id = huaweicloud_networking_secgroup.this.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  ports             = "22"
  remote_ip_prefix  = each.value
}

resource "huaweicloud_networking_secgroup_rule" "egress" {
  security_group_id = huaweicloud_networking_secgroup.this.id
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "huaweicloud_kps_keypair" "this" {
  name       = "${var.name}-key"
  public_key = var.ssh_public_key
}

resource "huaweicloud_compute_instance" "this" {
  name               = var.name
  availability_zone  = local.zone
  image_id           = data.huaweicloud_images_image.ubuntu.id
  flavor_id          = data.huaweicloud_compute_flavors.this.ids[0]
  security_group_ids = [huaweicloud_networking_secgroup.this.id]
  key_pair           = huaweicloud_kps_keypair.this.name
  system_disk_type   = "SSD"
  system_disk_size   = var.root_volume_size
  tags               = var.tags

  network {
    uuid = huaweicloud_vpc_subnet.this.id
  }
}

resource "huaweicloud_vpc_eip" "this" {
  publicip {
    type = "5_bgp"
  }

  bandwidth {
    name        = "${var.name}-bw"
    size        = var.eip_bandwidth
    share_type  = "PER"
    charge_mode = "traffic"
  }

  tags = var.tags
}

resource "huaweicloud_compute_eip_associate" "this" {
  public_ip   = huaweicloud_vpc_eip.this.address
  instance_id = huaweicloud_compute_instance.this.id
}
