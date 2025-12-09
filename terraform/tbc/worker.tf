resource "proxmox_virtual_environment_vm" "talos_worker_nodes" {
  for_each    = var.talos_worker_nodes
  name        = each.key
  description = "Talos Linux worker node. Managed by Terraform."
  tags        = ["terraform", "talos", "worker"]
  node_name   = each.value.node_name
  on_boot     = true

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 6144
  }

  agent {
    enabled = false
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 110
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
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${each.value.ip}/${var.default_prefix_length}"
        gateway = var.default_gateway
      }
    }
  }
}
