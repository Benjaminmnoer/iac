resource "proxmox_virtual_environment_download_file" "archlinux_base" {
  content_type       = "vztmpl"
  datastore_id       = "local"
  node_name          = "northrend"
  url                = "http://download.proxmox.com/images/system/archlinux-base_20240911-1_amd64.tar.zst"
  checksum           = "05b36399c801b774d9540ddbae6be6fc26803bc161e7888722f8f36c48569010e12392c6741bf263336b8542c59f18f67cf4f311d52b3b8dd58640efca765b85"
  checksum_algorithm = "sha512"
}

resource "proxmox_virtual_environment_container" "portal" {
  description = "Arch Linux jump host. Managed by Terraform"
  node_name   = "northrend"

  initialization {
    hostname = "portal"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFoD5D17uiVWei7OuHjo4P98yMfjP6vrLPcG3MgGLEu benjaminmnoer25@gmail.com",
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE1+kKAtU2AoIjCAONKuc+ABm5HpPmO1s3Z5P6J7l9zD benjaminmnoer25@gmail.com"
      ]
    }
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 8192
  }

  disk {
    datastore_id = "local-zfs"
    size         = 20
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr0"
    vlan_id = 110
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.archlinux_base.id
    type             = "archlinux"
  }

  unprivileged = true
}

resource "proxmox_virtual_environment_firewall_options" "portal" {
  depends_on = [proxmox_virtual_environment_container.portal]

  node_name = "northrend"
  vm_id     = proxmox_virtual_environment_container.portal.vm_id

  dhcp          = true
  enabled       = true
  ipfilter      = false
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = false
  ndp           = true
  input_policy  = "REJECT"
  output_policy = "ACCEPT"
}

resource "proxmox_virtual_environment_firewall_rules" "portal" {
  depends_on = [proxmox_virtual_environment_firewall_options.portal]

  node_name = "northrend"
  vm_id     = proxmox_virtual_environment_container.portal.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow SSH"
    source = "+management"
    macro   = "SSH"
    log     = "info"
  }
}