---
name: infra-as-code
description: 'Use this skill when the user wants to provision or configure cloud infrastructure as code with Terraform or Ansible. It covers compute (VPC, subnet, security group, SSH key, Linux VM) on AWS, Alibaba Cloud (alicloud), Tencent Cloud, and Huawei Cloud, and DNS records on Cloudflare. Triggers include "create a server on AWS/Aliyun/Tencent/Huawei", "add a Cloudflare DNS record", "write Terraform for", "write an Ansible playbook", "point my domain at this VM". Do not use it for Kubernetes manifests, Pulumi, CloudFormation, or providers not listed here.'
license: MIT
compatibility: 'Requires Terraform >= 1.6 (or OpenTofu) and Ansible core >= 2.16. Cloud credentials must already be set in the environment.'
allowed-tools: shell(terraform:*), shell(tofu:*), shell(ansible:*), shell(ansible-playbook:*), shell(ansible-galaxy:*), shell(ansible-lint:*)
---

# Infrastructure as Code

Provision cloud resources with Terraform and configure hosts with Ansible, starting from the templates in this skill.

## Supported providers

| Category | Provider | Terraform source | Template | Reference |
| --- | --- | --- | --- | --- |
| Compute | AWS | `hashicorp/aws` | `templates/terraform/compute/aws` | `references/aws.md` |
| Compute | Alibaba Cloud | `aliyun/alicloud` | `templates/terraform/compute/alicloud` | `references/alicloud.md` |
| Compute | Tencent Cloud | `tencentcloudstack/tencentcloud` | `templates/terraform/compute/tencentcloud` | `references/tencentcloud.md` |
| Compute | Huawei Cloud | `huaweicloud/huaweicloud` | `templates/terraform/compute/huaweicloud` | `references/huaweicloud.md` |
| DNS | Cloudflare | `cloudflare/cloudflare` | `templates/terraform/dns/cloudflare` | `references/cloudflare.md` |

Read the reference file for the provider before writing code. It lists the credential variables, the resource names, and the known pitfalls.

## Workflow

1. **Clarify scope.** Confirm the provider, region, instance size, the CIDRs allowed to reach SSH, and the domain if DNS is involved. Ask instead of guessing a region or opening SSH to `0.0.0.0/0`.
2. **Copy the template** into the user's project directory. Never edit the templates in place for a user's deployment.
3. **Check credentials** without printing them. Run `env | grep -E '^(AWS_|ALIBABA_CLOUD_|ALICLOUD_|TENCENTCLOUD_|HW_|CLOUDFLARE_)' | cut -d= -f1` and report missing variable names. If any are missing, point the user to `.env.example` in this skill: they copy it to `.env` in their project, fill in their own values, and load it with `set -a; source .env; set +a`. Never fill in values yourself.
4. **Write `terraform.tfvars`** from `terraform.tfvars.example`. It is git-ignored. Keep secrets out of it; they belong in environment variables.
5. **Validate**: `terraform init`, `terraform fmt -check`, `terraform validate`.
6. **Plan**: `terraform plan -out=tfplan`. Show the user the resource summary (add, change, destroy counts and any replacements).
7. **Apply only after the user approves the plan**: `terraform apply tfplan`. Never run `terraform apply -auto-approve` or `terraform destroy` without explicit confirmation.
8. **Chain outputs.** Pass the compute `public_ip` into the Cloudflare `records` map, and `public_ip` and `ssh_user` into the Ansible inventory.
9. **Configure hosts** with Ansible: `ansible-galaxy collection install -r requirements.yml`, then `ansible-playbook playbooks/site.yml --check --diff` before the real run.

## Rules

- Credentials come from environment variables or the provider's CLI profile. Never write keys or tokens into `.tf`, `.tfvars`, inventory, or chat output.
- Pin providers with `~>` constraints in `versions.tf` and commit `.terraform.lock.hcl` in user projects.
- One state per provider per environment. For anything beyond a demo, configure a remote backend (S3, OSS, COS, OBS, or Terraform Cloud) with locking.
- Prefer data sources for images and zones over hard-coded IDs, which differ per region.
- Treat any plan that destroys or replaces a resource as a hard stop. Explain why it happens and ask before applying.
- Ansible tasks use fully qualified collection names (`ansible.builtin.apt`, not `apt`) and must be idempotent.
