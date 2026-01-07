resource "proxmox_virtual_environment_download_file" "pve_iso" {
  url                = "https://enterprise.proxmox.com/iso/proxmox-ve_9.1-1.iso"
  checksum           = "6d8f5afc78c0c66812d7272cde7c8b98be7eb54401ceb045400db05eb5ae6d22"
  checksum_algorithm = "sha256"
  node_name          = "northrend"
  content_type       = "iso"
  datastore_id       = "local"
}

resource "proxmox_virtual_environment_vm" "pvet01" {
  name        = "pvet01"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "pve", "test"]

  node_name  = "northrend"
  bios       = "ovmf"
  boot_order = ["scsi0", "ide2"]
  machine    = "q35"
  on_boot = false

  efi_disk {
    datastore_id      = "local-zfs"
    type              = "4m"
    pre_enrolled_keys = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  cdrom {
    file_id   = "local:iso/proxmox-ve_9.1-1-pvet01.iso"
    interface = "ide2"
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = 100
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 90
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [
      started,
    ]
  }
}

resource "proxmox_virtual_environment_vm" "pvet03" {
  name        = "pvet03"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "pve", "test"]

  node_name  = "northrend"
  bios       = "ovmf"
  boot_order = ["scsi0", "ide2"]
  machine    = "q35"
  on_boot = false

  efi_disk {
    datastore_id      = "local-zfs"
    type              = "4m"
    pre_enrolled_keys = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  cdrom {
    file_id   = "local:iso/proxmox-ve_9.1-1-pvet03.iso"
    interface = "ide2"
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = 100
  }

  network_device {
    bridge = "vmbr0"
    vlan_id = 90
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [
      started,
    ]
  }
}

resource "proxmox_virtual_environment_vm" "pvet02" {
  name        = "pvet02"
  description = "Managed by Terraform"
  tags        = ["terraform", "debian", "pve", "test"]

  node_name  = "northrend"
  bios       = "ovmf"
  boot_order = ["scsi0", "ide2"]
  machine    = "q35"
  on_boot = false

  efi_disk {
    datastore_id      = "local-zfs"
    type              = "4m"
    pre_enrolled_keys = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  cdrom {
    file_id   = "local:iso/proxmox-ve_9.1-1-pvet02.iso"
    interface = "ide2"
  }

  disk {
    datastore_id = "local-zfs"
    interface    = "scsi0"
    size         = 100
  }

  network_device {
    bridge = "vmbr0"
    vlan_id = 90
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [
      started,
    ]
  }
}
