#################### Proxmox Provider ####################
variable "virtual_environment_endpoint" {
  type = string
}

variable "virtual_environment_api_token" {
  type = string
}

variable "virtual_environment_username" {
  type = string
}

variable "virtual_environment_password" {
  type = string
}

#################### General ####################
variable "cf_token" {
  description = "Cloudflare API token"
  type        = string
}

variable "cluster_nodes" {
  description = "List of cluster nodes"
  type = map(object({
    ip      = string
  }))
}

variable "management_ipset" {
  description = "List of allowed client IP for management access"
  type = map(object({
    ip      = string
    comment = string
  }))
}

#################### Stormwind ####################
variable "stormwind_ip" {
  type = string
}

variable "smb_clients" {
  type = list(object({
    ip      = string
    comment = string
  }))
}

#################### Lorekeeper ####################
variable "lorekeeper_ip" {
  type = string
}

#################### Cosmos ####################
variable "cosmos_ip" {
  type = string
}

#################### HAOS ####################
variable "haos_ip" {
  type = string
}