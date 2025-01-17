resource "proxmox_virtual_environment_cluster_options" "options" {
  language                  = "en"
  keyboard                  = "da"
  email_from                = "root@$hostname"
  max_workers               = 5
#   migration_cidr            = "10.0.0.0/8"
#   migration_type            = "secure"
  next_id = {
    lower = 100
    upper = 999999999
  }
}

resource "proxmox_virtual_environment_cluster_firewall" "example" {
  enabled = false

  ebtables      = false
  input_policy  = "DROP"
  output_policy = "ACCEPT"
  log_ratelimit {
    enabled = false
    burst   = 10
    rate    = "5/second"
  }
}