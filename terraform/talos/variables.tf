#################### GENERAL ####################
variable "default_gateway" {
  description = "Default gateway IP address"
  type = string
  default = "192.168.3.1"
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
  default = "1.10.4"
}

variable "antonidas_ip" {
  type = string
  default = "192.168.3.3"
}

variable "jaina_ip" {
  type = string
  default = "192.168.3.4"
}

variable "khadgar_ip" {
  type = string
  default = "192.168.3.5"
}

variable "rhonin_ip" {
  type = string
  default = "192.168.3.6"
}

variable "talos_cluster_config" {
  type = object({
    name = string
    domain = string
    endpoint = string
    proxy = object({
      ip = string
      aliases = list(string)
    })
  })
  default = {
    name = "Kirin Tor"
    domain = "benjaminmnoer.dk"
    endpoint = "https://kirintor.benjaminmnoer.dk:6443"
    proxy = {
      ip = "192.168.2.6"
      aliases = [ "kirintor", "kirintor.benjaminmnoer.dk" ]
    }
  }
}