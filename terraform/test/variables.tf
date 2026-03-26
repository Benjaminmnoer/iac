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

variable "management_ipset" {
  description = "List of allowed client IP for management access"
  type = map(object({
    ip      = string
    comment = optional(string, "")
  }))
}