resource "proxmox_virtual_environment_file" "arch_user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve1"

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
      - name: ansible
        groups:
          - wheel
        shell: /bin/bash
        ssh_authorized_keys:
          - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJSv5Qo/+Z5DIWkmlFz/Fw+TeUbIfVC3sBcwhHzec8Im ansible
        sudo: ALL=(ALL) NOPASSWD:ALL
    runcmd:
        - pacman -Syyuu --noconfirm
        - pacman -S --noconfirm qemu-guest-agent net-tools
        - timedatectl set-timezone Europe/Copenhagen
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
        - echo "done" > /tmp/cloud-config.done
    EOF

    file_name = "arch-user-data-cloud-config.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "arch_dev_01" {
  depends_on = [ proxmox_virtual_environment_file.arch_user_data_cloud_config ]
  name        = "arch-dev-01"
  description = "Arch Linux dev machine. Managed by Terraform."
  tags        = ["terraform", "arch", "dev"]
  node_name   = "pve1"
  on_boot     = true

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
  }

  disk {
    datastore_id = "data-nvme0n1"
      file_id      = "unraid-isos:iso/arch-linux-amd64-cloudimg-20250115.img"
      file_format  = "qcow2"
      interface    = "virtio0"
      size         = 100
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "192.168.50.5/24"
        gateway = var.default_gateway
      }
    }
    user_data_file_id = proxmox_virtual_environment_file.arch_user_data_cloud_config.id
  }
}
