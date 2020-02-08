# Add SUSE Helm charts repo
data "helm_repository" "suse" {
  name = "suse"
  url  = "https://kubernetes-charts.suse.com"
}

locals {
    chart_values_file = "${path.cwd}/scf-config-values.yaml"
    stratos_metrics_config_file = "${path.cwd}/stratos-metrics-values.yaml"
}

# Install UAA using Helm Chart
resource "helm_release" "uaa" {
  name       = "scf-uaa"
  repository = "${data.helm_repository.suse.metadata.0.name}"
  chart      = "uaa"
  namespace  = "uaa"
  wait       = "false"

  values = [
    "${file("${local.chart_values_file}")}"
  ]

  depends_on = ["helm_release.external-dns", "helm_release.nginx_ingress", "null_resource.cluster_issuer_setup"]
}


resource "helm_release" "scf" {
    name       = "scf-cf"
    repository = "${data.helm_repository.suse.metadata.0.name}"
    chart      = "cf"
    namespace  = "scf"
    wait       = "false"

    values = [
        "${file("${local.chart_values_file}")}"
    ]

    depends_on = ["helm_release.uaa"]
  }


resource "helm_release" "stratos" {
    name       = "susecf-console"
    repository = "${data.helm_repository.suse.metadata.0.name}"
    chart      = "console"
    namespace  = "stratos"
    wait       = "false"

    values = [
        "${file("${local.chart_values_file}")}"
    ]

   set {
    name  = "services.loadbalanced"
    value = "true"
  }
   set {
    name  = "console.techPreview"
    value = "true"
  }


    depends_on = ["helm_release.scf"]
  }

resource "null_resource" "metrics" {

  provisioner "local-exec" {
    command = "/bin/sh deploy_metrics.sh "

    environment = {
        METRICS_FILE = "${local.stratos_metrics_config_file}"
        SCF_FILE = "${local.chart_values_file}"
        RESOURCE_GROUP = "${var.resource_group}"
        CLUSTER_NAME = "${azurerm_kubernetes_cluster.k8s.name}"
        AZ_CERT_MGR_SP_PWD = "${var.client_secret}"

    }

  }
  depends_on = ["helm_release.stratos"]
}

resource "null_resource" "update_stratos_dns" {

  provisioner "local-exec" {
    command = "/bin/sh ext-dns-stratos-svc-annotate.sh"

    environment = {
        RESOURCE_GROUP = "${var.resource_group}"
        CLUSTER_NAME = "${azurerm_kubernetes_cluster.k8s.name}"
        AZ_CERT_MGR_SP_PWD = "${var.client_secret}"
	DOMAIN="${var.cap_domain}"

    }

  }
  depends_on = ["helm_release.stratos"]
}



resource "null_resource" "update_metrics_dns" {

  provisioner "local-exec" {
    command = "/bin/sh ext-dns-metrics-svc-annotate.sh"

    environment = {
        RESOURCE_GROUP = "${var.resource_group}"
        CLUSTER_NAME = "${azurerm_kubernetes_cluster.k8s.name}"
        AZ_CERT_MGR_SP_PWD = "${var.client_secret}"
        DOMAIN="${var.cap_domain}"

    }

  }
  depends_on = ["null_resource.metrics"]
}
