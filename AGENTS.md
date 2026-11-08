# Homelab IaC

Proxmox VMs (OpenTofu) + Ansible configuration + Talos/Flux GitOps Kubernetes.
Single-lifecycle repo: no packages, no build step, no test suite.

## Scope

- **Verification only.** Never run `tofu apply`/`destroy`, `ansible-playbook`, or anything needing cluster access.
- Sandbox has no `~/.ssh/id_ed25519`, no SOPS PGP secret key, and no network path to the cluster. Expect those failures.
- Working branch is `master`. `tofu init` rewrites `.terraform.lock.hcl` files — revert with `git checkout -- terraform/<cluster>/.terraform.lock.hcl` when you didn't intend to change provider versions.

## Environment

- Arch devcontainer (`.devcontainer/`): `opentofu`, `ansible`, `ansible-lint`, `sops`, `opencode`, `trivy`, `checkov` (`/opt/checkov-venv`, symlinked to `/usr/local/bin/checkov`).
- **Missing: `kubectl`, `kustomize`, `talosctl`, `flux`, `yq`, `jq`.** Kustomize/Flux rendering cannot be validated inside the sandbox.
- `.opencode/` is a bind mount of the host `~/.config/opencode` dir (agents, node_modules); it has its own `.gitignore` and is untracked.
- Network is available; `tofu init` downloads providers successfully.

## Layout

```
ansible/playbooks/         6 playbooks: update-system, get-vm-status, start-/shutdown-proxmox-vm,
                           enable-gpupassthrough, install-qemu-guest-agent
ansible/playbooks/roles/   update_apt, update_pacman  (that's all)
terraform/{azeroth,northrend,tbc,test}/   bpg/proxmox VMs, azurerm backend (acct tfstate27519)
apps/production/           podinfo, onedev, harbor, vaultwarden (namespace + HelmRepository + HelmRelease + HTTPRoute)
infrastructure/base/controllers/        cilium, csi-driver-smb HelmReleases
infrastructure/production/controllers/  overlays base + adds cilium Gateway/IPPool/HTTPRoutes
clusters/production/       Flux GitRepository (master via SSH) + 3 Kustomizations, .sops.yaml
```

## Verification Commands

### Ansible

```bash
ansible-playbook --syntax-check ansible/playbooks/*.yaml
ansible-lint --profile production -c ansible/playbooks/.ansible-lint.yml ansible/playbooks/*.yaml
```

- `-c` is required: the lint config lives in `ansible/playbooks/.ansible-lint.yml`, not the repo root.
- syntax-check passes (warns "no inventory parsed" — inventory is gitignored, so host groups `proxmox`/`autopatch`/`gpupassthrough` never resolve).
- **`ansible-lint` currently fails: 21 fatal violations, most/all in `start-proxmox-vm.yaml` and `shutdown-proxmox-vm.yaml`** (`fqcn[action-core]` from bare `command:`/`debug:`, plus `yaml[indentation]` and `yaml[new-line-at-end-of-file]`). This is the pre-existing baseline; don't attribute it to your change, and prefer fixing those files to FQCN if you touch them.
- Config skips: `yaml[line-length]`, `name[missing]`, `name[template]`, `no-changed-when`, `command-instead-of-shell`, `internal-error`.
- Use YAML `true`/`false` (production profile enforces `yaml[truthy]`).

### OpenTofu

```bash
tofu -chdir=terraform/<cluster> init -backend=false
tofu -chdir=terraform/<cluster> validate
```

- `tofu init` accepts **no positional directory**; `-chdir` is the only way. Keep `init` and `validate` using the same `-chdir` (a cwd mismatch yields "Module not installed").
- `terraform/azeroth` **cannot be initialized at all**: `cluster.tf` sources `../modules/proxmox`, which does not exist (`Unreadable module directory`).
- `northrend`, `tbc`, `test` init fine, but `validate` always fails at `private_key = file("~/.ssh/id_ed25519")` in `provider.tf` (no key in sandbox). No clean `tofu validate` is achievable here.
- Provider pins differ per cluster: azeroth `bpg/proxmox 0.90.0`, northrend `0.86.0`, tbc/test `0.98.1`; `tbc` also has `siderolabs/talos 0.10.1` and still defines Talos machine configs in `talos-cluster.tf`.
- Variable values come from gitignored `*.tfvars`; there is no `terraform/modules/` dir.

### checkov / trivy

```bash
cd terraform && checkov --config-file .checkov.yml --compact
trivy fs --scanners vuln,secret,misconfig .
```

- checkov **must run from `terraform/`** — the config's `directory:` entries are relative. It also logs `Error parsing file .../prod.tfvars`/`test.tfvars` because the `var-file` entries are gitignored; that noise is expected. `CKV_TF_1` failures are pre-existing (`?ref=0.1-rc` is a branch, not a commit hash).
- `trivy fs` is **not clean**: ~6 vulns and ~77 Kubernetes misconfig findings at repo root (e.g. `KSV-0040` missing ResourceQuota, HTTPRoute redirect rules). Use it for deltas, not a gate.

### SOPS

- Only config is `clusters/production/.sops.yaml` (there is none at repo root): `creation_rules` for `^(infrastructure|apps)/(production|base)/.*secret\.yaml$`, pgp `6B021152E518C20179D5558C51DE92958775C0C2`, `encrypted_regex: ^(data|stringData)$`.
- Encrypted files: `infrastructure/production/secrets/{smb-creds,wildcard-cert}.yaml` plus `apps/production/{harbor/harbor-admin-secret,harbor/harbor-postgres-secret,vaultwarden/postgres-secret,vaultwarden/pull-secret}.yaml`.
- **Outliers:** `apps/production/onedev/release.yaml` and `apps/production/vaultwarden/vaultwarden-admin-creds.yaml` are also encrypted but do **not** match that `path_regex`, so `sops updatekeys`/`rotate` run from `clusters/production` silently skips them.
- `sops decrypt` fails here (`gpg: decryption failed: No secret key`). Verify encryption by grepping for `ENC[AES256_GCM` and `^sops:`, not by decrypting.

## Cross-cutting Gotchas

- **Talos bootstrap Ansible does not exist on `master`.** `setup-talos-cluster.yaml`, `bootstrap-talos-baremetal.yaml`, and roles `bootstrap_talos`/`generate_talos_configs`/`apply_talos_configs`/`install_k8s_cluster`/`install_flux`/`install_cli_tools` live only on `feature/talos-deploy`. Don't reference them from `master`.
- Flux dependency chain (separate Kustomizations in `clusters/production/`): `infrastructure-secrets` (has `decryption: provider: sops`) → `infrastructure-controllers` → `infrastructure-storage-classes` (`dependsOn` controllers) → `apps` (also `decryption: provider: sops`). Adding a resource means matching the right `path:` and, for encrypted Secrets, the right `decryption` scope.
- Apps/infra Secrets are only decryptable in-cluster via the `sops-gpg` Secret in `flux-system`.
- Cilium serves Gateway API: gateway `kirintor-gateway` in `kube-system`, class `cilium`, TLS from secret `wildcard.kirintor.benjaminmnoer.dk-tls` (shipped by `infrastructure-secrets`); app HTTPRoutes attach to it.
- `update-system.yaml` reads inventory-only vars (`backup_vms`, `patch_vms`, `upgrade_strategy`, `upgrade_type`) and patches hypervisors `serial: 1`. `get-vm-status.yaml` reuses `patch_vms`. None of this is runnable without the gitignored inventory.
- Root `test` file is a 0-byte placeholder — there is no test suite; do not invent a test command.
