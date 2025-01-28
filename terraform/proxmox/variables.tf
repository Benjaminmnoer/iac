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

#################### DEV ####################
# Node defaults
variable "arch_dev_01" {
  type = object({
    name = string
    description     = string
    node = string
    cpu = number
    memory = number
    ip = string
    cputype         = string
    agent           = bool
    network_device  = string
    disk            = object({
      datastore_id      = string
      file_id           = string
      file_format       = string
      interface         = string
      size = number
    })
    operating_system = string  
  })
  default = {
    name = "arch-dev-01"
    ip = "192.168.50.5"
    node = "pve1"
    cpu = 8
    memory = 8192
    description = "Arch Linux dev machine. Managed by Terraform."
    cputype = "host"
    agent = true
    network_device = "vmbr0"
    disk = {
      datastore_id = "data-nvme0n1"
      file_id = "unraid-isos:iso/arch-linux-amd64-cloudimg-20250115.img"
      file_format = "qcow2"
      interface = "virtio0"
      size = 100
    }
    operating_system = "l26"
  }
}

variable "talos_cp_01" {
  type = object({
    
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