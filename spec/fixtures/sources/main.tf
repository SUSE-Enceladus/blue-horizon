resource "random_string" "cluster_name" {
  length  = 18
  special = false
  upper   = false
  number  = false
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "cap-${random_string.cluster_name.result}"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group}"
    dns_prefix          = "${var.dns_prefix}"

    linux_profile {
        admin_username = "${var.agent_admin}"

        ssh_key {
            key_data = "${file("${var.ssh_public_key}")}"
        }
    }

    agent_pool_profile {
        name            = "agentpool"
        count           = "${var.instance_count}"
        vm_size         = "${var.instance_type}"
        os_type         = "Linux"
        os_disk_size_gb = "${var.disk_size_gb}"
    }

    service_principal {
        client_id     = "${var.client_id}"
        client_secret = "${var.client_secret}"
    }

    tags = "${var.cluster_labels}"
}

resource "null_resource" "post_processor" {

  provisioner "local-exec" {
    command = "/bin/sh aks-post-processing.sh"

    environment = {
      AKSNAME = "${azurerm_kubernetes_cluster.k8s.name}"
      RGNAME = "${var.resource_group}"
      CLUSTER_NAME = "${azurerm_kubernetes_cluster.k8s.name}"
      NODEPOOLNAME = "agentpool"
    }
  }
}

locals {
  k8scfg = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
}

output "kube_config" {
  value = "${local.k8scfg}"
}

resource "local_file" "k8scfg" {
  content = "${local.k8scfg}"
  filename = "aksk8scfg"
}
