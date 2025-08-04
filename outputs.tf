output "talosconfig" {
  description = "Talos client configuration (talosconfig)"
  value       = data.talos_client_configuration.this.client_configuration
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig for the Talos cluster"
  value       = resource.talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}


