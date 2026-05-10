resource "proxmox_download_file" "this" {
  count = var.download_file_url != "" ? 1 : 0

  content_type       = "iso"
  datastore_id       = var.download_datastore_id
  node_name          = var.node_name
  url                = var.download_file_url
  checksum           = var.download_file_checksum
  checksum_algorithm = var.download_file_checksum_algorithm
}

resource "proxmox_virtual_environment_vm" "this" {
  name        = var.name
  description = var.description
  tags        = var.tags
  node_name   = var.node_name
  on_boot     = var.on_boot

  bios       = var.bios
  machine    = var.machine
  boot_order = var.boot_order

  cpu {
    type  = var.cpu_type
    cores = var.cores
    units = var.cpu_units
  }

  memory {
    dedicated = var.memory
  }

  agent {
    enabled = var.agent_enabled
  }

  network_device {
    bridge   = var.bridge
    vlan_id  = var.vlan_id != 0 ? var.vlan_id : null
    firewall = var.firewall
  }

  efi_disk {
    datastore_id      = var.efi_datastore_id
    type              = var.efi_type
    pre_enrolled_keys = var.efi_pre_enrolled_keys
  }

  dynamic "disk" {
    for_each = var.disk_file_id != "" ? [1] : []
    content {
      datastore_id = var.datastore_id
      interface    = var.disk_interface
      size         = var.disk_size
      file_id      = var.disk_file_id != "" ? var.disk_file_id : (length(proxmox_download_file.this) > 0 ? proxmox_download_file.this[0].id : "")
      file_format  = var.disk_file_format
    }
  }

  dynamic "disk" {
    for_each = var.disk_file_id == "" && var.disk_size > 0 ? [1] : []
    content {
      datastore_id = var.datastore_id
      interface    = var.disk_interface
      size         = var.disk_size
    }
  }

  operating_system {
    type = var.os_type
  }

  dynamic "initialization" {
    for_each = var.ip_address != "" ? [1] : []
    content {
      datastore_id = var.datastore_id

      ip_config {
        ipv4 {
          address = var.ip_address
          gateway = var.ip_gateway
        }
      }

      user_account {
        keys = var.user_ssh_keys
      }

      dynamic "dns" {
        for_each = var.dns_domain != "" ? [1] : []
        content {
          domain  = var.dns_domain
          servers = var.dns_servers
        }
      }
    }
  }

  dynamic "usb" {
    for_each = var.usb_host != "" ? [1] : []
    content {
      host = var.usb_host
      usb3 = var.usb3
    }
  }

  dynamic "tpm_state" {
    for_each = var.tpm_enabled ? [1] : []
    content {
      version      = var.tpm_version
      datastore_id = var.efi_datastore_id
    }
  }
}

resource "proxmox_virtual_environment_firewall_options" "this" {
  depends_on = [proxmox_virtual_environment_vm.this]

  node_name = var.node_name
  vm_id     = proxmox_virtual_environment_vm.this.vm_id

  enabled       = var.firewall_options.enabled
  input_policy  = var.firewall_options.input_policy
  output_policy = "ACCEPT"
  dhcp          = var.ip_address == "dhcp" || var.ip_address == ""
  ipfilter      = true
  ndp           = true
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = false
}

resource "proxmox_virtual_environment_firewall_rules" "this" {
  depends_on = [proxmox_virtual_environment_firewall_options.this]

  node_name = var.node_name
  vm_id     = proxmox_virtual_environment_vm.this.vm_id

  dynamic "rule" {
    for_each = var.firewall_options.rules
    content {
      type    = rule.value.type
      action  = rule.value.action
      comment = rule.value.comment
      source  = rule.value.source
      macro   = rule.value.macro
      dport   = rule.value.dport
      proto   = rule.value.proto
      log     = rule.value.log
    }
  }
}
