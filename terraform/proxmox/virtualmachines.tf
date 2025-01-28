resource "proxmox_virtual_environment_vm" "arch_dev_01" {
  name        = var.arch_dev_01.name
  description = var.arch_dev_01.description
  tags        = ["terraform","talos","controlplane"]
  node_name   = var.arch_dev_01.node
  on_boot     = true

  cpu {
    cores = var.arch_dev_01.cpu
    type = var.arch_dev_01.cputype
  }

  memory {
    dedicated = var.arch_dev_01.memory
  }

  agent {
    enabled = var.arch_dev_01.agent
  }

  network_device {
    bridge = var.arch_dev_01.network_device
  }

  disk {
    datastore_id = var.arch_dev_01.disk.datastore_id
    file_id      = var.arch_dev_01.disk.file_id
    file_format  = var.arch_dev_01.disk.file_format
    interface    = var.arch_dev_01.disk.interface
    size         = var.arch_dev_01.disk.size
  }

  operating_system {
    type = "${var.arch_dev_01.operating_system}" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${var.arch_dev_01.ip}/24"
        gateway = var.default_gateway
      }
    }
    user_account {
      username = "benjaminmn"
      keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFoD5D17uiVWei7OuHjo4P98yMfjP6vrLPcG3MgGLEu benjaminmnoer25@gmail.com" ]
    }
  }
}