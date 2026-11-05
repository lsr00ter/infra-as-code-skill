# Huawei Cloud

- Terraform provider: `huaweicloud/huaweicloud`, pinned `~> 1.100`
- Template: `templates/terraform/compute/huaweicloud`

## Credentials

Set `HW_ACCESS_KEY` and `HW_SECRET_KEY` in the environment (plus `HW_SECURITY_TOKEN` for temporary credentials). `HW_REGION_NAME` can replace the `region` variable. `HW_PROFILE` selects a profile from the shared config file instead. Use an IAM user, not the account root key.

## Resources in the template

`huaweicloud_vpc`, `huaweicloud_vpc_subnet`, `huaweicloud_networking_secgroup`, `huaweicloud_networking_secgroup_rule`, `huaweicloud_kps_keypair`, `huaweicloud_compute_instance`, `huaweicloud_vpc_eip`, `huaweicloud_compute_eip_associate`.

## Pitfalls

- ECS instances get no public IP by default. The template creates an EIP and associates it, so use the EIP address, not `access_ip_v4`, for SSH and DNS.
- `huaweicloud_vpc_subnet` requires `gateway_ip`, which must sit inside the subnet CIDR. The template uses the first host address.
- `delete_default_rules = true` removes the default rules, including allow-all outbound, so the template adds an explicit egress rule. The argument is ForceNew, so changing it replaces the security group.
- Flavors are chosen by CPU and memory through `huaweicloud_compute_flavors`. If no flavor matches in the zone, apply fails on an empty list.
- The EIP `type` accepts `5_bgp` (dynamic BGP, the default) and `5_sbgp` (static BGP). Changing it replaces the EIP.
- The default login user for Ubuntu public images is `root`.

## Remote state

OBS through the `s3` backend with a custom endpoint, following Huawei's `remote_state_backend` guide. That guide sets `skip_region_validation`, `skip_credentials_validation`, `skip_metadata_api_check`, `skip_requesting_account_id`, and `skip_s3_checksum`, and does not document locking. Run one apply at a time.
