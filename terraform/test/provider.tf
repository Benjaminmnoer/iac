terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate27519"
    container_name       = "tfstate"
    key                  = "test.terraform.tfstate"
  }
}

provider "proxmox" {
  endpoint  = var.virtual_environment_endpoint
  # api_token = var.virtual_environment_api_token
  username  = var.virtual_environment_username
  password  = var.virtual_environment_password

  min_tls = 1.2

  # uncomment (unless on Windows...)
  tmp_dir = "/var/tmp"
  insecure = true

  ssh {
    agent       = true
    username    = "root"
    private_key = file("~/.ssh/id_ed25519")
    node {
      name = "pvet01.test.benjaminmnoer.dk"
      address = "192.168.90.2"
    }
    node {
      name = "pvet02.test.benjaminmnoer.dk"
      address = "192.168.90.3"
    }
    node {
      name = "pvet03.test.benjaminmnoer.dk"
      address = "192.168.90.4"
    }
  }
}
