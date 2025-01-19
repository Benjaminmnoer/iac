#################### GENERAL ####################
variable "default_gateway" {
  description = "Default gateway IP address"
  type = string
  default = "192.168.50.1"
}

#################### PROXMOX ####################
variable "virtual_environment_endpoint" {
  type = string
}

variable "virtual_environment_username" {
  type = string
}

variable "virtual_environment_password" {
  type = string
}

#################### TALOS ####################
variable "talos_cluster_name" {
  type    = string
  default = "istari"
}

variable "talos_cp_01_ip" {
  type    = string
  default = "192.168.50.101"
}

variable "talos_worker_01_ip" {
  type    = string
  default = "192.168.50.102"
}