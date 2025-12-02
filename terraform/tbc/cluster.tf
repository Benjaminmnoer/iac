resource "proxmox_virtual_environment_acme_dns_plugin" "cloudflare" {
  plugin = "cloudflare"
  api    = "cf"
  data = {
    CF_Token = var.cf_token
  }
}

resource "proxmox_virtual_environment_firewall_ipset" "trusted_clients" {
  name    = "trusted_clients"
  comment = "Managed by Terraform"

  dynamic "cidr" {
    for_each = var.trusted_clients
    content {
      name    = cidr.value.ip
      comment = cidr.value.comment
    }

  }
}

resource "proxmox_virtual_environment_cluster_firewall_security_group" "management" {
  depends_on = [ proxmox_virtual_environment_firewall_ipset.trusted_clients ]

  name       = "management"
  comment    = "Managed by Terraform"

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow 8006"
    source  = "+${proxmox_virtual_environment_firewall_ipset.trusted_clients.name}"
    dest    = "${var.host_ip}"
    dport   = "8006"
    proto   = "tcp"
    log     = "nolog"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow SSH"
    source  = "+${proxmox_virtual_environment_firewall_ipset.trusted_clients.name}"
    dest    = "${var.host_ip}"
    macro   = "SSH"
    log     = "info"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "proxmox" {
  depends_on = [ proxmox_virtual_environment_cluster_firewall_security_group.management ]

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.management.name
    comment        = "From security group. Managed by Terraform"
  }
}

resource "proxmox_virtual_environment_cluster_firewall" "cluster_fw_options" {
  depends_on = [ proxmox_virtual_environment_firewall_rules.proxmox ]

  enabled = false

  ebtables      = false
  input_policy  = "DROP"
  output_policy = "ACCEPT"
  log_ratelimit {
    enabled = true
    burst   = 30
    rate    = "10/second"
  }
}