resource "proxmox_virtual_environment_download_file" "truenas-iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "azeroth"
  url          = "https://download.sys.truenas.net/TrueNAS-SCALE-Fangtooth/25.04.2.4/TrueNAS-SCALE-25.04.2.4.iso"
}

resource "proxmox_virtual_environment_vm" "stormwind" {
  name        = "stormwind"
  description = "TrueNAS. Managed by Terraform."
  tags        = ["terraform", "debian", "truenas"]
  node_name   = "azeroth"
  on_boot     = true

  startup {
    order    = 1
    up_delay = 300
  }

  bios       = "ovmf"
  boot_order = ["scsi0"]
  machine    = "q35"

  efi_disk {
    datastore_id      = "local-zfs"
    type              = "4m"
    pre_enrolled_keys = true
  }

  cpu {
    cores = 4
    type  = "host"
    units = 1024
  }

  memory {
    dedicated = 32768
  }

  agent {
    enabled = true
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 110
  }

  disk {
    datastore_id = "local-zfs"
    file_format  = "raw"
    interface    = "scsi0"
    size         = 100
  }

  operating_system {
    type = "l26"
  }

  hostpci {
    device = "hostpci0"
    id     = "0000:01:00"
    rombar = true
    pcie   = true
  }

  hostpci {
    device = "hostpci1"
    id     = "0000:02:00"
    rombar = true
    pcie   = true
  }

  hostpci {
    device = "hostpci2"
    id     = "0000:03:00"
    rombar = true
    pcie   = true
  }
}

resource "proxmox_virtual_environment_firewall_options" "stormwind" {
  node_name = proxmox_virtual_environment_vm.stormwind.node_name
  vm_id     = proxmox_virtual_environment_vm.stormwind.vm_id

  dhcp          = false
  enabled       = true
  ipfilter      = true
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = false
  ndp           = true
  input_policy  = "REJECT"
  output_policy = "ACCEPT"
  radv          = true
}

resource "proxmox_virtual_environment_firewall_ipset" "smb_clients" {
  name    = "smb_clients"
  comment = "Managed by Terraform"

  dynamic "cidr" {
    for_each = var.smb_clients
    content {
      name    = cidr.value.ip
      comment = cidr.value.comment
    }

  }
}

resource "proxmox_virtual_environment_firewall_rules" "stormwind" {
  node_name = proxmox_virtual_environment_vm.stormwind.node_name
  vm_id     = proxmox_virtual_environment_vm.stormwind.id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTPS"
    source  = "+${proxmox_virtual_environment_firewall_ipset.trusted_clients.name}"
    dest    = var.stormwind_ip
    macro   = "HTTPS"
    log     = "nolog"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow SMB"
    source  = "+${proxmox_virtual_environment_firewall_ipset.smb_clients.name}"
    dest    = var.stormwind_ip
    macro   = "SMB"
    log     = "nolog"
  }
}
