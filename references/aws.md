# AWS

- Terraform provider: `hashicorp/aws`, pinned `~> 6.0`
- Ansible collection: `amazon.aws`
- Template: `templates/terraform/compute/aws`

## Credentials

Set one of these in the environment:

- `AWS_PROFILE` (uses `~/.aws/config` and `~/.aws/credentials`)
- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` (plus `AWS_SESSION_TOKEN` for temporary credentials)

Check access with `aws sts get-caller-identity`.

## Resources in the template

`aws_vpc`, `aws_internet_gateway`, `aws_subnet`, `aws_route_table`, `aws_route_table_association`, `aws_security_group`, `aws_vpc_security_group_ingress_rule`, `aws_vpc_security_group_egress_rule`, `aws_key_pair`, `aws_instance`.

## Pitfalls

- Use the standalone `aws_vpc_security_group_ingress_rule` and `aws_vpc_security_group_egress_rule` resources. The provider docs warn that mixing them with inline `ingress` and `egress` blocks on the same security group causes rule conflicts, permanent diffs, and overwritten rules.
- AWS adds an allow-all egress rule to every new VPC security group, but Terraform removes it on creation. The template therefore adds an explicit allow-all egress rule.
- The Canonical owner ID `099720109477` covers the commercial regions. China (`cn-*`) and GovCloud regions use different owner IDs.
- `metadata_options.http_tokens = "required"` enforces IMDSv2.
- The default login user for Ubuntu AMIs is `ubuntu`.

## Remote state

S3 backend with S3-native locking (`use_lockfile = true`). It is generally available from Terraform 1.11. The DynamoDB locking arguments are deprecated.
