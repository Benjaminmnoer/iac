resource "proxmox_virtual_environment_firewall_ipset" "talos_clients_ipset" {
  name       = "talos_clients"
  depends_on = [module.proxmox]

  cidr {
    name = "dc/${var.talos_jumphost_alias_name}"
  }

  dynamic "cidr" {
    for_each = merge(var.talos_controlplane_nodes, var.talos_worker_nodes)
    content {
      name    = cidr.value.ip
      comment = cidr.key
    }
  }
}

resource "proxmox_virtual_environment_firewall_rules" "talos_node_access" {
  depends_on = [proxmox_virtual_environment_firewall_ipset.talos_clients_ipset, proxmox_virtual_environment_vm.talos_controlplane_nodes, proxmox_virtual_environment_vm.talos_worker_nodes]
  for_each   = merge(proxmox_virtual_environment_vm.talos_controlplane_nodes, proxmox_virtual_environment_vm.talos_worker_nodes)

  node_name = each.value.node_name
  vm_id     = each.value.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow 50000"
    source  = "+${proxmox_virtual_environment_firewall_ipset.talos_clients_ipset.name}"
    dport   = "50000"
    proto   = "tcp"
    log     = "info"
  }
}

resource "proxmox_virtual_environment_firewall_rules" "talos_api_access" {
  depends_on = [proxmox_virtual_environment_firewall_ipset.talos_clients_ipset, proxmox_virtual_environment_vm.talos_controlplane_nodes, proxmox_virtual_environment_firewall_rules.talos_node_access]
  for_each   = proxmox_virtual_environment_vm.talos_controlplane_nodes

  node_name = each.value.node_name
  vm_id     = each.value.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow 6443"
    source  = "192.168.110.41" 
    dport   = "6443"
    proto   = "tcp"
    log     = "info"
  }
}

resource "talos_machine_secrets" "machine_secrets" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.talos_cluster_config.name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [var.talos_cluster_config.endpoint]
}

data "talos_machine_configuration" "machineconfig_controlplane" {
  cluster_name     = var.talos_cluster_config.name
  cluster_endpoint = var.talos_cluster_config.endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  config_patches = [
    templatefile("${path.module}/talos-patch.yaml", {})
  ]
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

resource "talos_machine_configuration_apply" "controlplane_config_apply" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_controlplane_nodes, proxmox_virtual_environment_firewall_rules.talos_node_access]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_controlplane.machine_configuration
  for_each                    = var.talos_controlplane_nodes
  node                        = each.value.ip
}

resource "talos_machine_configuration_apply" "worker_config_apply" {
  depends_on                  = [proxmox_virtual_environment_vm.talos_worker_nodes, talos_machine_configuration_apply.controlplane_config_apply, proxmox_virtual_environment_firewall_rules.talos_node_access]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
  for_each                    = var.talos_worker_nodes
  node                        = each.value.ip
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [talos_machine_configuration_apply.worker_config_apply]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = values(var.talos_controlplane_nodes)[0].ip
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = values(var.talos_controlplane_nodes)[0].ip
}

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}
