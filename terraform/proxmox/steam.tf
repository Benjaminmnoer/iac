resource "proxmox_virtual_environment_download_file" "arch-iso" {
  content_type       = "iso"
  datastore_id       = "local"
  file_name          = "archlinux-2025.11.01-x86_64.iso"
  node_name          = "northrend"
  url                = "https://fastly.mirror.pkgbuild.com/iso/2025.11.01/archlinux-2025.11.01-x86_64.iso"
  checksum           = "3fde01031127fb49d3fb489dd92f8d1fc0a7fc4fdfff220936031a00a7673a2e"
  checksum_algorithm = "sha256"
}

# resource "proxmox_virtual_environment_file" "steam_user_data_cloud_config" {
#   content_type = "snippets"
#   datastore_id = "local"
#   node_name    = "northrend"

#   source_raw {
#     data = <<-EOF
#     #cloud-config
#     users:
#       - default
#       - name: benjaminmn
#         groups:
#           - wheel
#         shell: /bin/bash
#         ssh_authorized_keys:
#           - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFoD5D17uiVWei7OuHjo4P98yMfjP6vrLPcG3MgGLEu benjaminmnoer25@gmail.com
#         sudo: ALL=(ALL) NOPASSWD:ALL
#     runcmd:
#         - pacman -Syyuu --noconfirm
#         - pacman -S --noconfirm qemu-guest-agent net-tools
#         - timedatectl set-timezone Europe/Copenhagen
#         - systemctl enable qemu-guest-agent --now
#         - echo "done" > /tmp/cloud-config.done
#     EOF

#     file_name = "steam-user-data-cloud-config.yaml"
#   }
# }

resource "proxmox_virtual_environment_vm" "steam01" {
  depends_on  = [proxmox_virtual_environment_download_file.arch-iso]
  name        = "steam01"
  description = "Steam streaming VM. Managed by Terraform."
  tags        = ["terraform", "arch", "gaming", "steam"]
  node_name   = "northrend"
  on_boot     = false
  started     = true

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
    cores = 16
    type  = "host"
  }

  memory {
    dedicated = 24576
  }

  agent {
    enabled = false
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 110
  }

  cdrom {
    file_id   = proxmox_virtual_environment_download_file.arch-iso.id
    interface = "ide2"
  }

  disk {
    datastore_id = "fdata"
    interface    = "scsi0"
    size         = 100
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

  # initialization {
  #   datastore_id = "data"
  #   ip_config {
  #     ipv4 {
  #       address = "192.168.3.8/27"
  #       gateway = "192.168.3.1"
  #     }
  #   }
  #   user_data_file_id = proxmox_virtual_environment_file.steam_user_data_cloud_config.id
  # }
}
