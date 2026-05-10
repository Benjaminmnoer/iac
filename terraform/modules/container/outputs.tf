output "vm_id" {
  value = proxmox_virtual_environment_container.this.vm_id
}

output "name" {
  value = var.name
}

output "node_name" {
  value = var.node_name
}

output "download_file_id" {
  description = "File ID of the downloaded template"
  value       = length(proxmox_download_file.this) > 0 ? proxmox_download_file.this[0].id : ""
}

output "template_file_id" {
  description = "Template file ID used by the container"
  value       = var.template_file_id != "" ? var.template_file_id : (length(proxmox_download_file.this) > 0 ? proxmox_download_file.this[0].id : "")
}