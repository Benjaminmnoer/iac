resource "proxmox_virtual_environment_download_file" "pbs-iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "azeroth"
  url          = "https://enterprise.proxmox.com/iso/proxmox-backup-server_4.0-1.iso"
}

resource "proxmox_virtual_environment_vm" "lorekeeper" {
  name        = "lorekeeper"
  description = "Proxmox Backup Server. Managed by Terraform."
  tags        = ["terraform", "debian", "proxmox-backup-server"]
  node_name   = "azeroth"
  on_boot     = true

  startup {
    order    = 2
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
}

resource "proxmox_virtual_environment_firewall_options" "lorekeeper" {
  node_name = proxmox_virtual_environment_vm.lorekeeper.node_name
  vm_id     = proxmox_virtual_environment_vm.lorekeeper.vm_id

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

resource "proxmox_virtual_environment_firewall_rules" "lorekeeper" {
  node_name = proxmox_virtual_environment_vm.lorekeeper.node_name
  vm_id     = proxmox_virtual_environment_vm.lorekeeper.id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTPS"
    source  = "+${proxmox_virtual_environment_firewall_ipset.trusted_clients.name}"
    dest    = var.lorekeeper_ip
    dport   = "8007"
    proto = "tcp"
    log     = "nolog"
  }
}
