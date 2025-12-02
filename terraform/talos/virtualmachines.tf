resource "proxmox_virtual_environment_download_file" "azeroth_talos_amd64_img" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "talos-${var.talos_version}-nocloud-amd64.iso"
  node_name    = "azeroth"
  url          = "https://factory.talos.dev/image/${var.talos_img_schematic}/${var.talos_version}/nocloud-amd64.iso"
}

resource "proxmox_virtual_environment_download_file" "northrend_talos_amd64_img" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "talos-${var.talos_version}-nocloud-amd64.iso"
  node_name    = "northrend"
  url          = "https://factory.talos.dev/image/${var.talos_img_schematic}/${var.talos_version}/nocloud-amd64.iso"
}

resource "proxmox_virtual_environment_vm" "antonidas" {
  name        = "antonidas"
  description = "Talos Linux controlplane node. Managed by Terraform."
  tags        = ["terraform", "talos", "controlplane"]
  node_name   = "azeroth"
  on_boot     = true

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 16384
  }

  agent {
    enabled = true
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 110
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.northrend_talos_amd64_img.id
    file_format  = "raw"
    interface    = "scsi0"
    size         = 100
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${var.antonidas_ip}/${var.default_prefix_length}"
        gateway = var.default_gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_firewall_options" "antonidas_fw" {
  depends_on = [proxmox_virtual_environment_vm.antonidas]

  node_name = proxmox_virtual_environment_vm.antonidas.node_name
  vm_id     = proxmox_virtual_environment_vm.antonidas.vm_id

  enabled       = true
  dhcp          = true
  ndp           = true
  radv          = false
  macfilter     = true
  ipfilter      = false
  log_level_in  = "info"
  log_level_out = "nolog"
  input_policy  = "REJECT"
  output_policy = "ACCEPT"
}

resource "proxmox_virtual_environment_vm" "jaina" {
  name        = "jaina"
  description = "Talos Linux worker node. Managed by Terraform."
  tags        = ["terraform", "talos", "worker"]
  node_name   = "azeroth"
  on_boot     = true

  cpu {
    cores = 4
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 16384
  }

  agent {
    enabled = true
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 110
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.northrend_talos_amd64_img.id
    file_format  = "raw"
    interface    = "scsi0"
    size         = 100
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${var.jaina_ip}/${var.default_prefix_length}"
        gateway = var.default_gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_firewall_options" "jaina_fw" {
  depends_on = [proxmox_virtual_environment_vm.jaina]

  node_name = proxmox_virtual_environment_vm.jaina.node_name
  vm_id     = proxmox_virtual_environment_vm.jaina.vm_id

  enabled       = true
  dhcp          = true
  ndp           = true
  radv          = false
  macfilter     = true
  ipfilter      = false
  log_level_in  = "info"
  log_level_out = "nolog"
  input_policy  = "REJECT"
  output_policy = "ACCEPT"
}

resource "proxmox_virtual_environment_vm" "khadgar" {
  name        = "khadgar"
  description = "Talos Linux worker node. Managed by Terraform."
  tags        = ["terraform", "talos", "worker"]
  node_name   = "northrend"
  on_boot     = true

  cpu {
    cores = 8
    type  = "x86-64-v2-AES"
    # affinity = "16-23"
  }

  memory {
    dedicated = 8192
  }

  agent {
    enabled = true
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 110
  }

  disk {
    datastore_id = "data"
    file_id      = proxmox_virtual_environment_download_file.northrend_talos_amd64_img.id
    file_format  = "raw"
    interface    = "scsi0"
    size         = 100
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${var.khadgar_ip}/${var.default_prefix_length}"
        gateway = var.default_gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_firewall_options" "khadgar_fw" {
  depends_on = [proxmox_virtual_environment_vm.khadgar]

  node_name = proxmox_virtual_environment_vm.khadgar.node_name
  vm_id     = proxmox_virtual_environment_vm.khadgar.vm_id

  enabled       = true
  dhcp          = true
  ndp           = true
  radv          = false
  macfilter     = true
  ipfilter      = false
  log_level_in  = "info"
  log_level_out = "nolog"
  input_policy  = "REJECT"
  output_policy = "ACCEPT"
}

# resource "proxmox_virtual_environment_vm" "rhonin" {
#   name        = "rhonin"
#   description = "Talos Linux workernode. Managed by Terraform."
#   tags        = ["terraform", "talos", "worker"]
#   node_name   = "northrend"
#   on_boot     = true

#   cpu {
#     cores = 8
#     type  = "x86-64-v2-AES"
#   }

#   memory {
#     dedicated = 4096
#   }

#   agent {
#     enabled = true
#   }

#   network_device {
#     bridge  = "vmbr0"
#     vlan_id = 110
#   }

#   disk {
#     datastore_id = "data"
#     file_id      = proxmox_virtual_environment_download_file.talos_amd64_img.id
#     file_format  = "raw"
#     interface    = "scsi0"
#     size         = 100
#   }

#   operating_system {
#     type = "l26" # Linux Kernel 2.6 - 5.X.
#   }

#   initialization {
#     datastore_id = "local"
#     ip_config {
#       ipv4 {
#         address = "${var.rhonin_ip}"
#         gateway = var.default_gateway
#       }
#     }
#   }
# }
