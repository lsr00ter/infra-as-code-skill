# infra-as-code-skill

An agent skill for provisioning cloud infrastructure with Terraform and configuring hosts with Ansible. The agent loads `SKILL.md`, reads the provider reference, copies a template into your project, and runs plan before any apply.

## Supported providers

| Category | Provider | Terraform provider | Credentials (environment) |
| --- | --- | --- | --- |
| Cloud computing | AWS | `hashicorp/aws` ~> 6.0 | `AWS_PROFILE` or `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` |
| Cloud computing | Alibaba Cloud | `aliyun/alicloud` ~> 2.1 | `ALIBABA_CLOUD_PROFILE` or `ALIBABA_CLOUD_ACCESS_KEY_ID` / `ALIBABA_CLOUD_ACCESS_KEY_SECRET` |
| Cloud computing | Tencent Cloud | `tencentcloudstack/tencentcloud` ~> 1.83 | `TENCENTCLOUD_SECRET_ID` / `TENCENTCLOUD_SECRET_KEY` |
| Cloud computing | Huawei Cloud | `huaweicloud/huaweicloud` ~> 1.100 | `HW_ACCESS_KEY` / `HW_SECRET_KEY` |
| Domain name (DNS) | Cloudflare | `cloudflare/cloudflare` ~> 5.0 | `CLOUDFLARE_API_TOKEN` |

Each compute template creates a VPC, a subnet, a security group that allows SSH only from the CIDRs you list, an SSH key pair, and one Ubuntu 24.04 VM with a public IP. The Cloudflare template manages a map of DNS records in one zone.

## Requirements

- Terraform 1.6 or later (OpenTofu works too: set `TF_BIN=tofu` for the validation script)
- Ansible core 2.16 or later
- Optional: `ansible-lint`

## Install

Clone the repo into your agent's skills directory:

```bash
git clone https://github.com/lsr00ter/infra-as-code-skill.git ~/.agents/skills/infra-as-code
```

For Claude Code, use `~/.claude/skills/infra-as-code` instead.

## Layout

```text
.
├── SKILL.md                     # Skill entry point loaded by the agent
├── AGENTS.md                    # Guide for agents working on this repo
├── .env.example                 # Credential variable names for every provider
├── references/                  # Per-provider notes: credentials, resources, pitfalls
├── scripts/validate.sh          # fmt, validate, and lint for every template
└── templates/
    ├── terraform/
    │   ├── compute/{aws,alicloud,tencentcloud,huaweicloud}/
    │   └── dns/cloudflare/
    └── ansible/                 # ansible.cfg, inventory example, site.yml, common role
```

Every Terraform template has the same files: `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`, and `terraform.tfvars.example`. Compute templates all export `instance_id`, `public_ip`, `private_ip`, and `ssh_user`.

## Manual use

```bash
cp -r templates/terraform/compute/aws ~/work/demo && cd ~/work/demo
cp terraform.tfvars.example terraform.tfvars   # edit region, ssh key, allowed CIDRs
cp /path/to/infra-as-code-skill/.env.example .env   # uncomment and fill in the AWS section
set -a; source .env; set +a
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

Then point a domain at the VM with `templates/terraform/dns/cloudflare`, using the `public_ip` output as the A record content. Configure the host with Ansible:

```bash
cd templates/ansible
cp inventory/hosts.yml.example inventory/hosts.yml   # fill in public_ip and ssh_user
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/site.yml --check --diff
ansible-playbook playbooks/site.yml
```

## Validate

```bash
./scripts/validate.sh
```

It runs `terraform fmt -check`, `terraform init -backend=false` and `terraform validate` in each template, the Ansible syntax check, and `ansible-lint` when installed. It needs network access to download providers, but no cloud credentials.

## Security

- Credentials are read from the environment only. `*.tfvars`, `*.tfstate`, plan files, `.env`, and the real Ansible inventory are git-ignored.
- `ssh_allowed_cidrs` has no default, so SSH is never opened to `0.0.0.0/0` by accident.
- The skill tells the agent to show the plan and wait for approval before `apply` or `destroy`.

## License

MIT
