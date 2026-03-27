# Homelab Infrastructure as Code

This repository holds the Infrastructure as Code configuration for my personal homelab. It consists mainly of Proxmox VE hypervisors, which are used to host a TrueNAS VM for storage and a Talos Linux k8s cluster for the main compute operations.

The goal of this repository is to learn new skills and test things generally not available other places. 

## Quick Start
1. Spin up jumphost
2. Ensure connectivity and credentials to proxmox hosts
3. Create Azure storage for backend
4. In each terraform subfolder
```
tofu init
tofu apply
```
5. Run ansible playbook deploy-talos-cluster.yaml

### Prerequisites

- [OpenTofu](https://opentofu.org/)
- [Ansible](https://docs.ansible.com/)

### Initial Setup

1. Clone the repository:
   ```bash
   git clone ssh://git@github.com/benjaminmnoer/iac.git
   cd iac
   ```

2. Configure OpenTofu backend (Azure Blob Storage credentials)

3. Initialize Terraform:
   ```bash
   cd terraform/tbc
   tofu init
   ```

4. Run Ansible playbooks for initial host configuration:
   ```bash
   ansible-playbook -i ansible/inventory/production.yaml ansible/deploy-talos-cluster.yaml
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
| IaC | OpenTofu | Infrastructure provisioning |
| Kubernetes | Talos Linux | Container orchestration |
| GitOps | Flux CD | Git-based deployments |
| Storage | TrueNAS SMB share | Storage management (ZFS) |
| Networking (k8s) | Cilium | CNI plugin with Gateway API |
| Secrets | SOPS | Encrypted secrets management |

## Available Applications

- **Harbor** - Container registry
- **Vaultwarden** - Password manager
- **OneDev** - CI/CD platform
- **Podinfo** - Debug/testing utility

## Common Operations

### Update infrastructure components

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

## License

MIT
