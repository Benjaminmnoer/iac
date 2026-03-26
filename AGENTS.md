# Agent Guidelines for IaC Repository

## Build/Lint/Test Commands

### Terraform
```bash
# Format Terraform files
terraform fmt -recursive terraform/

# Validate Terraform configuration
terraform -chdir=terraform/<folder> validate

# Plan changes (dry run)
terraform -chdir=terraform/<folder> plan

# Run in test environment first, then apply to production
terraform -chdir=terraform/test validate
```

Available environments: `azeroth`, `northrend`, `proxmox`, `talos`, `tbc`, `test`

### Terratest (Validation Tests)
```bash
# Run all validation tests
cd tests && go test -v ./...

# Run specific environment
cd tests && go test -v -run TestTBC ./...

# Run init & validate only (no plan)
cd tests && go test -v -run "InitAndValidate" ./...
```

### Ansible
```bash
# Check Ansible syntax
ansible-playbook --syntax-check ansible/playbooks/main.yaml

# List hosts without executing
ansible-playbook -i ansible/inventory.yaml ansible/playbooks/main.yaml --list-hosts
```

---

## Terraform Conventions

### Provider Setup
- Pin provider versions in `provider.tf`
- Use AzureRM backend for state storage
- SSH agent forwarding for Proxmox access: `agent = true`
- `insecure = true` and `min_tls = "1.2"` for Proxmox provider

### File Organization
- `provider.tf` - Terraform and provider configuration
- `cluster.tf` - Module calls and cluster-wide resources
- `variables.tf` - All variable definitions with section headers
- `<resource-type>.tf` - Individual resource definitions

### Section Headers
Use section comments in `variables.tf`:
```hcl
#################### PROXMOX ####################
#################### TALOS ####################
```

### Resource Naming
- VM resources: Use descriptive hostnames (e.g., `antonidas`, `jaina`, `khadgar`)
- Firewall resources: Suffix with `_fw` or `_fw_options`
- Storage resources: Use descriptive IDs (e.g., `stormwind-tbc`)

### Tags
Always include these tags on VM resources:
```hcl
tags = ["terraform", "talos", "controlplane"]  # or "worker"
```

### Descriptions
- All resources must have a `description` field: `"Managed by Terraform."`
- Variables must have `description` attribute
- Firewall rules must have `comment` attribute

### Dependencies
- Use explicit `depends_on` for firewall rules depending on VMs
- Resources creating infrastructure should depend on module that sets up base

---

## Ansible Conventions

### YAML Format
- Always use `---` document start marker
- Use FQCN (Fully Qualified Collection Names):
  ```yaml
  ansible.builtin.apt
  ansible.builtin.get_url
  kubernetes.core.helm
  ```

### Task Organization
- Use roles for reusable task sets
- Use `import_tasks` for static imports, `include_tasks` for dynamic
- Use `loop:` for iterating over items

### Privilege Escalation
- Use `become: true` only when needed
- Use `become_user:` for specific privilege requirements

---

## Kubernetes/Flux Conventions

### Cluster Structure
- `clusters/<env>/` - Cluster-specific configuration
- `apps/<env>/` - Application manifests
- Use Kustomization for composition

### Secrets Management
- Never commit plain secrets to Git
- Use SOPS with GPG for secrets encryption
- Flux manages secret decryption via SOPS

---

## General Guidelines

1. **Test in `terraform/test/` first** before applying to production
2. **Review Terraform plans carefully** before applying
3. **Use descriptive names** over abbreviations
4. **No inline comments** unless explaining non-obvious configuration
5. **Sensitive outputs** should be marked `sensitive = true`
6. **VM names** should be fully qualified: `name.benjaminmnoer.dk`
