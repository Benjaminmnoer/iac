resource "proxmox_download_file" "this" {
  count = var.download_file_url != "" ? 1 : 0

  content_type       = "vztmpl"
  datastore_id       = var.download_datastore_id
  node_name          = var.node_name
  url                = var.download_file_url
  checksum           = var.download_file_checksum
  checksum_algorithm = var.download_file_checksum_algorithm
}

resource "proxmox_virtual_environment_container" "this" {
  description = var.description
  node_name   = var.node_name

  initialization {
    hostname = var.name

    ip_config {
      ipv4 {
        address = "dhcp" # Assuming DHCP and reserving IPs in DHCP server.
      }
    }

    user_account {
      keys = var.user_ssh_keys
    }
  }

  cpu {
    cores = var.cores
  }

  memory {
    dedicated = var.memory
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  network_interface {
    name    = "eth0"
    bridge  = var.bridge
    vlan_id = var.vlan_id
  }

  operating_system {
    template_file_id = var.template_file_id != "" ? var.template_file_id : (length(proxmox_download_file.this) > 0 ? proxmox_download_file.this[0].id : "")
    type             = var.os_type
  }

  unprivileged = var.unprivileged
}

resource "proxmox_virtual_environment_firewall_options" "this" {
  depends_on = [proxmox_virtual_environment_container.this]

  node_name = var.node_name
  vm_id     = proxmox_virtual_environment_container.this.vm_id

  enabled       = var.firewall.enabled
  input_policy  = var.firewall.input_policy
  output_policy = var.firewall.output_policy
  dhcp          = var.ip_address == "dhcp"
  ipfilter      = true
  ndp           = true
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = false
}

resource "proxmox_virtual_environment_firewall_rules" "this" {
  depends_on = [proxmox_virtual_environment_firewall_options.this]

  node_name = var.node_name
  vm_id     = proxmox_virtual_environment_container.this.vm_id


  dynamic "rule" {
    for_each = var.firewall.rules
    content {
      type    = rule.value.type
      action  = rule.value.action
      comment = rule.value.comment
      source  = rule.value.source
      macro   = rule.value.macro
      dport   = rule.value.dport
      proto   = rule.value.proto  
    }
  }
}