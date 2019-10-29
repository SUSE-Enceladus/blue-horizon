
resource "kubernetes_secret" "azure_dns_sp_creds" {
  metadata {
    name = "azure-dns-sp-creds"
  }

  data = {
    "azure.json" = "${file("${var.azure_dns_json}")}"
  }
}
resource "helm_release" "external-dns" {
    name = "cap-external-dns"
    chart = "stable/external-dns"
    wait = "false"

    set {
        name = "azure.secretName"
        value = "${kubernetes_secret.azure_dns_sp_creds.metadata.0.name}"
    }
    set {
        name = "provider"
        value = "azure"
    }

    set {
        name = "logLevel"
        value = "debug"
    }

    set {
        name = "rbac.create"
        value = "true"
    }

    depends_on = ["kubernetes_cluster_role_binding.tiller"]
}