resource "proxmox_virtual_environment_vm" "talos_worker_nodes" {
  for_each    = var.talos_worker_nodes
  name        = "${each.key}.benjaminmnoer.dk"
  description = "Talos Linux worker node. Managed by Terraform."
  tags        = ["terraform", "talos", "worker"]
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

resource "proxmox_virtual_environment_firewall_options" "worker_fw_options" {
  depends_on = [proxmox_virtual_environment_vm.talos_worker_nodes]
  for_each   = proxmox_virtual_environment_vm.talos_worker_nodes

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
