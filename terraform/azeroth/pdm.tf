resource "proxmox_virtual_environment_download_file" "pdm-iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "azeroth"
  url          = "https://enterprise.proxmox.com/iso/proxmox-datacenter-manager_0.9-BETA-1.iso"
}

resource "proxmox_virtual_environment_vm" "cosmos" {
  name        = "cosmos"
  description = "Proxmox Backup Server. Managed by Terraform."
  tags        = ["terraform", "debian", "proxmox-datacenter-manager"]
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

resource "proxmox_virtual_environment_firewall_options" "cosmos" {
  node_name = proxmox_virtual_environment_vm.cosmos.node_name
  vm_id     = proxmox_virtual_environment_vm.cosmos.vm_id

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

resource "proxmox_virtual_environment_firewall_rules" "cosmos" {
  node_name = proxmox_virtual_environment_vm.cosmos.node_name
  vm_id     = proxmox_virtual_environment_vm.cosmos.id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTPS"
    source  = "+${proxmox_virtual_environment_firewall_ipset.trusted_clients.name}"
    dest    = var.cosmos_ip
    dport   = "8443"
    proto   = "tcp"
    log     = "nolog"
  }
}
