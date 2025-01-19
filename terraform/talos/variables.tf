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

# Node defaults
variable "talos_node_defaults" {
  type = object({
    description     = string
    cputype         = string
    agent           = bool
    network_device  = string
    disk            = object({
      datastore_id      = string
      file_id           = string
      file_format       = string
      interface         = string
    })
    operating_system = string  
  })
  default = {
    description = "Talos Linux node. Managed by Terraform."
    cputype = "x86-64-v2-AES"
    agent = true
    network_device = "vmbr0"
    disk = {
      datastore_id = "unraid-domains"
      file_id = "unraid-isos:iso/talos-v1.9.2-nocloud-amd64.img"
      file_format = "raw"
      interface = "virtio0"
    }
    operating_system = "l26"
  }
}

variable "talos_cp_01" {
  type = object({
    name = string
    ip = string
    node = string
    cpu = number
    memory = number
    disksize = number
  })
  default = {
    name = "talos-cp-01"
    ip = "192.168.50.110"
    node = "tower"
    cpu = 4
    memory = 8192
    disksize = 100
  }
}

variable "talos_cp_02" {
  type = object({
    name = string
    ip = string
    node = string
    cpu = number
    memory = number
    disksize = number
  })
  default = {
    name = "talos-cp-02"
    ip = "192.168.50.112"
    node = "pve1"
    cpu = 4
    memory = 4096
    disksize = 100
  }
}

variable "talos_worker_01" {
  type = object({
    name = string
    ip = string
    node = string
    cpu = number
    memory = number
    disksize = number
  })
  default = {
    name = "talos-worker-01"
    ip = "192.168.50.111"
    node = "tower"
    cpu = 4
    memory = 8192
    disksize = 100
  }
}

variable "talos_worker_02" {
  type = object({
    name = string
    ip = string
    node = string
    cpu = number
    memory = number
    disksize = number
  })
  default = {
    name = "talos-worker-02"
    ip = "192.168.50.113"
    node = "pve1"
    cpu = 4
    memory = 4096
    disksize = 100
  }
}