variable "cluster_name" {
  description = "Talos cluster name"
  type        = string
  default     = "talos"
  sensitive   = false
}

variable "cluster_vip" {
  description = "Talos cluster control plane VIP"
  type        = string
  nullable    = true
  sensitive   = false
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes cluster version"
  type        = string
  sensitive   = false
  default     = "v1.33.3"
}

variable "talos_nodes" {
  type = map(object({
    ip_address   = string
    ip_subnet    = number
    machine_type = string
  }))
}

variable "talos_version" {
  description = "Talos node version"
  type        = string
  sensitive   = false
  default     = "v1.10.6"
}
