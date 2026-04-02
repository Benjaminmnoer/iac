resource "proxmox_virtual_environment_download_file" "talos_amd64_img" {
  for_each     = var.cluster_nodes
  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key
  url          = "https://factory.talos.dev/image/${var.talos_img_schematic}/${var.talos_version}/nocloud-amd64-secureboot.iso"
  # https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.12.6/metal-amd64.iso
}

resource "proxmox_virtual_environment_vm" "talos_controlplane_nodes" {
  for_each    = var.talos_controlplane_nodes
  name        = "${each.key}.benjaminmnoer.dk"
  description = "Talos Linux controlplane node. Managed by Terraform."
  tags        = ["terraform", "talos", "controlplane"]
  node_name   = each.value.node_name
  on_boot     = true
  machine     = "q35"
  bios        = "ovmf"
  boot_order  = ["scsi0"]

  lifecycle {
    ignore_changes = [
      started,

    ]
  }

  efi_disk {
    datastore_id = "local-zfs"
    type         = "4m"
  }

  tpm_state {
    version      = "v2.0"
    datastore_id = "local-zfs"
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 6144
  }

  agent {
    enabled = true
  }

  network_device {
    bridge   = "vmbr0"
    vlan_id  = 110
    firewall = true
  }

  disk {
    datastore_id = "local-zfs"
    file_id      = proxmox_virtual_environment_download_file.talos_amd64_img[each.value.node_name].id
    file_format  = "raw"
    interface    = "scsi0"
    size         = 100
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local-zfs"
    ip_config {
      ipv4 {
        address = "${each.value.ip}/26"
        gateway = "192.168.110.1"
      }
    }
    dns {
      domain  = var.talos_cluster_config.domain
      servers = ["192.168.110.1"]
    }
  }
}

resource "proxmox_virtual_environment_firewall_options" "controlplane_fw_options" {
  depends_on = [proxmox_virtual_environment_vm.talos_controlplane_nodes]
  for_each   = proxmox_virtual_environment_vm.talos_controlplane_nodes

  node_name = each.value.node_name
  vm_id     = each.value.vm_id

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
