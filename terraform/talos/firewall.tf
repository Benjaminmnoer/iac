resource "proxmox_virtual_environment_firewall_ipset" "talos" {
  name       = "talos"
  comment    = "Managed by Terraform"

  cidr {
    name    = var.antonidas_ip
    comment = "antonidas"
  }

  cidr {
    name    = var.jaina_ip
    comment = "jaina"
  }

  cidr {
    name    = var.khadgar_ip
    comment = "khadgar"
  }

  # cidr {
  #   name    = var.rhonin_ip
  #   comment = "rhonin"
  # }
}

resource "proxmox_virtual_environment_cluster_firewall_security_group" "talos" {
  name    = "talos"
  comment = "Managed by Terraform"

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow 6443"
    dport   = "6443"
    dest    = "+${proxmox_virtual_environment_firewall_ipset.talos.name}"
    proto   = "tcp"
    log     = "info"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow 50000"
    dport   = "50000"
    dest    = "+${proxmox_virtual_environment_firewall_ipset.talos.name}" # Only controlplane nodes?
    proto   = "tcp"
    log     = "info"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "jaina" {
  depends_on = [
    proxmox_virtual_environment_cluster_firewall_security_group.talos,
    proxmox_virtual_environment_vm.jaina
  ]

  node_name = proxmox_virtual_environment_vm.jaina.node_name
  vm_id     = proxmox_virtual_environment_vm.jaina.id

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.talos.name
    comment        = "From security group. Managed by Terraform"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "khadgar" {
  depends_on = [
    proxmox_virtual_environment_cluster_firewall_security_group.talos,
    proxmox_virtual_environment_vm.khadgar
  ]

  node_name = proxmox_virtual_environment_vm.khadgar.node_name
  vm_id     = proxmox_virtual_environment_vm.khadgar.id

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.talos.name
    comment        = "From security group. Managed by Terraform"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "antonidas" {
  depends_on = [
    proxmox_virtual_environment_cluster_firewall_security_group.talos,
    proxmox_virtual_environment_vm.antonidas
  ]

  node_name = proxmox_virtual_environment_vm.antonidas.node_name
  vm_id     = proxmox_virtual_environment_vm.antonidas.id

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.talos.name
    comment        = "From security group. Managed by Terraform"
  }
}

# resource "proxmox_virtual_environment_firewall_rules" "rhonin" {
#   depends_on = [
#     proxmox_virtual_environment_cluster_firewall_security_group.talos,
#     proxmox_virtual_environment_vm.rhonin
#   ]

#   node_name = proxmox_virtual_environment_vm.rhonin.node_name
#   vm_id     = proxmox_virtual_environment_vm.rhonin.id

#   rule {
#     security_group = proxmox_virtual_environment_cluster_firewall_security_group.talos.name
#     comment        = "From security group. Managed by Terraform"
#   }
# }
