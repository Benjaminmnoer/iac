terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate27519"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "proxmox" {
  endpoint  = var.virtual_environment_endpoint
  api_token = var.virtual_environment_api_token

  min_tls = 1.2

  # uncomment (unless on Windows...)
  tmp_dir = "/var/tmp"
  insecure = true

  ssh {
    agent       = true
    username    = "terraform"
    private_key = file("~/.ssh/terraform_id_25519")
  }
}
