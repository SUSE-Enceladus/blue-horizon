provider "kubernetes" {
  version = "~> 1.5"
  load_config_file = false
  host                   = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)}"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true

  depends_on = ["null_resource.post_processor"]
}

resource "kubernetes_cluster_role_binding" "tiller" {
    metadata {
        name = "tiller"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        kind = "ServiceAccount"
        name = "tiller"
        namespace = "kube-system"
    }
    depends_on = ["kubernetes_service_account.tiller"]
}

resource "kubernetes_storage_class" "akssc" {
  metadata  {
    name = "persistent"
  }
  storage_provisioner = "kubernetes.io/azure-disk"
  parameters = {
    storageaccounttype = "Premium_LRS"
    kind = "managed" 
  }
}