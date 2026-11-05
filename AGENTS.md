# AGENTS.md

Guide for agents changing this repository. To use the skill, read `SKILL.md` instead.

## What this repo is

An agent skill. `SKILL.md` is the entry point, `references/` holds per-provider notes, and `templates/` holds Terraform and Ansible starting points that the skill copies into user projects. There is no application code and no build step.

## Commands

```bash
./scripts/validate.sh                 # run all checks; must pass before you finish
terraform fmt -recursive templates/terraform
TF_BIN=tofu ./scripts/validate.sh     # same checks with OpenTofu
```

`validate.sh` downloads providers into each template's `.terraform/` (git-ignored). It needs network access but no cloud credentials. Never run `terraform plan` or `apply` against a real account while working on this repo.

## Conventions

### Terraform templates

- One directory per provider: `templates/terraform/compute/<provider>` or `templates/terraform/dns/<provider>`. The directory name matches the Terraform provider's local name.
- Every template has exactly these files: `versions.tf` (required_version, required_providers, provider block), `variables.tf`, `main.tf`, `outputs.tf`, `terraform.tfvars.example`.
- Pin providers with `~>` on the major version (or minor, for 1.x providers). Do not commit `.terraform.lock.hcl` in templates; users commit their own.
- Provider blocks set only the region. Credentials always come from environment variables, which are documented in a comment and in the reference file.
- Compute templates share the same inputs (`region`, `name`, `vpc_cidr`, `subnet_cidr`, `root_volume_size`, `ssh_public_key`, `ssh_allowed_cidrs`, `tags`) and the same outputs (`instance_id`, `public_ip`, `private_ip`, `ssh_user`). Keep that interface identical across providers so DNS and Ansible can consume any of them.
- `ssh_allowed_cidrs` never gets a default. Do not add rules that open ports to `0.0.0.0/0`.
- Look up images and zones with data sources. Do not hard-code AMI or image IDs.
- Every variable and output has a `description`. Add `validation` blocks for inputs with provider-specific limits.
- Resource labels are `this` when there is one of a kind.

### Ansible

- Fully qualified module names (`ansible.builtin.copy`). Tasks must be idempotent.
- Role variables are prefixed with the role name (`common_timezone`), as ansible-lint requires.
- Collections go in `templates/ansible/requirements.yml`.
- Inventory groups match the compute template directory names.

### References

Each provider has `references/<provider>.md` with these sections: credentials, resources in the template, pitfalls, remote state. Pitfalls should be specific failures you can name (a renamed argument, a quota, a default that differs), not general advice.

## Adding a provider

1. Create the template directory with the five standard files.
2. For compute, keep the shared inputs and outputs listed above.
3. Write `references/<provider>.md`.
4. Add a row to the provider tables in `SKILL.md` and `README.md`, add the provider's credential prefix to the `env | grep` check in `SKILL.md`, and add its variables, commented out, to `.env.example`.
5. Add an inventory group to `templates/ansible/inventory/hosts.yml.example` (compute only).
6. Run `./scripts/validate.sh`.

## Secrets

Never commit real credentials, `*.tfvars`, state files, or plan files. `.gitignore` covers them; check `git status` before committing. Example values use documentation ranges (`203.0.113.0/24`, `198.51.100.0/24`) and `example.com`.

## Commits

Conventional Commits, scoped by provider or area, for example `feat(tencentcloud): add CVM template` or `docs(cloudflare): note v5 rename`.
