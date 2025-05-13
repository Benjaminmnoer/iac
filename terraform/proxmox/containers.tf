resource "proxmox_virtual_environment_container" "gryphon_master" {
  description = "Managed by Terraform"

  node_name = "maelstrom"

  initialization {
    hostname = "gryphonmaster"

    ip_config {
      ipv4 {
        address = "192.168.2.6/24"
        gateway = "192.168.2.1"
      }
    }

    user_account {
      keys = [
        trimspace(tls_private_key.gryphon_master_key.public_key_openssh)
      ]
      password = random_password.gryphon_master_password.result
    }
  }

  network_interface {
    name    = "eth0"
    bridge  = "vmbr0"
    vlan_id = "2"
  }

  cpu {
    architecture = "arm64"
    cores        = 1
  }

  memory {
    dedicated = "1024"
    swap      = "512"
  }

  disk {
    datastore_id = "local"
    size         = 4
  }

  operating_system {
    template_file_id = "unraid-isos:vztmpl/archlinux-current-20231124_arm64.tar.xz"
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    # template_file_id = "local:vztmpl/jammy-server-cloudimg-amd64.tar.gz"
    type = "ubuntu"
  }

  startup {
    order      = "2"
    up_delay   = "60"
    down_delay = "60"
  }
}

resource "random_password" "gryphon_master_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

resource "tls_private_key" "gryphon_master_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "gryphon_master_password" {
  value     = random_password.gryphon_master_password.result
  sensitive = true
}

output "gryphon_master_private_key" {
  value     = tls_private_key.gryphon_master_key.private_key_pem
  sensitive = true
}

output "gryphon_master_public_key" {
  value = tls_private_key.gryphon_master_key.public_key_openssh
}

resource "proxmox_virtual_environment_firewall_options" "gryphon_master" {
  depends_on = [proxmox_virtual_environment_container.gryphon_master]

  node_name    = proxmox_virtual_environment_container.gryphon_master.node_name
  container_id = proxmox_virtual_environment_container.gryphon_master.id

  enabled       = true
  dhcp          = true
  ipfilter      = true
  log_level_in  = "info"
  log_level_out = "info"
  macfilter     = true
  ndp           = true
  input_policy  = "DROP"
  output_policy = "ACCEPT"
  radv          = true
}

resource "proxmox_virtual_environment_firewall_rules" "gryphon_master" {
  depends_on = [
    proxmox_virtual_environment_container.gryphon_master,
    proxmox_virtual_environment_cluster_firewall_security_group.ssh,
    proxmox_virtual_environment_cluster_firewall_security_group.https,
    proxmox_virtual_environment_firewall_options.gryphon_master
  ]

  node_name    = proxmox_virtual_environment_container.gryphon_master.node_name
  container_id = proxmox_virtual_environment_container.gryphon_master.id

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.ssh.name
    comment        = "From security group. Managed by Terraform"
  }

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.https.name
    comment        = "From security group. Managed by Terraform"
  }
}
