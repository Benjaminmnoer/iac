resource "talos_machine_secrets" "machine_secrets" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.talos_cluster_config.name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [var.antonidas_ip]
}

data "talos_machine_configuration" "machineconfig_cp" {
  cluster_name     = var.talos_cluster_config.name
  cluster_endpoint = var.talos_cluster_config.endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  config_patches = [
    templatefile("${path.module}/talos-patch.yaml", {})
  ]
}

resource "talos_machine_configuration_apply" "antonidas_config_apply" {
  depends_on                  = [proxmox_virtual_environment_vm.antonidas]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  count                       = 1
  node                        = var.antonidas_ip
}

data "talos_machine_configuration" "machineconfig_worker" {
  cluster_name     = var.talos_cluster_config.name
  cluster_endpoint = var.talos_cluster_config.endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  config_patches = [
    templatefile("${path.module}/talos-patch.yaml", {})
  ]
}

resource "talos_machine_configuration_apply" "jaina_config_apply" {
  depends_on                  = [proxmox_virtual_environment_vm.khadgar, talos_machine_configuration_apply.antonidas_config_apply]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
  count                       = 1
  node                        = var.jaina_ip
}

resource "talos_machine_configuration_apply" "khadgar_config_apply" {
  depends_on                  = [proxmox_virtual_environment_vm.khadgar, talos_machine_configuration_apply.antonidas_config_apply]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
  count                       = 1
  node                        = var.khadgar_ip
}

# resource "talos_machine_configuration_apply" "rhonin_config_apply" {
#   depends_on                  = [proxmox_virtual_environment_vm.rhonin, talos_machine_configuration_apply.antonidas_config_apply]
#   client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
#   machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
#   count                       = 1
#   node                        = var.rhonin_ip
# }

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [talos_machine_configuration_apply.jaina_config_apply, talos_machine_configuration_apply.khadgar_config_apply ]# , talos_machine_configuration_apply.rhonin_config_apply]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.antonidas_ip
}

# data "talos_cluster_health" "health" {
#   depends_on           = [talos_machine_bootstrap.bootstrap]
#   client_configuration = data.talos_client_configuration.talosconfig.client_configuration
#   control_plane_nodes  = [var.talos_cp_01.ip, var.talos_cp_02.ip]
#   worker_nodes         = [var.talos_worker_01.ip, var.talos_worker_02.ip]
#   endpoints            = data.talos_client_configuration.talosconfig.endpoints
# }

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap] # depends_on           = [ talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.antonidas_ip
}

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}
