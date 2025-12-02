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
  type = list(object({
    name    = string
    ip      = string
    comment = string
  }))
}

variable "trusted_clients" {
  description = "List of allowed client IP addresses for management access"
  type = list(object({
    ip      = string
    comment = string
  }))
}
