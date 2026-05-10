# Homelab IaC

A homelab based on **Bare Metal**, **OpenTofu**, **Ansible**, **Talos Linux**, **Cilium** and **Flux**.



## Overview

**IaC** is a repository for managing my heterogenous homelab. It handles everything from provisioning and configuring virtual machine nodes to automating application deployments and managing backups.

This project started as a migration from a simple Unraid server with a few VMs and docker containers. The end goal is a more modern and mature infrastructure for various services, from common homelab services (Vaultwarden, version control server etc.) to game servers and development projects.

At the same time, this is also a place to try out features not commonly used in my line of work. So this is a learning/play-ground as well.


## Core stack

| Layer                | Tooling                                                      |
| ---------------------| -------------------------------------------------------------|
| Provisioning         | [Opentofu](https://opentofu.org/)                            |
| Configuration        | [Ansible](https://www.ansible.com/)                          |
| Kubernetes           | [Talos Linux](https://talos.dev/) (Bare Metal)               |
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

- [x] Proxmox environment running
- [x] Ansible bootstrapping for bare metal Talos complete
- [x] Bootstrap playbook restructured (tools → configs → apply → bootstrap)
- [x] CNI/Flux deployment separated into dedicated playbook
- [ ] Talos cluster deployed (bare metal)
- [ ] Flux desired state deployments
- [ ] Setup observability/monitoring

## Repository Structure

```
IaC/
├── ansible/         # Playbooks performing various common activities, e.g. updating system, bootstrapping Talos.
│   ├── playbooks/   # Ansible playbooks and roles
│   │   ├── bootstrap-talos-baremetal.yaml  # Bootstrap Talos cluster (tools, configs, apply, bootstrap)
│   │   ├── deploy-talos-services.yaml      # Deploy CNI, Gateway API, and Flux to cluster
│   │   └── roles/                          # Ansible roles
│   └── production/  # Inventory files
├── apps/            # Application definitions.
├── clusters/        # Cluster resources (Flux, sops, etc.)
├── infrastructure/  # Kubernetes cluster infrastructure code
├── terraform/       # Infrastructure provisioning (Proxmox VMs, TrueNAS, etc.)
└── README.md
```

## Testing
You can execute these tests using the following commands:
### Terraform/OpenTofu Tests
Run tofu validate directly from any cluster directory after initializing with tofu init. 
For security scanning, trivy is installed in dev container and can be executed on jumphost.
For infrastructure validation, run checkov -d terraform/ using terraform/.checkov.yml for custom settings.

### Ansible Tests
Run syntax validation with ansible-playbook --syntax-check ansible/playbooks/*.yaml. 
Execute ansible-lint with ansible-lint ansible/playbooks/*.yaml from the playbooks directory.