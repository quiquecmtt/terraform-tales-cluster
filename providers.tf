provider "helm" {
  kubernetes = {
    host = "https://${local.cluster_endpoint}:6443"

    client_certificate     = resource.talos_cluster_kubeconfig.this.client_configuration.client_certificate
    client_key             = resource.talos_cluster_kubeconfig.this.client_configuration.client_key
    cluster_ca_certificate = resource.talos_cluster_kubeconfig.this.client_configuration.client_certificate.ca_certificate
  }
}
