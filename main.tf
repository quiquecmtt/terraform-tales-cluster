resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [for k, v in var.talos_nodes : v.ip_address]
  endpoints            = [for k, v in var.talos_nodes : v.ip_address if v.machine_type == "controlplane"]
}

data "talos_machine_configuration" "this" {
  for_each = var.talos_nodes

  talos_version      = var.talos_version
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${local.cluster_endpoint}:6443"
  machine_type       = each.value.machine_type
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.kubernetes_version
  config_patches = [
    yamlencode({
      cluster = {
        allowSchedulingOnControlPlanes = var.scheduling_on_control_planes
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "this" {
  for_each = var.talos_nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = each.value.ip_address
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.this]
  # Bootstrap with the first control plane node.
  # VIP not yet available at this stage, so can't use var.cluster.vip
  # ref - https://www.talos.dev/v1.9/talos-guides/network/vip/#caveats
  node                 = local.first_control_plane_node_ip
  client_configuration = talos_machine_secrets.this.client_configuration
}

data "talos_cluster_health" "this" {
  depends_on = [
    talos_machine_configuration_apply.this,
    talos_machine_bootstrap.this
  ]
  skip_kubernetes_checks = false
  client_configuration   = data.talos_client_configuration.this.client_configuration
  control_plane_nodes    = [for k, v in var.talos_nodes : v.ip_address if v.machine_type == "controlplane"]
  worker_nodes           = [for k, v in var.talos_nodes : v.ip_address if v.machine_type == "worker"]
  endpoints              = data.talos_client_configuration.this.endpoints
  timeouts = {
    read = "10m"
  }
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this,
    data.talos_cluster_health.this
  ]
  # The kubeconfig endpoint will be populated from the talos_machine_configuration cluster_endpoint
  node                 = local.first_control_plane_node_ip
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    read = "1m"
  }
}

