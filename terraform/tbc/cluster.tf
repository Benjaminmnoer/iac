module "proxmox" {
  source           = "git::https://github.com/Benjaminmnoer/proxmox-terraform-module.git?ref=0.1-rc"
  cloudflare_token = var.cf_token
  management_ipset = var.management_ipset
  firewall_aliases = {
    "${var.talos_jumphost.alias}" = var.talos_jumphost
    "${var.talos_loadbalancer.alias}" = var.talos_loadbalancer
  }
  firewall_enabled = true
}

resource "proxmox_virtual_environment_storage_cifs" "stormwind_tbc" {
  id     = "stormwind-tbc"
  nodes  = [for k, v in var.cluster_nodes : k]
  server = "stormwind.benjaminmnoer.dk"
  share  = "tbc"

  username = "tbc-user"
  password = var.cifs_password

  content = ["rootdir", "vztmpl"]
  # domain                   = "WORKGROUP"
  # subdirectory             = "/ha/"
  preallocation            = "metadata"
  snapshot_as_volume_chain = true
}

resource "proxmox_virtual_environment_firewall_ipset" "talos_nodes" {
  name       = "talos_nodes"
  depends_on = [module.proxmox]

  dynamic "cidr" {
    for_each = merge(var.talos_controlplane_nodes, var.talos_worker_nodes)
    content {
      name    = cidr.value.ip
      comment = cidr.key
    }
  }
}

resource "proxmox_virtual_environment_firewall_ipset" "talos_clients" {
  name       = "talos_clients"
  depends_on = [module.proxmox]

  cidr {
    name = "dc/${var.talos_jumphost.alias}"
  }

  cidr {
    name = "dc/${var.talos_loadbalancer.alias}"
  }
}