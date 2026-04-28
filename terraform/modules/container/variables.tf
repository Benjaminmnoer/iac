# Variables for download file
variable "download_file_url" {
  description = "URL of the file to download (optional)"
  type        = string
  default     = ""
}

variable "download_file_checksum" {
  description = "Checksum of the file to download (optional)"
  type        = string
  default     = ""
}

variable "download_file_checksum_algorithm" {
  description = "Checksum algorithm (e.g., sha256, sha512) (default sha512)"
  type        = string
  default     = "sha512"
}

variable "download_datastore_id" {
  description = "Datastore ID for the downloaded file (optional)"
  type        = string
  default     = "local"
}

variable "name" {
  description = "Hostname for the container"
  type        = string
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "description" {
  description = "Container description"
  type        = string
  default     = "Managed by Terraform"
}

variable "datastore_id" {
  description = "Datastore ID for container disk"
  type        = string
  default     = "local-zfs"
}

variable "template_file_id" {
  description = "Template file ID (from download_file)"
  type        = string
  default     = ""
}

variable "os_type" {
  description = "Operating system type"
  type        = string
  default     = "archlinux"
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 8192
}

variable "disk_size" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "VLAN ID"
  type        = number
  default     = 0
}

variable "user_ssh_keys" {
  description = "List of SSH public keys"
  type        = list(string)
  default     = []
}

variable "ip_address" {
  description = "IP address (dhcp or CIDR)"
  type        = string
  default     = "dhcp"
}

variable "unprivileged" {
  description = "Run as unprivileged container"
  type        = bool
  default     = true
}

variable "on_boot" {
  description = "Start container on boot"
  type        = bool
  default     = true
}

variable "firewall" {
  description = "Firewall configuration"
  type = object({
    enabled      = optional(bool, true)
    input_policy = optional(string, "REJECT")
    output_policy = optional(string, "ACCEPT")
    rules = optional(list(object({
      type    = optional(string, "in")
      action  = string
      comment = optional(string, "")
      source  = optional(string)
      macro   = optional(string)
      dport   = optional(string)
      proto   = optional(string)
      log     = optional(string, "info")
    })), [])
  })
  default = {}
}