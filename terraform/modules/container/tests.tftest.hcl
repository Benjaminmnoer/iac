mock_provider "proxmox" {
  mock_resource "proxmox_virtual_environment_container" {
    defaults = {
      vm_id = 100
    }
  }
  mock_resource "proxmox_download_file" {
    defaults = {
      id = "local:vztmpl/archlinux-base_20240911-1_amd64.tar.zst"
    }
  }
}

variables {
  name      = "test-container"
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
    download_file_url                = "https://download.example.com/archlinux.tar.zst"
    download_file_checksum           = "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4"
    download_file_checksum_algorithm = "sha256"
    download_datastore_id            = "local"
  }

  assert {
    condition     = length(proxmox_download_file.this) == 1
    error_message = "Download resource should be created when download_file_url is set"
  }

  assert {
    condition     = proxmox_download_file.this[0].url == "https://download.example.com/archlinux.tar.zst"
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
    condition     = proxmox_download_file.this[0].id == proxmox_virtual_environment_container.this.operating_system[0].template_file_id
    error_message = "Download file ID should match container template file ID"
  }
}

run "sha512_checksum" {
  command = plan

  variables {
    download_file_url                = "https://download.example.com/archlinux.tar.zst"
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
    download_file_url = "https://download.example.com/archlinux.tar.zst"
  }

  assert {
    condition     = proxmox_download_file.this[0].datastore_id == "local"
    error_message = "download_file_id should use default datastore"
  }
}

run "container_creation" {
  command = plan

  variables {
    user_ssh_keys = ["ssh-rsa AAAA", "ssh-ed25519 AAAA"]
    firewall = {
      enabled = true
      rules = [
        {
          action = "ACCEPT"
          dport = "22"
          proto = "tcp"
        }
      ]
    }
  }

  assert {
    condition     = length(proxmox_download_file.this) == 0
    error_message = "Download file resource should not be created"
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.initialization[0].hostname == "test-container"
    error_message = "Container hostname should match the name variable"
  }

  assert {
    condition = length(proxmox_virtual_environment_container.this.initialization[0].user_account[0].keys) == 2
    error_message = "Container should have 2 SSH keys configured"
  }
}