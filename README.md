# Homelab Infrastructure as Code

This repository contains the Infrastructure as Code (IaC) configuration for a personal homelab environment. It manages Proxmox VE hypervisors, Kubernetes clusters running Talos Linux, and various containerized applications.

## Architecture Overview

```
┌────────────────────────────────────────────────────────────────┐
│                        Proxmox VE Cluster                      │
├──────────┬──────────┬──────────┬──────────┬────────────────────┤
│ outland  │ northrend│ azeroth  │ kalimdor │ eastern kingdoms   │
│ (Intel)  │ (AMD/GPU)│ (Intel)  │ (Intel)  │ (Intel)            │
└────┬─────┴────┬─────┴────┬─────┴──────────┴────────────────────┘
     │          │
     ▼          ▼
┌─────────────────────────────────────┐
│      Kubernetes Cluster (Talos)     │
│  ┌─────────┐ ┌──────────────────┐   │
│  │ Cilium  │ │ CSI Driver SMB   │   │
│  └─────────┘ └──────────────────┘   │
│  ┌─────────┐ ┌──────────────────┐   │
│  │ Harbor  │ │ Podinfo/OneDev   │   │
│  └─────────┘ └──────────────────┘   │
└─────────────────────────────────────┘
```

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 2.10
- [SOPS](https://github.com/mozilla/sops/releases) for secrets management
- PGP key configured for secrets encryption
- SSH access to Proxmox nodes

### Initial Setup

1. Clone the repository:
   ```bash
   git clone ssh://git@github.com/benjaminmnoer/iac.git
   cd iac
   ```

2. Configure Terraform backend (Azure Blob Storage credentials)

3. Initialize Terraform:
   ```bash
   cd terraform/tbc
   terraform init
   ```

4. Run Ansible playbooks for initial host configuration:
   ```bash
   ansible-playbook -i ansible/inventory/production.yaml ansible/playbooks/proxmox-setup.yaml
   ```

## Repository Structure

| Directory | Description |
|-----------|-------------|
| `ansible/` | Ansible playbooks for host configuration and automation |
| `apps/` | Kubernetes application manifests (Harbor, Vaultwarden, OneDev, Podinfo) |
| `clusters/` | Flux CD system configuration and Kustomizations |
| `infrastructure/` | Base infrastructure components (Cilium, CSI drivers) |
| `terraform/` | Terraform modules for VM and cluster provisioning |

## Key Technologies

| Component | Technology | Purpose |
|-----------|------------|---------|
| Hypervisor | Proxmox VE | VM orchestration |
| Kubernetes | Talos Linux | Container orchestration |
| GitOps | Flux CD | Git-based deployments |
| Networking | Cilium | CNI plugin with Gateway API |
| Storage | CSI Driver SMB | SMB share provisioning |
| Secrets | SOPS | Encrypted secrets management |
| IaC | Terraform | Infrastructure provisioning |

## Available Applications

- **Harbor** - Container registry
- **Vaultwarden** - Password manager
- **OneDev** - CI/CD platform
- **Podinfo** - Debug/testing utility

## Common Operations

### Deploy Infrastructure Changes

```bash
# Terraform
cd terraform/tbc
terraform plan
terraform apply

# Ansible
ansible-playbook -i ansible/inventory/production.yaml ansible/playbooks/update-system.yaml
```

### Sync Flux Resources

Flux automatically syncs changes from the `master` branch. For manual reconciliation:

```bash
flux reconcile source git flux-system
flux reconcile kustomization production --with-source
```

### Update Secrets

```bash
export GPG_TTY=$(tty)
sops clusters/production/secrets/<file>.yaml
```

## Contributing

1. Create a feature branch from `master`
2. Make changes and test in `test/` environment
3. Submit a pull request to `master`
4. Flux will automatically deploy changes

## License

MIT
