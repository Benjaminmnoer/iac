resource "proxmox_virtual_environment_file" "haos_disk_file" {
  content_type = "import"
  datastore_id = "local"
  node_name    = "azeroth"

  source_file {
    path = "./haos_ova-17.0.qcow2"
  }
}

resource "proxmox_virtual_environment_vm" "haos" {
  name        = "haos"
  description = "Home assistant. Managed by Terraform."
  tags        = ["terraform", "debian", "haos"]
  node_name   = "azeroth"
  on_boot     = true

  startup {
    order = 2
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
    cores = 2
    type  = "host"
    units = 1024
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
    vlan_id = 160
    firewall = true
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = 100
    import_from  = proxmox_virtual_environment_file.haos_disk_file.id
  }

  operating_system {
    type = "l26"
  }

  usb {
    host = "10c4:ea60"
    usb3 = true
  }
}

resource "proxmox_virtual_environment_firewall_options" "haos" {
  node_name = proxmox_virtual_environment_vm.haos.node_name
  vm_id     = proxmox_virtual_environment_vm.haos.vm_id

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

resource "proxmox_virtual_environment_firewall_rules" "haos" {
  node_name = proxmox_virtual_environment_vm.haos.node_name
  vm_id     = proxmox_virtual_environment_vm.haos.id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTPS"
    dest    = var.haos_ip
    macro   = "HTTPS"
    log     = "nolog"
  }
}
