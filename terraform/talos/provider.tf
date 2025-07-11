terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.78.2"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.8.1"
    }
  }
  
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate27519"
    container_name       = "tfstate"
    key                  = "talos.terraform.tfstate"
  }
}

provider "proxmox" {
  endpoint = var.virtual_environment_endpoint
  api_token = var.virtual_environment_api_token
  # api_token = var.virtual_environment_api_token
  username  = var.virtual_environment_username
  password  = var.virtual_environment_password

  min_tls = 1.2
  insecure = true
  # uncomment (unless on Windows...)
  tmp_dir  = "/var/tmp"

  ssh {
    agent = true
    username    = "terraform"
    private_key = file("~/.ssh/terraform_id_25519")
  }
}