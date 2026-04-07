# Homelab IaC

## Scope
Verification only - no apply/destroy/playbook execution. Runs in devcontainer sandbox with read-only access.

## Dev Environment
- `.devcontainer/` - Arch Linux with pre-installed tools: opentofu, ansible, ansible-lint, talosctl, kubectl, cilium-cli, sops, opencode
- Execute all commands inside container
- Install `opencode-devcontainers` plugin in `~/.config/opencode/opencode.json`:
  ```json
  { "plugin": ["opencode-devcontainers"] }
  ```

## Multiple Development Containers
Use the plugin to run isolated containers per branch:
```bash
/devcontainer my-branch    # Start devcontainer for branch
/devcontainer              # Show current status
/devcontainer off          # Disable
```
Port range: 13000-13099 (auto-assigned per branch)

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
# Terraform/OpenTofu (run from each cluster directory)
tofu validate terraform/azeroth
tofu validate terraform/tbc
tofu validate terraform/northrend
tofu validate terraform/test

# Ansible
ansible-playbook --syntax-check ansible/playbooks/*.yaml
ansible-lint ansible/playbooks/*.yaml

# Kustomize (Flux)
kubectl kustomize clusters/production --dry-run=client
kubectl kustomize apps/production --dry-run=client
kubectl kustomize infrastructure/production --dry-run=client

# SOPS (verify encrypted files without decrypting)
sops --dry-run -d clusters/production/secrets/*.yaml
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
