resource "proxmox_virtual_environment_cluster_options" "options" {
  language                  = "en"
  keyboard                  = "da"
  email_from                = "pve@benjaminmnoer.dk"
  max_workers               = 5
#   migration_cidr            = "10.0.0.0/8"
#   migration_type            = "secure"
  next_id = {
    lower = 200
    upper = 999999999
  }
}