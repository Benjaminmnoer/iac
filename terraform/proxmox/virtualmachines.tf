# resource "proxmox_virtual_environment_download_file" "manjaro-kde-img" {
#   content_type = "iso"
#   datastore_id = "local"
#   file_name    = "manjaro-kde-25.0.4-250623-linux612.iso"
#   node_name    = "azeroth"
#   url          = "https://download.manjaro.org/kde/25.0.4/manjaro-kde-25.0.4-250623-linux612.iso"
# }

# resource "proxmox_virtual_environment_download_file" "manjaro-xfce-img" {
#   content_type = "iso"
#   datastore_id = "local"
#   file_name    = "manjaro-xfce-25.0.4-250623-linux612.iso"
#   node_name    = "azeroth"
#   url          = "https://download.manjaro.org/xfce/25.0.4/manjaro-xfce-25.0.4-250623-linux612.iso"
# }

# resource "proxmox_virtual_environment_hardware_mapping_pci" "gpu" {
#   name = "gpu"
#   map = [
#     {
#       node = "northrend"
#       id   = "10de:2204"
#       # This is an optional attribute, but causes a mapping to be incomplete when not defined.
#       iommu_group  = 27
#       path         = "0000:0b:00"
#       subsystem_id = "3842:3975"
#     }
#   ]
# }

# resource "proxmox_virtual_environment_hardware_mapping_pci" "backpanel" {
#   name = "backpanel"
#   map = [
#     {
#       node = "northrend"
#       id   = "1022:1485"
#       # This is an optional attribute, but causes a mapping to be incomplete when not defined.
#       iommu_group  = 20
#       path         = "0000:08:00"
#       subsystem_id = "1043:8808"
#     }
#   ]
# }

# resource "proxmox_virtual_environment_hardware_mapping_pci" "frontpanel" {
#   name = "frontpanel"
#   map = [
#     {
#       node = "northrend"
#       id   = "1022:1487"
#       # This is an optional attribute, but causes a mapping to be incomplete when not defined.
#       iommu_group  = 32
#       path         = "0000:0d:00.4"
#       subsystem_id = "1043:87c4"
#     }
#   ]
# }

# resource "proxmox_virtual_environment_vm" "icecrown01" {
#   depends_on  = [proxmox_virtual_environment_download_file.manjaro-xfce-img]
#   name        = "icecrown01"
#   description = "Manjaro Xfce Gaming VM. Managed by Terraform."
#   tags        = ["terraform", "arch", "gaming", "manjaro"]
#   node_name   = "northrend"
#   on_boot     = false
#   started = false

#   machine       = "q35"
#   bios          = "ovmf"
#   boot_order    = ["scsi0"]
#   kvm_arguments = "-cpu 'host,host-cache-info=on,topoext=on,hv_ipi,hv_relaxed,hv_reset,hv_runtime,hv_spinlocks=0x1fff,hv_stimer,hv_synic,hv_time,hv_vapic,hv_vendor_id=0123756792CD,hv_vpindex,kvm=off,+kvm_pv_eoi,+kvm_pv_unhalt,+invtsc,hypervisor=off' -smp '16,sockets=1,cores=16,maxcpus=16'"

#   efi_disk {
#     datastore_id      = "fdata"
#     type              = "4m"
#     pre_enrolled_keys = true
#   }

#   cpu {
#     cores    = 16
#     type     = "host"
#     affinity = "0-16"
#   }

#   memory {
#     dedicated = 16384
#   }

#   agent {
#     enabled = true
#   }

#   network_device {
#     bridge  = "vmbr0"
#     vlan_id = 1
#   }

#   cdrom {
#     file_id   = proxmox_virtual_environment_download_file.manjaro-xfce-img.id
#     interface = "ide2"
#   }

#   disk {
#     datastore_id = "fdata"
#     interface    = "scsi0"
#     size         = 100
#   }

#   operating_system {
#     type = "l26"
#   }

#   hostpci {
#     device  = "hostpci0"
#     mapping = proxmox_virtual_environment_hardware_mapping_pci.gpu.name
#     rombar  = true
#     pcie    = true
#     xvga    = true
#   }

#   hostpci {
#     device  = "hostpci1"
#     mapping = proxmox_virtual_environment_hardware_mapping_pci.backpanel.name
#     rombar  = true
#   }

#   hostpci {
#     device  = "hostpci2"
#     mapping = proxmox_virtual_environment_hardware_mapping_pci.frontpanel.name
#     rombar  = true
#   }

  # hostpci {
  #   device = "hostpci0"
  #   id     = "0000:0b:00"
  #   rombar = true
  #   pcie   = true
  #   xvga   = true
  # }

  # hostpci {
  #   device = "hostpci1"
  #   id     = "0000:08:00"
  #   rombar = true
  # }

  # hostpci {
  #   device = "hostpci2"
  #   id     = "0000:0d:00.4"
  #   rombar = true
  # }
# }

# resource "proxmox_virtual_environment_vm" "stormwind" {

# }

# resource "proxmox_virtual_environment_file" "arch_user_data_cloud_config" {
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

#     file_name = "arch-user-data-cloud-config.yaml"
#   }
# }

# resource "proxmox_virtual_environment_vm" "runeforge" {
#   depends_on  = [proxmox_virtual_environment_file.arch_user_data_cloud_config]
#   name        = "runeforge"
#   description = "Arch Linux dev machine. Managed by Terraform."
#   tags        = ["terraform", "arch", "dev"]
#   node_name   = "northrend"
#   on_boot     = false

#   cpu {
#     cores = 8
#     type  = "host"
#   }

#   memory {
#     dedicated = 8192
#   }

#   agent {
#     enabled = true
#   }

#   network_device {
#     bridge  = "vmbr0"
#     vlan_id = 3
#   }

#   disk {
#     datastore_id = "data"
#     file_id      = "unraid-isos:iso/arch-linux-amd64-cloudimg-20250115.img"
#     file_format  = "qcow2"
#     interface    = "virtio0"
#     size         = 100
#   }

#   operating_system {
#     type = "l26"
#   }

#   initialization {
#     datastore_id = "data"
#     ip_config {
#       ipv4 {
#         address = "192.168.3.2/24"
#         gateway = "192.168.3.1"
#       }
#     }
#     user_data_file_id = proxmox_virtual_environment_file.arch_user_data_cloud_config.id
#   }
# }
