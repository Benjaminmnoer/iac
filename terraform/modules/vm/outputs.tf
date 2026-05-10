output "vm_id" {
  value = proxmox_virtual_environment_vm.this.vm_id
}

output "name" {
  value = var.name
}

output "node_name" {
  value = var.node_name
}

output "download_file_id" {
  description = "File ID of the downloaded ISO"
  value       = length(proxmox_download_file.this) > 0 ? proxmox_download_file.this[0].id : ""
}

output "disk_file_id" {
  description = "Disk file ID used by the VM"
  value       = var.disk_file_id != "" ? var.disk_file_id : (length(proxmox_download_file.this) > 0 ? proxmox_download_file.this[0].id : "")
}