resource "proxmox_virtual_environment_vm" "talos_cp_01" {
  name        = "${var.talos_cp_01.name}"
  description = "${var.talos_node_defaults.description}"
  tags        = ["terraform","talos","controlplane"]
  node_name   = "${var.talos_cp_01.node}"
  on_boot     = true

  cpu {
    cores = var.talos_cp_01.cpu
    type = "${var.talos_node_defaults.cputype}"
  }

  memory {
    dedicated = var.talos_cp_01.memory
  }

  agent {
    enabled = var.talos_node_defaults.agent
  }

  network_device {
    bridge = "${var.talos_node_defaults.network_device}"
  }

  disk {
    datastore_id = "${var.talos_node_defaults.disk.datastore_id}"
    file_id      = "${var.talos_node_defaults.disk.file_id}"
    file_format  = "${var.talos_node_defaults.disk.file_format}"
    interface    = "${var.talos_node_defaults.disk.interface}"
    size         = var.talos_cp_01.disksize
  }

  operating_system {
    type = "${var.talos_node_defaults.operating_system}" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${var.talos_cp_01.ip}/24"
        gateway = var.default_gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos_cp_02" {
  name        = "${var.talos_cp_02.name}"
  description = "${var.talos_node_defaults.description}"
  tags        = ["terraform","talos","controlplane"]
  node_name   = "${var.talos_cp_02.node}"
  on_boot     = true

  cpu {
    cores = var.talos_cp_02.cpu
    type = "${var.talos_node_defaults.cputype}"
  }

  memory {
    dedicated = var.talos_cp_02.memory
  }

  agent {
    enabled = var.talos_node_defaults.agent
  }

  network_device {
    bridge = "${var.talos_node_defaults.network_device}"
  }

  disk {
    datastore_id = "${var.talos_node_defaults.disk.datastore_id}"
    file_id      = "${var.talos_node_defaults.disk.file_id}"
    file_format  = "${var.talos_node_defaults.disk.file_format}"
    interface    = "${var.talos_node_defaults.disk.interface}"
    size         = var.talos_cp_02.disksize
  }

  operating_system {
    type = "${var.talos_node_defaults.operating_system}" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${var.talos_cp_02.ip}/24"
        gateway = var.default_gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos_worker_01" {
  name        = "${var.talos_worker_01.name}"
  description = "${var.talos_node_defaults.description}"
  tags        = ["terraform","talos","controlplane"]
  node_name   = "${var.talos_worker_01.node}"
  on_boot     = true

  cpu {
    cores = var.talos_worker_01.cpu
    type = "${var.talos_node_defaults.cputype}"
  }

  memory {
    dedicated = var.talos_worker_01.memory
  }

  agent {
    enabled = var.talos_node_defaults.agent
  }

  network_device {
    bridge = "${var.talos_node_defaults.network_device}"
  }

  disk {
    datastore_id = "${var.talos_node_defaults.disk.datastore_id}"
    file_id      = "${var.talos_node_defaults.disk.file_id}"
    file_format  = "${var.talos_node_defaults.disk.file_format}"
    interface    = "${var.talos_node_defaults.disk.interface}"
    size         = var.talos_worker_01.disksize
  }

  operating_system {
    type = "${var.talos_node_defaults.operating_system}" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${var.talos_worker_01.ip}/24"
        gateway = var.default_gateway
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos_worker_02" {
  name        = "${var.talos_worker_02.name}"
  description = "${var.talos_node_defaults.description}"
  tags        = ["terraform","talos","controlplane"]
  node_name   = "${var.talos_worker_02.node}"
  on_boot     = true

  cpu {
    cores = var.talos_worker_02.cpu
    type = "${var.talos_node_defaults.cputype}"
  }

  memory {
    dedicated = var.talos_worker_02.memory
  }

  agent {
    enabled = var.talos_node_defaults.agent
  }

  network_device {
    bridge = "${var.talos_node_defaults.network_device}"
  }

  disk {
    datastore_id = "${var.talos_node_defaults.disk.datastore_id}"
    file_id      = "${var.talos_node_defaults.disk.file_id}"
    file_format  = "${var.talos_node_defaults.disk.file_format}"
    interface    = "${var.talos_node_defaults.disk.interface}"
    size         = var.talos_worker_02.disksize
  }

  operating_system {
    type = "${var.talos_node_defaults.operating_system}" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${var.talos_worker_02.ip}/24"
        gateway = var.default_gateway
      }
    }
  }
}