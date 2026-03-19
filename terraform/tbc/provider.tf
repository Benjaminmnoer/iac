terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.98.1"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.10.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate27519"
    container_name       = "tfstate"
    key                  = "tbc.terraform.tfstate"
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
      name = "outland.benjaminmnoer.dk"
      address = "192.168.100.2"
    }
    node {
      name = "easternkingdoms.benjaminmnoer.dk"
      address = "192.168.100.5"
    }
    node {
      name = "kalimdor.benjaminmnoer.dk"
      address = "192.168.100.6"
    }
  }
}
