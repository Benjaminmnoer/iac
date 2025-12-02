#################### GENERAL ####################
variable "default_gateway" {
  description = "Default gateway IP address"
  type = string
  default = "192.168.110.1"
}

variable "default_prefix_length" {
  description = "Default network prefix length"
  type = number
  default = 27
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

#################### TALOS ####################
variable "talos_img_schematic" {
  type = string
  default = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
}

variable "talos_version" {
  type = string
  default = "1.11.5"
}

variable "antonidas_ip" {
  type = string
  default = "192.168.110.4"
}

variable "jaina_ip" {
  type = string
  default = "192.168.110.5"
}

variable "khadgar_ip" {
  type = string
  default = "192.168.110.6"
}

variable "rhonin_ip" {
  type = string
  default = "192.168.110.7"
}

variable "talos_cluster_config" {
  type = object({
    name = string
    domain = string
    endpoint = string
  })
  default = {
    name = "Kirin Tor"
    domain = "benjaminmnoer.dk"
    endpoint = "https://kirintor.benjaminmnoer.dk:6443"
  }
}