# Tencent Cloud

- Terraform provider: `tencentcloudstack/tencentcloud`, pinned `~> 1.83`
- Template: `templates/terraform/compute/tencentcloud`

## Credentials

Set `TENCENTCLOUD_SECRET_ID` and `TENCENTCLOUD_SECRET_KEY` in the environment (plus `TENCENTCLOUD_SECURITY_TOKEN` for temporary credentials). Use a CAM sub-user, not the root account key.

## Resources in the template

`tencentcloud_vpc`, `tencentcloud_subnet`, `tencentcloud_security_group`, `tencentcloud_security_group_rule_set`, `tencentcloud_key_pair`, `tencentcloud_instance`.

## Pitfalls

- `tencentcloud_security_group_rule_set` writes the whole rule list with the `ModifySecurityGroupPolicies` API, which replaces every existing rule in the group. Do not combine it with `tencentcloud_security_group_rule` or `tencentcloud_security_group_lite_rule` on the same group.
- Key pair names allow only letters, digits, and underscores, 1 to 25 characters (the provider's `ValidateKeyPairName` check). The template converts hyphens to underscores and limits `name` to 21 characters.
- Instance types vary by zone and sell out. If apply fails with a stock error, pick another zone or type with `tencentcloud_instance_types`.
- Public bandwidth needs `allocate_public_ip = true` and an `internet_charge_type`.
- The default login user for Ubuntu images is `ubuntu`.

## Remote state

COS backend, which supports locking natively.
