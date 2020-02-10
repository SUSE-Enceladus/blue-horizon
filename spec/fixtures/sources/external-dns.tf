resource "helm_release" "external-dns" {
    name = "cap-external-dns"
    chart = "stable/external-dns"
    wait = "false"

    set {
        name = "provider"
        value = "azure"
    }

    set {
        name = "logLevel"
        value = "debug"
    }

    set {
        name = "azure.resourceGroup"
        value = "${var.resource_group}"
    }
    set {
        name = "azure.tenantId"
        value = "${var.tenant_id}"
    }
    set {
        name = "azure.subscriptionId"
        value = "${var.subscription_id}"
    }
    set {
        name = "azure.aadClientId"
        value = "${var.client_id}"
    }
    set {
        name = "azure.aadClientSecret"
        value = "${var.client_secret}"
    }

    set {
        name = "rbac.create"
        value = "true"
    }

    depends_on = ["kubernetes_cluster_role_binding.tiller"]
}
