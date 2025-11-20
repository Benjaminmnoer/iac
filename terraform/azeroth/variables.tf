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

variable "host_ip" {
  description = "IP address of the proxmox host"
  type        = string
}

variable "trusted_clients" {
  description = "List of allowed client IP addresses for management access"
  type = list(object({
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
