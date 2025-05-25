resource "proxmox_virtual_environment_vm" "icecrown" {
  name = "icecrown"
  description = "Manjaro Gaming VM. Managed by Terraform"
}

resource "proxmox_virtual_environment_vm" "stormwind" {
  
}

resource "proxmox_virtual_environment_file" "arch_user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "northrend"

  source_raw {
    data = <<-EOF
    #cloud-config
    users:
      - default
      - name: benjaminmn
        groups:
          - wheel
        shell: /bin/bash
        ssh_authorized_keys:
          - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFoD5D17uiVWei7OuHjo4P98yMfjP6vrLPcG3MgGLEu benjaminmnoer25@gmail.com
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - pacman -Syyuu --noconfirm
        - pacman -S --noconfirm qemu-guest-agent net-tools
        - timedatectl set-timezone Europe/Copenhagen
        - systemctl enable qemu-guest-agent --now
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "arch-user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "runeforge" {
  depends_on  = [proxmox_virtual_environment_file.arch_user_data_cloud_config]
  name        = "runeforge"
  description = "Arch Linux dev machine. Managed by Terraform."
  tags        = ["terraform", "arch", "dev"]
  node_name   = "northrend"
  on_boot     = false

  cpu {
    cores = 8
    type  = "host"
  }

  memory {
    dedicated = 8192
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
    vlan_id = 3
  }

  disk {
    datastore_id = "data"
    file_id      = "unraid-isos:iso/arch-linux-amd64-cloudimg-20250115.img"
    file_format  = "qcow2"
    interface    = "virtio0"
    size         = 100
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = "data"
    ip_config {
      ipv4 {
        address = "192.168.3.2/24"
        gateway = "192.168.3.1"
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.arch_user_data_cloud_config.id
  }
}