module "container" {
  source = "../modules/container"

  # Download file
  download_file_url                = "http://download.proxmox.com/images/system/archlinux-base_20240911-1_amd64.tar.zst"
  download_file_checksum           = "05b36399c801b774d9540ddbae6be6fc26803bc161e7888722f8f36c48569010e12392c6741bf263336b8542c59f18f67cf4f311d52b3b8dd58640efca765b85"
  download_file_checksum_algorithm = "sha512"

  name         = "portal"
  node_name    = "azeroth"
  os_type      = "archlinux"
  cores        = 2
  memory       = 8192
  datastore_id = "local-zfs"
  disk_size    = 20
  vlan_id      = 110
  user_ssh_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFoD5D17uiVWei7OuHjo4P98yMfjP6vrLPcG3MgGLEu benjaminmnoer25@gmail.com",
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE1+kKAtU2AoIjCAONKuc+ABm5HpPmO1s3Z5P6J7l9zD benjaminmnoer25@gmail.com"
  ]
  firewall = {
    enabled = true
    rules = [
      {
        comment = "Allow SSH"
        action  = "ACCEPT"
        macro   = "SSH"
      }
    ]
  }
}
