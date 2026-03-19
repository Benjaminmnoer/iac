module "proxmox" {
  source           = "git::https://github.com/Benjaminmnoer/proxmox-terraform-module.git?ref=0.1-rc"
  cloudflare_token = var.cf_token
  management_ipset  = var.management_ipset
  firewall_enabled = true
}
