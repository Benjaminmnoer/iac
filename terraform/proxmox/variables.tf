#################### GENERAL ####################
variable "default_gateway" {
  description = "Default gateway IP address"
  type        = string
  default     = "192.168.2.1"
}

#################### PROXMOX ####################
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

#################### DEV ####################