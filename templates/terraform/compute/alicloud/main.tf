data "alicloud_zones" "available" {
  available_instance_type     = var.instance_type
  available_resource_creation = "VSwitch"
}

# Latest Ubuntu 24.04 system image.
data "alicloud_images" "ubuntu" {
  owners      = "system"
  name_regex  = "^ubuntu_24_04_x64"
  most_recent = true
}

resource "alicloud_vpc" "this" {
  vpc_name   = "${var.name}-vpc"
  cidr_block = var.vpc_cidr
  tags       = var.tags
}

resource "alicloud_vswitch" "this" {
  vswitch_name = "${var.name}-vsw"
  vpc_id       = alicloud_vpc.this.id
  cidr_block   = var.subnet_cidr
  zone_id      = data.alicloud_zones.available.zones[0].id
  tags         = var.tags
}

resource "alicloud_security_group" "this" {
  security_group_name = "${var.name}-sg"
  description         = "SSH ingress for ${var.name}"
  vpc_id              = alicloud_vpc.this.id
  tags                = var.tags
}

resource "alicloud_security_group_rule" "ssh" {
  for_each = toset(var.ssh_allowed_cidrs)

  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.this.id
  cidr_ip           = each.value
}

resource "alicloud_ecs_key_pair" "this" {
  key_pair_name = "${var.name}-key"
  public_key    = var.ssh_public_key
  tags          = var.tags
}

resource "alicloud_instance" "this" {
  instance_name              = var.name
  host_name                  = var.name
  image_id                   = data.alicloud_images.ubuntu.images[0].id
  instance_type              = var.instance_type
  vswitch_id                 = alicloud_vswitch.this.id
  security_groups            = [alicloud_security_group.this.id]
  key_name                   = alicloud_ecs_key_pair.this.key_pair_name
  internet_max_bandwidth_out = var.internet_bandwidth_out
  system_disk_category       = "cloud_essd"
  system_disk_size           = var.root_volume_size
  tags                       = var.tags
}
