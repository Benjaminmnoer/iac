# Homelab IaC

## Scope
Verification only - no apply/destroy/playbook execution. Runs in devcontainer sandbox with read-only access.

## Dev Environment
- `.devcontainer/` - Arch Linux with pre-installed tools: opentofu, ansible, ansible-lint, talosctl, sops, opencode
- Execute all commands inside container

## Directory Structure
```
ansible/playbooks/         # Ansible playbooks
ansible/playbooks/roles/  # Ansible roles (install_cli_tools, install_k8s_cluster, install_flux, generate_talos_configs, apply_talos_configs, bootstrap_talos)
ansible/production/       # Inventory (inventory.yaml)
terraform/<cluster>/     # OpenTofu configs (azeroth, tbc, northrend, test)
clusters/production/     # Flux GitOps (kubeconfig, talosconfig, gotk-*)
apps/production/         # App deployments (harbor, onedev, podinfo, vaultwarden)
infrastructure/production/  # Infra (controllers, storage-classes, secrets)
```

## Validation and preparation Commands
```bash
# Terraform/OpenTofu (run from each cluster directory)
tofu validate terraform/azeroth
tofu validate terraform/tbc
tofu validate terraform/northrend
tofu validate terraform/test

# Ansible
ansible-playbook --syntax-check ansible/playbooks/*.yaml
ansible-lint ansible/playbooks

# Ansible (bare metal Talos bootstrap)
ansible-playbook --syntax-check ansible/playbooks/bootstrap-talos-baremetal.yaml
ansible-lint ansible/playbooks/bootstrap-talos-baremetal.yaml

# Kustomize (Flux)
kubectl kustomize clusters/production --dry-run=client
kubectl kustomize apps/production --dry-run=client
kubectl kustomize infrastructure/production --dry-run=client

# SOPS (verify encrypted files without decrypting)
sops --dry-run -d clusters/production/secrets/*.yaml
```

## Ansible Lint Configuration
- Profile: production (strictest)
- Key rules enforced: var-naming (with role prefix), no-changed-when, yaml (line-length)
- All variables in roles must use role name as prefix (e.g., install_flux_git_repo)
- The `.ansible-lint.yml` config file is located in `ansible/playbooks/.ansible-lint.yml`

## Best Practices to Verify
- **Ansible FQCN**: Module names must be fully qualified (e.g., `ansible.builtin.file`, not `file`)
- **Ansible truthy values**: Use `yes`/`no` or explicit integers, never `true`/`false`
- **Ansible variable naming**: All registered variables in roles must use the role name as prefix (e.g., `install_k8s_cluster_cilium_status`)
- **Terraform**: Provider versions pinned, required variables defined
- **SOPS**: Secrets encrypted, never commit plaintext credentials

## Output Format
- Summarize validation results concisely
- Label errors clearly with file:line references
- Update AGENTS.md along the way when new practices should be adopted or new tools will be included
- Update README.md if one of the following criteria match:
  - Infrastructure stack changes
  - Application is added to Talos cluster
