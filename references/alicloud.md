# Alibaba Cloud (alicloud)

- Terraform provider: `aliyun/alicloud`, pinned `~> 2.1`
- Template: `templates/terraform/compute/alicloud`

## Credentials

Set one of these in the environment:

- `ALIBABA_CLOUD_ACCESS_KEY_ID` and `ALIBABA_CLOUD_ACCESS_KEY_SECRET` (plus `ALIBABA_CLOUD_SECURITY_TOKEN` for STS)
- `ALIBABA_CLOUD_PROFILE` (uses `~/.aliyun/config.json` from the `aliyun` CLI)

`ALIBABA_CLOUD_REGION` can replace the `region` variable. The older `ALICLOUD_ACCESS_KEY`, `ALICLOUD_SECRET_KEY`, `ALICLOUD_SECURITY_TOKEN`, and `ALICLOUD_PROFILE` names have been deprecated since provider v1.228.0. They still work, but examples on the internet that use them are out of date.

Use a RAM user or role, not the root account AccessKey.

## Resources in the template

`alicloud_vpc`, `alicloud_vswitch`, `alicloud_security_group`, `alicloud_security_group_rule`, `alicloud_ecs_key_pair`, `alicloud_instance`.

## Pitfalls

- Instance types are not available in every zone. The template picks the zone from `alicloud_zones` filtered by `available_instance_type`, so changing `instance_type` can move the instance to another zone and replace it.
- `internet_max_bandwidth_out > 0` assigns a public IP at creation. The old `allocate_public_ip` argument is deprecated. Use an EIP if the address must survive instance replacement.
- Security group rules on VPC security groups need `nic_type = "intranet"`, and `port_range` uses the `22/22` format.
- Use the current argument names: `vpc_name`, `vswitch_name`, `security_group_name`, `key_pair_name`. The older `name` and `key_name` arguments are deprecated, and many examples online still use them.
- Accounts in mainland China regions need real-name verification before ECS creation succeeds.
- The template matches system images with `^ubuntu_24_04_x64`. The default login user is `root`.

## Remote state

OSS backend, with locking through a Tablestore table (`tablestore_endpoint`, `tablestore_table`). The table needs a primary key named `LockID` of type String.
