# Infrastructure as Code Repository

This repository manages the infrastructure for a personal homelab environment running Proxmox VE hypervisors with Kubernetes clusters managed by Talos Linux.

## Technology Stack

| Category | Technologies |
|----------|-------------|
| Hypervisors | Proxmox VE (Debian-based) |
| Container Orchestration | Kubernetes (Talos Linux) |
| GitOps | Flux CD v2.6.4 |
| IaC Tools | Terraform, Ansible |
| Secrets Management | SOPS with PGP encryption |
| State Management | Azure Blob Storage |
| Networking | Cilium CNI |
| Storage | TrueNAS SMB, CSI Driver SMB |

## Directory Structure

```
/iac
├── ansible/                  # Ansible automation playbooks
│   ├── ansible.cfg          # Ansible configuration
│   ├── inventory/           # Inventory files
│   │   ├── hosts.yaml      # Main host definitions
│   │   ├── production.yaml # Production environment
│   │   └── test.yaml       # Test environment
│   └── playbooks/           # Playbooks
│       ├── main.yaml        # Start Talos cluster VMs
│       ├── proxmox-setup.yaml
│       ├── update-system.yaml
│       └── enable-gpupassthrough.yaml
├── apps/                    # Kubernetes application manifests (Flux)
│   └── production/
│       ├── podinfo/
│       ├── onedev/
│       ├── harbor/
│       └── vaultwarden/
├── clusters/                # Cluster configurations
│   └── production/
│       ├── flux-system/     # Flux CD configuration
│       └── .sops.yaml       # SOPS encryption rules
├── infrastructure/          # Base infrastructure components
│   ├── base/controllers/
│   │   ├── cilium/          # CNI configuration
│   │   └── csi-driver-smb/  # SMB storage driver
│   └── production/
│       ├── controllers/
│       ├── secrets/
│       └── storage-classes/
└── terraform/              # Terraform configurations
    ├── azeroth/             # Main production environment
    ├── tbc/                 # Talos cluster
    ├── northrend/           # GPU passthrough
    └── test/                # Test environment
```

## Common Tasks

### Terraform Operations

```bash
# Initialize Terraform (each module directory)
cd terraform/tbc && terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Target specific resources
terraform apply -target=module.proxmox
```

### Ansible Operations

```bash
# Apply Proxmox post-install setup
ansible-playbook -i ansible/inventory/production.yaml ansible/playbooks/proxmox-setup.yaml

# Update systems (multi-stage)
ansible-playbook -i ansible/inventory/production.yaml ansible/playbooks/update-system.yaml

# Start Talos cluster VMs
ansible-playbook -i ansible/inventory/hosts.yaml ansible/playbooks/main.yaml

# Enable GPU passthrough
ansible-playbook -i ansible/inventory/production.yaml ansible/playbooks/enable-gpupassthrough.yaml
```

### Flux/GitOps

Flux automatically syncs from this Git repository. Changes pushed to `master` are automatically deployed.

To trigger a manual sync:
```bash
flux reconcile source git flux-system
flux reconcile kustomization production --with-source
```

## Secrets Management

Secrets are encrypted with SOPS using PGP. To decrypt/edit:

```bash
# Install SOPS if needed
export GPG_TTY=$(tty)
sops <file>.yaml  # Opens editor for encrypted file
```

## Environment Details

### Proxmox Nodes
- `outland` (192.168.100.2) - Intel
- `northrend` (192.168.100.3) - AMD (GPU passthrough)
- `azeroth` (192.168.100.4) - Intel (main controller)
- `kalimdor` (192.168.100.5) - Intel
- `easternkingdoms` (192.168.100.6) - Intel

### Domains
- Main: `benjaminmnoer.dk`
- Internal: `kirintor.benjaminmnoer.dk`

## Conventions

- Resources tagged with `["terraform", "type", "description"]`
- Host naming inspired by Warcraft universe
- Environment separation via `production/` and `test/` directories
- Flux Kustomization depends order: `infrastructure.yaml` → `apps.yaml`
