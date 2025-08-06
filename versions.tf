terraform {
  required_version = ">= 1.10.3"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0-alpha.0"
    }
  }
}


