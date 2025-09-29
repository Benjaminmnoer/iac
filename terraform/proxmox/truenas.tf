resource "proxmox_virtual_environment_download_file" "truenas-iso" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = "azeroth"
  url          = "https://download.sys.truenas.net/TrueNAS-SCALE-Fangtooth/25.04.2.4/TrueNAS-SCALE-25.04.2.4.iso"
}

resource "proxmox_virtual_environment_vm" "stormwind" {
  depends_on  = [proxmox_virtual_environment_download_file.truenas-iso]
  name        = "stormwind01"
  description = "TrueNAS. Managed by Terraform."
  tags        = ["terraform", "debian", "truenas"]
  node_name   = "azeroth"
  on_boot     = true
  
  startup {
    order = 1
    up_delay = 300
  }

  bios = "ovmf"
  boot_order = ["scsi0"]
  machine = "q35"

  cdrom {
    file_id   = proxmox_virtual_environment_download_file.truenas-iso.id
    interface = "ide2"
  }

  efi_disk {
    datastore_id      = "local"
    type              = "4m"
    pre_enrolled_keys = true
  }

  cpu {
    cores = 4
    type  = "host"
  }

  memory {
    dedicated = 20480
  }
 
  agent {
    enabled = false
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 110
  }

  disk {
    datastore_id = "local"
    file_format  = "qcow2"
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
