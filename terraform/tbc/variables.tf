#################### Proxmox Provider ####################
variable "virtual_environment_endpoint" {
  type = string
}

# variable "virtual_environment_api_token" {
#   type = string
# }

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
    comment = optional(string, "")
  }))
}

#################### TALOS ####################
variable "talos_img_schematic" {
  type = string
  default = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
}

variable "talos_version" {
  type = string
  default = "v1.12.6"
}

variable "talos_controlplane_nodes" {
  type = map(object({
    node_name = string
    ip        = string
  }))
}

variable "talos_worker_nodes" {
  type = map(object({
    node_name = string
    ip        = string
  }))
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