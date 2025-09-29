#################### GENERAL ####################
variable "default_gateway" {
  description = "Default gateway IP address"
  type        = string
  default     = "192.168.2.1"
}

#################### PROXMOX PROVIDER ####################
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

#################### PROXMOX HOSTS ####################
variable "azeroth_ip_address" {
  type = string
}

variable "northrend_ip_address" {
  type = string
}

variable "maelstrom_ip_address" {
  type = string
}