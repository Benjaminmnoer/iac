# Variables for download file
variable "download_file_url" {
  description = "URL of the ISO file to download (optional)"
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
  description = "Name of the VM"
  type        = string
}

variable "node_name" {
  description = "Proxmox node name"
  type        = string
}

variable "description" {
  description = "VM description"
  type        = string
  default     = "Managed by Terraform"
}

variable "tags" {
  description = "VM tags"
  type        = list(string)
  default     = []
}

variable "on_boot" {
  description = "Start VM on boot"
  type        = bool
  default     = true
}

variable "bios" {
  description = "BIOS type"
  type        = string
  default     = "ovmf"
}

variable "machine" {
  description = "Machine type"
  type        = string
  default     = "q35"
}

variable "boot_order" {
  description = "Boot order"
  type        = list(string)
  default     = ["scsi0"]
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "cpu_type" {
  description = "CPU type"
  type        = string
  default     = "host"
}

variable "cpu_units" {
  description = "CPU units"
  type        = number
  default     = 1024
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 4096
}

variable "agent_enabled" {
  description = "Enable qemu-guest-agent"
  type        = bool
  default     = true
}

variable "user_ssh_keys" {
  description = "List of SSH public keys"
  type        = list(string)
  default     = []
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

variable "firewall" {
  description = "Enable firewall on network"
  type        = bool
  default     = true
}

variable "datastore_id" {
  description = "Datastore ID for disks"
  type        = string
  default     = "local-zfs"
}

variable "disk_size" {
  description = "Disk size in GB (for new disk)"
  type        = number
  default     = 0
}

variable "disk_interface" {
  description = "Disk interface"
  type        = string
  default     = "scsi0"
}

variable "disk_file_id" {
  description = "File ID to import from (e.g., ISO)"
  type        = string
  default     = ""
}

variable "disk_file_format" {
  description = "File format when importing"
  type        = string
  default     = "raw"
}

variable "efi_datastore_id" {
  description = "Datastore ID for EFI disk"
  type        = string
  default     = "local-zfs"
}

variable "efi_type" {
  description = "EFI disk type"
  type        = string
  default     = "4m"
}

variable "efi_pre_enrolled_keys" {
  description = "Pre-enroll EFI keys"
  type        = bool
  default     = true
}

variable "os_type" {
  description = "Operating system type"
  type        = string
  default     = "l26"
}

variable "ip_address" {
  description = "IP address with CIDR (e.g., 192.168.1.10/24)"
  type        = string
  default     = ""
}

variable "ip_gateway" {
  description = "IP gateway"
  type        = string
  default     = ""
}

variable "dns_domain" {
  description = "DNS domain"
  type        = string
  default     = ""
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = []
}

variable "usb_host" {
  description = "USB device host (e.g., 10c4:ea60)"
  type        = string
  default     = ""
}

variable "usb3" {
  description = "Enable USB 3.0"
  type        = bool
  default     = true
}

variable "tpm_enabled" {
  description = "Enable TPM state"
  type        = bool
  default     = false
}

variable "tpm_version" {
  description = "TPM version"
  type        = string
  default     = "v2.0"
}

variable "firewall_options" {
  description = "Firewall options configuration"
  type = object({
    enabled      = optional(bool, true)
    input_policy = optional(string, "REJECT")
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