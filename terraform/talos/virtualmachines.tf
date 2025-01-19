resource "proxmox_virtual_environment_vm" "talos_cp_01" {
  name        = "talos-cp-01"
  description = "Managed by Terraform"
  tags        = ["terraform","talos","controlplane"]
  node_name   = "tower"
  on_boot     = true

  cpu {
    cores = 2
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "unraid-domains"
    file_id      = "unraid-isos:iso/talos-v1.9.2-nocloud-amd64.img"
    file_format  = "raw"
    interface    = "virtio0"
    size         = 20
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${var.talos_cp_01_ip}/24"
        gateway = var.default_gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos_worker_01" {
  depends_on = [ proxmox_virtual_environment_vm.talos_cp_01 ]
  name        = "talos-worker-01"
  description = "Managed by Terraform"
  tags        = ["terraform", "talos", "worker"]
  node_name   = "tower"
  on_boot     = true

  cpu {
    cores = 4
    type = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "unraid-domains"
    file_id      = "unraid-isos:iso/talos-v1.9.2-nocloud-amd64.img"
    file_format  = "raw"
    interface    = "virtio0"
    size         = 20
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${var.talos_worker_01_ip}/24"
        gateway = var.default_gateway
      }
    }
  }
}