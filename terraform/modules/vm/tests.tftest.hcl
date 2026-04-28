mock_provider "proxmox" {
  mock_resource "proxmox_virtual_environment_vm" {
    defaults = {
      vm_id = 100
    }
  }
  mock_resource "proxmox_download_file" {
    defaults = {
      id = "local:iso/archlinux-2024.09.01-x86_64.iso"
    }
  }
}

variables {
  name      = "test-vm"
  node_name = "testnode"
}

run "no_download" {
  command = plan

  assert {
    condition     = length(proxmox_download_file.this) == 0
    error_message = "Download resource should not be created when download_file_url is empty"
  }
}

run "with_download" {
  command = plan

  variables {
    download_file_url                = "https://download.example.com/archlinux.iso"
    download_file_checksum           = "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4"
    download_file_checksum_algorithm = "sha256"
    download_datastore_id            = "local"
  }

  assert {
    condition     = length(proxmox_download_file.this) == 1
    error_message = "Download resource should be created when download_file_url is set"
  }

  assert {
    condition     = proxmox_download_file.this[0].url == "https://download.example.com/archlinux.iso"
    error_message = "Download URL should match"
  }

  assert {
    condition     = proxmox_download_file.this[0].checksum == "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4"
    error_message = "Download checksum should match"
  }

  assert {
    condition     = proxmox_download_file.this[0].checksum_algorithm == "sha256"
    error_message = "Checksum algorithm should be sha256"
  }

  assert {
    condition     = proxmox_download_file.this[0].datastore_id == "local"
    error_message = "Datastore ID should be local"
  }

  assert {
    condition     = proxmox_download_file.this[0].content_type == "iso"
    error_message = "Content type should be iso"
  }
}

run "sha512_checksum" {
  command = plan

  variables {
    download_file_url                = "https://download.example.com/archlinux.iso"
    download_file_checksum           = "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4"
    download_file_checksum_algorithm = "sha512"
  }

  assert {
    condition     = proxmox_download_file.this[0].checksum_algorithm == "sha512"
    error_message = "sha512 checksum algorithm should be used"
  }
}

run "default_datastore" {
  command = plan

  variables {
    download_file_url = "https://download.example.com/archlinux.iso"
  }

  assert {
    condition     = proxmox_download_file.this[0].datastore_id == "local"
    error_message = "download_file_id should use default datastore"
  }
}

run "vm_creation" {
  command = plan

  variables {
    ip_address   = "192.168.1.100/24"
    user_ssh_keys = ["ssh-rsa AAAA", "ssh-ed25519 AAAA"]
    firewall_options = {
      enabled      = true
      input_policy = "REJECT"
      rules = [
        {
          action = "ACCEPT"
          dport  = "22"
          proto  = "tcp"
        }
      ]
    }
  }

  assert {
    condition     = length(proxmox_download_file.this) == 0
    error_message = "Download file resource should not be created"
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.name == "test-vm"
    error_message = "VM name should match the name variable"
  }

  assert {
    condition     = length(proxmox_virtual_environment_vm.this.initialization) > 0
    error_message = "VM should have initialization configured"
  }

  assert {
    condition = length(proxmox_virtual_environment_vm.this.initialization[0].user_account[0].keys) == 2
    error_message = "VM should have 2 SSH keys configured"
  }

  assert {
    condition = proxmox_virtual_environment_firewall_rules.this.rule[0] != null
    error_message = "Firewall rule should be configured"
  }

  assert {
    condition = proxmox_virtual_environment_firewall_rules.this.rule[0].action == "ACCEPT" && proxmox_virtual_environment_firewall_rules.this.rule[0].dport == "22" && proxmox_virtual_environment_firewall_rules.this.rule[0].proto == "tcp"
    error_message = "Firewall rule values should match the specified configuration"
  }
}

run "vm_with_efi_and_tpm" {
  command = plan

  variables {
    bios         = "ovmf"
    efi_type     = "4m"
    tpm_enabled  = true
    tpm_version  = "v2.0"
  }

  assert {
    condition     = proxmox_virtual_environment_vm.this.efi_disk[0].type == "4m"
    error_message = "EFI disk type should be 4m"
  }

  assert {
    condition     = length(proxmox_virtual_environment_vm.this.tpm_state) > 0
    error_message = "TPM state should be configured when tpm_enabled is true"
  }
}
