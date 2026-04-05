# Homelab IaC

## Scope
Verification only - no apply/destroy/playbook execution. Runs in devcontainer sandbox with read-only access.

## Dev Environment
- `.devcontainer/` - Arch Linux with pre-installed tools: opentofu, ansible, talosctl, kubectl, cilium-cli, opencode
- Execute all commands inside container

## Directory Structure
```
ansible/playbooks/         # Ansible playbooks
ansible/playbooks/roles/  # Ansible roles
ansible/production/       # Inventory
terraform/<cluster>/     # OpenTofu configs (azeroth, tbc, northrend, test)
clusters/production/     # Flux GitOps (kubeconfig, talosconfig, gotk-*)
apps/production/         # App deployments (harbor, onedev, podinfo, vaultwarden)
infrastructure/production/  # Infra (controllers, storage-classes, secrets)
```

## Validation Commands
```bash
# Terraform/OpenTofu
tofu validate <cluster_dir>

# Ansible
ansible-playbook --syntax-check <playbook.yaml>

# Kustomize (Flux)
kubectl kustomize <dir> --dry-run=client

# SOPS (verify encrypted files without decrypting)
sops --dry-run -d <file>
```

## Best Practices to Verify
- **Ansible FQCN**: Module names must be fully qualified (e.g., `ansible.builtin.file`, not `file`)
- **Ansible truthy values**: Use `yes`/`no` or explicit integers, never `true`/`false`
- **Terraform**: Provider versions pinned, required variables defined
- **SOPS**: Secrets encrypted, never commit plaintext credentials

## Validation Order
1. `tofu validate` → 2. `ansible --syntax-check` → 3. `kubectl kustomize --dry-run`

## Output Format
- Summarize validation results concisely
- Label errors clearly with file:line references
