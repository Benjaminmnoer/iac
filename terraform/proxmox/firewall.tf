resource "proxmox_virtual_environment_cluster_firewall" "cluster_fw_options" {
  enabled = true

  ebtables      = false
  input_policy  = "DROP"
  output_policy = "ACCEPT"
  log_ratelimit {
    enabled = true
    burst   = 30
    rate    = "10/second"
  }
}

resource "proxmox_virtual_environment_firewall_ipset" "management_ipset" {
  name    = "management_ipset"
  comment = "Managed by Terraform"

  cidr {
    name    = "192.168.2.2"
    comment = "Northrend"
  }

  cidr {
    name    = "192.168.2.3"
    comment = "Azeroth"
  }

  cidr {
    name    = "192.168.2.4"
    comment = "Maelstrom"
  }

  cidr {
    name    = "192.168.2.5"
    comment = "Stormwind"
  }
}

resource "proxmox_virtual_environment_firewall_ipset" "proxmox_ipset" {
  name    = "proxmox_ipset"
  comment = "Managed by Terraform"

  cidr {
    name    = "192.168.2.2"
    comment = "Northrend"
  }

  cidr {
    name    = "192.168.2.3"
    comment = "Azeroth"
  }

  cidr {
    name    = "192.168.2.4"
    comment = "Maelstrom"
  }
}

resource "proxmox_virtual_environment_firewall_ipset" "unraid_ipset" {
  name    = "unraid_ipset"
  comment = "Managed by Terraform"

  cidr {
    name    = "192.168.2.5"
    comment = "Stormwind"
  }
}

resource "proxmox_virtual_environment_firewall_ipset" "trusted_clients" {
  name    = "trusted_clients"
  comment = "Managed by Terraform"

  cidr {
    name    = "192.168.1.5"
    comment = "laptop - lan"
  }

  cidr {
    name    = "192.168.1.6"
    comment = "laptop - wifi"
  }

  cidr {
    name    = "192.168.1.7"
    comment = "OP8T"
  }

  cidr {
    name    = "192.168.1.8"
    comment = "OP12"
  }
}

resource "proxmox_virtual_environment_cluster_firewall_security_group" "proxmox_security_group" {
  name       = "proxmox_sg"
  comment    = "Managed by Terraform"
  depends_on = [proxmox_virtual_environment_firewall_ipset.trusted_clients, proxmox_virtual_environment_firewall_ipset.proxmox_ipset]

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow 8006"
    source  = "+${proxmox_virtual_environment_firewall_ipset.trusted_clients.name}"
    dest    = "+${proxmox_virtual_environment_firewall_ipset.proxmox_ipset.name}"
    dport   = "8006"
    proto   = "tcp"
    log     = "info"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow 22"
    source  = "+${proxmox_virtual_environment_firewall_ipset.trusted_clients.name}"
    dest    = "+${proxmox_virtual_environment_firewall_ipset.proxmox_ipset.name}"
    dport   = "22"
    proto   = "tcp"
    log     = "info"
  }
}

resource "proxmox_virtual_environment_cluster_firewall_security_group" "unraid_security_group" {
  name       = "unraid_sg"
  comment    = "Managed by Terraform"

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow 443"
    source  = "+${proxmox_virtual_environment_firewall_ipset.trusted_clients.name}"
    dest    = "+${proxmox_virtual_environment_firewall_ipset.unraid_ipset.name}"
    dport   = "443"
    proto   = "tcp"
    log     = "info"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow 80"
    source  = "+${proxmox_virtual_environment_firewall_ipset.trusted_clients.name}"
    dest    = "+${proxmox_virtual_environment_firewall_ipset.unraid_ipset.name}"
    dport   = "80"
    proto   = "tcp"
    log     = "info"
  }

  # rule {
  #   type    = "in"
  #   action  = "ACCEPT"
  #   comment = "Allow 445"
  #   source  = "+${proxmox_virtual_environment_firewall_ipset.trusted_clients.name}"
  #   dest    = "+${proxmox_virtual_environment_firewall_ipset.unraid_ipset.name}"
  #   dport   = "80"
  #   proto   = "tcp"
  #   log     = "info"
  # }
}

resource "proxmox_virtual_environment_cluster_firewall_security_group" "ssh" {
  name    = "ssh"
  comment = "Managed by Terraform"

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow 22"
    dport   = "22"
    proto   = "tcp"
    log     = "info"
  }
}

resource "proxmox_virtual_environment_cluster_firewall_security_group" "https" {
  name    = "https"
  comment = "Managed by Terraform"

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow 443"
    dport   = "443"
    proto   = "tcp"
    log     = "nolog"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "proxmox" {
  depends_on = [
    proxmox_virtual_environment_firewall_ipset.proxmox_ipset,
    proxmox_virtual_environment_cluster_firewall_security_group.proxmox_security_group
  ]

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.proxmox_security_group.name
    comment        = "From security group. Managed by Terraform"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "unraid" {
  depends_on = [
    proxmox_virtual_environment_firewall_ipset.unraid_ipset,
    proxmox_virtual_environment_cluster_firewall_security_group.unraid_security_group
  ]

  node_name = "azeroth"
  vm_id = 100

  rule {
    security_group = proxmox_virtual_environment_cluster_firewall_security_group.unraid_security_group.name
    comment        = "From security group. Managed by Terraform"
  }
}
