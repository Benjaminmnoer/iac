resource "proxmox_virtual_environment_vm" "nginx" {
  name        = "nginx"
  description = "Managed by Terraform"
  tags        = ["terraform", "arch"]

  node_name = "pve1"
  vm_id     = 110

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true

  cpu {
    cores = 2
    type  = "x86-64-v2-AES" # recommended for modern CPUs
  }

  cdrom {
    enabled = true
    file_id = "unraid-isos:iso/archlinux-2025.01.14-x86_64.iso"
  }

  disk {
    datastore_id = "unraid-domains"
    interface    = "scsi0"
  }

  memory {
    dedicated = 2048
    floating  = 2048 # set equal to dedicated to enable ballooning
  }


  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }
}

resource "random_password" "arch_vm_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "arch_vm_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "arch_vm_password" {
  value     = random_password.arch_vm_password.result
  sensitive = true
}

output "arch_vm_key" {
  value     = tls_private_key.arch_vm_key.private_key_pem
  sensitive = true
}

output "arch_vm_public_key" {
  value = tls_private_key.arch_vm_key.public_key_openssh
}