

resource "proxmox_virtual_environment_container" "jump" {
  description = "Arch Linux jump host. Managed by Terraform"
  node_name   = "northrend"

  initialization {
    hostname = "jump"

    ip_config {
      ipv4 {
        address = var.jump_ip
        gateway = "10.0.10.1"
      }
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local-zfs"
    size         = 8
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr0"
    vlan_id = 10
  }

  operating_system {
    type = "archlinux"
  }

  unprivileged = true
}

resource "proxmox_virtual_environment_firewall_options" "jump" {
  depends_on = [proxmox_virtual_environment_container.jump]

  node_name = "northrend"
  vm_id     = proxmox_virtual_environment_container.jump.vm_id

  dhcp          = false
  enabled       = true
  ipfilter      = false
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = false
  ndp           = true
  input_policy  = "REJECT"
  output_policy = "ACCEPT"
}

resource "proxmox_virtual_environment_firewall_rules" "jump" {
  depends_on = [proxmox_virtual_environment_firewall_options.jump]

  node_name = "northrend"
  vm_id     = proxmox_virtual_environment_container.jump.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow SSH"
    macro   = "SSH"
    log     = "info"
  }
}

resource "proxmox_virtual_environment_container" "jump_services" {
  description = "Arch Linux services LXC (Docker host). Managed by Terraform"
  node_name   = "northrend"

  initialization {
    hostname = "jump-svc"

    ip_config {
      ipv4 {
        address = var.jump_services_ip
        gateway = "10.0.10.1"
      }
    }
  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-zfs"
    size         = 32
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr0"
    vlan_id = 10
  }

  operating_system {
    type = "archlinux"
  }

  unprivileged = true

  mount_point {
    volume = "local-zfs:subvol"
    path   = "/var/lib/docker"
  }
}

resource "proxmox_virtual_environment_firewall_options" "jump_services" {
  depends_on = [proxmox_virtual_environment_container.jump_services]

  node_name = "northrend"
  vm_id     = proxmox_virtual_environment_container.jump_services.vm_id

  dhcp          = false
  enabled       = true
  ipfilter      = false
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = false
  ndp           = true
  input_policy  = "REJECT"
  output_policy = "ACCEPT"
}