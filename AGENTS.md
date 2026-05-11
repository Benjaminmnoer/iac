# Homelab IaC

## Scope
Verification only - no apply/destroy/playbook execution. Runs in devcontainer sandbox with read-only access that has no connectivity to actual infrastructure (Proxmox, Talos nodes, Kubernetes clusters). All validation commands work locally. Dev container is Arch-based with opentofu, ansible, ansible-lint, talosctl, sops, trivy, checkov pre-installed.

## Key directories

| Path | Purpose |
|------|---------|
| `terraform/<cluster>/` | OpenTofu configs per cluster (azeroth, northrend, test) |
| `terraform/modules/vm\|container/` | Shared Proxmox modules |
| `ansible/inventory/` | Ansible inventory (everything under this is gitignored) |
| `ansible/playbooks/` | Playbooks + roles |
| `ansible/playbooks/roles/` | Roles: install_cli_tools, install_k8s_cluster, install_flux, generate_talos_configs, apply_talos_configs, bootstrap_talos, update_apt, update_pacman |
| `clusters/production/` | Flux GitOps root (kubeconfig + talosconfig gitignored) |
| `apps/production/` | App kustomizations (harbor, onedev, podinfo, vaultwarden) |
| `infrastructure/production/` | K8s infra (controllers, storage-classes, secrets) |

## Validation commands

```bash
# OpenTofu - init first, then validate per cluster dir
tofu validate terraform/azeroth
tofu validate terraform/northrend
tofu validate terraform/test

# OpenTofu - module tests (mocked)
tofu test terraform/modules/vm
tofu test terraform/modules/container

# Ansible - syntax check all playbooks
ansible-playbook --syntax-check ansible/playbooks/*.yaml

# Ansible-lint (config: ansible/playbooks/.ansible-lint.yml)
# ansible.cfg also has skip_list entries
ansible-lint ansible/playbooks

# Kustomize (Flux) - dry-run validation
kubectl kustomize clusters/production --dry-run=client
kubectl kustomize apps/production --dry-run=client
kubectl kustomize infrastructure/production --dry-run=client

# SOPS - verify encrypted files without decrypting
sops --dry-run -d clusters/production/secrets/*.yaml

# Checkov - infra security scanning
checkov -d terraform/ --config-file terraform/.checkov.yml
```

## Ansible conventions

- **FQCN required**: All module names must be fully qualified (e.g., `ansible.builtin.file`, not `file`)
- **Variable prefix**: All role variables and registered vars must use the role name as prefix (e.g., `install_flux_git_repo`, `install_k8s_cluster_cilium_status`)
- **Role variables in `defaults/`**: Use `defaults/main.yaml` for role variables (as done by `install_flux`, `install_k8s_cluster`, `install_cli_tools`)
- **Ansible-lint profile**: `production` (strictest). Skipped rules: `yaml[line-length]`, `name[missing]`, `name[template]`, `no-changed-when`, `command-instead-of-shell`, `internal-error` (via `.ansible-lint.yml`) — plus `var-naming[no-role-prefix]` and `no-changed-when` (via `ansible.cfg`)

## Bootstrap flow

The bare metal Talos bootstrap playbook (`bootstrap-talos-baremetal.yaml`) runs as 5 sequential plays tagged `tools → configs → apply → bootstrap → verify`, all targeting the `ansible_controller` host (except `apply` which targets `talos_controlplane:talos_workers`). The `deploy-talos-services.yaml` playbook runs after to install Cilium + Flux.

## Notes

- `test` file at repo root is empty (not a dir)
- Terraform modules have `tests.tftest.hcl` files using mocked `proxmox` provider — run via `tofu test`
- No pre-commit hooks, no CI workflows, no npm/yarn/pip package managers at root
- Inventory files (`ansible/inventory/*`) gitignored — no inventory committed to repo

## Conventions to maintain

- **Ansible**: FQCN modules, role-prefixed vars, `defaults/main.yaml` for variables
- **Terraform**: Provider versions pinned, required variables defined
- **SOPS**: Secrets encrypted, never commit plaintext credentials
