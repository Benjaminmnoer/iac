terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.70.0"
    }
  }
  backend "pg" {
    conn_str = "postgres://192.168.50.104/terraform"
  }
}

provider "proxmox" {
  endpoint = var.virtual_environment_endpoint
  username = var.virtual_environment_username
  password = var.virtual_environment_password

  min_tls = 1.2

  # uncomment (unless on Windows...)
  tmp_dir  = "/var/tmp"

  ssh {
    agent = true
    private_key = file("~/.ssh/terraform_id_25519")
  }
}