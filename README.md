# Homelab IaC

A homelab based on **Proxmox**, **OpenTofu**, **Ansible**, **Talos Linux**, **Cilium** and **Flux**.



## Overview

**IaC** is a repository for managing my heterogenous homelab. It handles everything from provisioning and configuring virtual machine nodes to automating application deployments and managing backups.

This project started as a migration from a simple Unraid server with a few VMs and docker containers. The end goal is a more modern and mature infrastructure for various services, from common homelab services (Vaultwarden, version control server etc.) to game servers and development projects.

At the same time, this is also a place to try out features not commonly used in my line of work. So this is a learning/play-ground as well.


## Core stack

| Layer                | Tooling                                                      |
| ---------------------| -------------------------------------------------------------|
| Virtualization       | [Proxmox VE](https://www.proxmox.com/en/)                    |
| Provisioning         | [Opentofu](https://opentofu.org/)                            |
| Configuration        | [Ansible](https://www.ansible.com/)                          |
| Kubernetes           | [Talos Linux](https://talos.dev/)                            |
| GitOps               | [Flux](https://fluxcd.io/)                                   |
| Secrets Management   | [SOPS](https://github.com/mozilla/sops)                      |
| Gateway API          | [Cilium](https://cilium.io/get-started/)                     |
| Storage Management   | [TrueNAS](https://www.truenas.com/)                          |
| Observability        | TBD                                                          |

## Goals

- Moving from a single Unraid server to multiple Proxmox hosts, serving various roles
- Automate everything from bare metal provisioning to app deployment
- Maintain a declarative, self-healing, and idempotent system
- Learn and implement best practices around GitOps, CI/CD, Kubernetes, and infrastructure automation

## Current Status

> "Under active development. Do **not** trust anything."

- [ ] Proxmox environment running
- [ ] Tofu/Ansible bootstrapping complete
- [ ] Talos cluster deployed
- [ ] Flux desired state deployments
- [ ] Setup observability/monitoring

## Repository Structure

```
IaC/
├── ansible/         # Playbooks performing various common activities, e.g. updating system, bootstrapping Talos.
├── apps/            # Application definitions.
├── clusters/        # Cluster resources (Flux, sops, etc.)
├── infrastructure/  # Kubernetes cluster infrastructure code
├── terraform/       # Infrastructure provisioning
└── README.md
```

## Development Workflow
### Ansible Playbooks
1. **Edit**: Modify playbooks in `ansible/playbooks/`
2. **Validate**: `ansible-playbook --syntax-check` + `ansible-lint`
3. **Apply**: `ansible-playbook -i ansible/production/inventory.yaml <playbook.yaml>`
### OpenTofu Configuration
1. **Edit**: Modify configs in `terraform/<cluster>/`
2. **Validate**: `tofu init && tofu validate`
3. **Plan**: `tofu plan` (shows pending changes)
4. **Apply**: `tofu apply`
### Flux Configuration (GitOps)
1. **Edit**: Modify YAML in `clusters/production/`, `apps/production/`, `infrastructure/production/`
2. **Validate**: `kubectl kustomize --dry-run=client`
3. **Apply**: Push to git - Flux automatically reconciles cluster
4. **Force sync**: `flux reconcile source git flux-system`