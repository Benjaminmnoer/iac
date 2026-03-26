resource "proxmox_virtual_environment_download_file" "archlinux_base" {
  content_type       = "vztmpl"
  datastore_id       = proxmox_virtual_environment_storage_cifs.stormwind_tbc.id
  node_name          = keys(var.cluster_nodes)[0]
  url                = "http://download.proxmox.com/images/system/archlinux-base_20240911-1_amd64.tar.zst"
  checksum           = "05b36399c801b774d9540ddbae6be6fc26803bc161e7888722f8f36c48569010e12392c6741bf263336b8542c59f18f67cf4f311d52b3b8dd58640efca765b85"
  checksum_algorithm = "sha512"
}

resource "proxmox_virtual_environment_container" "tbc_nginx" {
  description = "Managed by Terraform"

  node_name = keys(var.cluster_nodes)[0]

  unprivileged  = true
  start_on_boot = true
  features {
    nesting = true
  }

  initialization {
    hostname = "tbc-nginx.benjaminmnoer.dk"
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
      password = random_password.tbc_nginx.result
    }
  }

  network_interface {
    name     = "eth0"
    bridge   = "vmbr0"
    vlan_id  = "110"
    firewall = true
  }

  cpu {
    architecture = "amd64"
    cores        = 1
  }

  memory {
    dedicated = "1024"
    swap      = "512"
  }

  disk {
    datastore_id = proxmox_virtual_environment_storage_cifs.stormwind_tbc.id
    size         = 4
  }

  operating_system {
    template_file_id = proxmox_virtual_environment_download_file.archlinux_base.id
    type             = "archlinux"
  }

  startup {
    order      = "2"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "random_password" "tbc_nginx" {
  length           = 16
  override_special = "!?"
  special          = true
}

resource "proxmox_virtual_environment_firewall_options" "tbc_nginx" {
  depends_on = [proxmox_virtual_environment_container.tbc_nginx]

  node_name    = proxmox_virtual_environment_container.tbc_nginx.node_name
  container_id = proxmox_virtual_environment_container.tbc_nginx.id

  enabled       = true
  dhcp          = false
  ipfilter      = true
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = false
  ndp           = true
  input_policy  = "REJECT"
  output_policy = "ACCEPT"
  radv          = true
}

resource "proxmox_virtual_environment_firewall_rules" "tbc_nginx" {
  depends_on = [
    proxmox_virtual_environment_container.tbc_nginx,
    proxmox_virtual_environment_firewall_options.tbc_nginx
  ]

  node_name    = proxmox_virtual_environment_container.tbc_nginx.node_name
  container_id = proxmox_virtual_environment_container.tbc_nginx.id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow SSH"
    source  = "+management"
    dport   = "22"
    proto   = "tcp"
    log     = "info"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTPS"
    source  = "+management"
    dport   = "443"
    proto   = "tcp"
    log     = "info"
  }

  # Talos control plane API
  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow TCP 6443"
    source  = "+management"
    dport   = "6443"
    proto   = "tcp"
    log     = "info"
  }
}

resource "proxmox_virtual_environment_haresource" "tbc_nginx" {
  depends_on = [
    proxmox_virtual_environment_container.tbc_nginx
  ]
  resource_id  = "ct:${proxmox_virtual_environment_container.tbc_nginx.vm_id}"
  state        = "started"
  comment      = "Managed by Terraform"
  max_relocate = 2
  max_restart  = 3
}

output "tbc_nginx_password" {
  value       = random_password.tbc_nginx.result
  description = "The password for the tbc-nginx container user account"
  sensitive = true
}