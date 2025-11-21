# resource "proxmox_virtual_environment_download_file" "manjaro-kde-img" {
#   content_type       = "iso"
#   datastore_id       = "local"
#   node_name          = "azeroth"
#   url                = "https://download.manjaro.org/kde/25.0.10/manjaro-kde-25.0.10-251013-linux612.iso"
#   checksum           = "8067253b7174aa3b0706ab4849dabf27288c5787cea7838ca037fec5a01fa1c5"
#   checksum_algorithm = "sha256"
# }

resource "proxmox_virtual_environment_vm" "icecrown" {
  # depends_on      = [proxmox_virtual_environment_download_file.manjaro-kde-img]
  name            = "icecrown"
  description     = "Manjaro KDE Gaming VM. Managed by Terraform."
  tags            = ["terraform", "arch", "gaming", "manjaro"]
  node_name       = "northrend"
  on_boot         = false
  started         = false
  keyboard_layout = "da"

  machine       = "q35"
  bios          = "ovmf"
  boot_order    = ["scsi0"]
  kvm_arguments = "-cpu 'host,host-cache-info=on,topoext=on,hv_ipi,hv_relaxed,hv_reset,hv_runtime,hv_spinlocks=0x1fff,hv_stimer,hv_synic,hv_time,hv_vapic,hv_vendor_id=0123756792CD,hv_vpindex,kvm=off,+kvm_pv_eoi,+kvm_pv_unhalt,+invtsc,hypervisor=off' -smp '16,sockets=1,cores=16,maxcpus=16'"

  efi_disk {
    datastore_id      = "fdata"
    type              = "4m"
    pre_enrolled_keys = true
  }

  cpu {
    cores = 24
    type  = "host"
    units = 1024
  }

  memory {
    dedicated = 24576
  }

  agent {
    enabled = true
  }

  # cdrom {
  #   file_id   = proxmox_virtual_environment_download_file.manjaro-kde-img.id
  #   interface = "ide2"
  # }

  disk {
    datastore_id = "fdata"
    interface    = "scsi0"
    size         = 100
    iothread     = true
  }

  disk {
    datastore_id = "fdata"
    interface    = "scsi1"
    size         = 500
    iothread     = true
  }

  operating_system {
    type = "l26"
  }

  hostpci {
    device = "hostpci0"
    id     = "0000:0b:00"
    rombar = true
    pcie   = true
    xvga   = true
  }

  hostpci {
    device = "hostpci1"
    id     = "0000:08:00"
    rombar = true
  }

  hostpci {
    device = "hostpci2"
    id     = "0000:0d:00.4"
    rombar = true
  }

  hostpci {
    device = "hostpci3"
    id     = "0000:06:00.0"
    rombar = true
  }
}
