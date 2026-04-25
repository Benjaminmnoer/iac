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

#################### Jump Host ####################
variable "jump_ip" {
  description = "IP address for jump LXC"
  type        = string
  default     = "10.0.10.2"
}

variable "jump_services_ip" {
  description = "IP address for jump-svc LXC"
  type        = string
  default     = "10.0.10.3"
}