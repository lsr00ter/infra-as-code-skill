#!/usr/bin/env bash
# Static checks for every template. Needs no cloud credentials.
# Terraform downloads providers on first run, so network access is required.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tf="${TF_BIN:-terraform}"
status=0

echo "==> terraform fmt"
"$tf" fmt -check -recursive "$root/templates/terraform" || status=1

while IFS= read -r dir; do
  echo "==> terraform validate ${dir#"$root"/}"
  if ! { "$tf" -chdir="$dir" init -backend=false -input=false >/dev/null &&
         "$tf" -chdir="$dir" validate -no-color; }; then
    status=1
  fi
done < <(find "$root/templates/terraform" -name versions.tf -exec dirname {} \; | sort)

echo "==> ansible syntax check"
(
  cd "$root/templates/ansible"
  ansible-playbook -i localhost, --syntax-check playbooks/site.yml
) || status=1

if command -v ansible-lint >/dev/null 2>&1; then
  echo "==> ansible-lint"
  (cd "$root/templates/ansible" && ansible-lint playbooks/site.yml) || status=1
else
  echo "==> ansible-lint not installed, skipping"
fi

exit "$status"
