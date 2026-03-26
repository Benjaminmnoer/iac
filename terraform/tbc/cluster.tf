module "proxmox" {
  source           = "git::https://github.com/Benjaminmnoer/proxmox-terraform-module.git?ref=0.1-rc"
  cloudflare_token = var.cf_token
  management_ipset  = var.management_ipset
  firewall_aliases = {
    "${var.talos_jumphost_alias_name}" = var.talos_jumphost
  }
  firewall_enabled = true
}

resource "proxmox_virtual_environment_storage_cifs" "stormwind_tbc" {
  id     = "stormwind-tbc"
  nodes  = [for k, v in var.cluster_nodes : k ]
  server = "stormwind.benjaminmnoer.dk"
  share  = "tbc"

  username = "tbc-user"
  password = "tbc-user"

  content                  = ["rootdir", "vztmpl"]
  # domain                   = "WORKGROUP"
  # subdirectory             = "/ha/"
  preallocation            = "metadata"
  snapshot_as_volume_chain = true
}