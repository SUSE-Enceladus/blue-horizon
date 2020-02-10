0. Prerequisites
  * Create an Azure Service Principal
    ```
    az ad sp create-for-rbac
    ```
    Note the SP must have sufficient privileges, the created account must have at least Contributor and DNS Zone Contributor roles. The data provided as output from this function will be required in the terraform variables.

  * Create a Resource Group
    ```
    az group create --name $(az_resource_group) --location $(location)
    ```
    This resource group will contain all resources of, and in support of your SUSE CAP cluster. Make note of the _name_ and _location_ which must be supplied in terraform variables.

  * Create a DNS zone
    ```
    az network dns zone create -g $(az_resource_group) -n $(dns_zone_name)
    ```
    The DNS zone will host the cluster's DNS records in a specific domain name. Make note of the _name_ which must be supplied in terraform variables. See https://docs.microsoft.com/en-us/azure/dns/ for details on setting up a DNS zone.

1. Create a `terraform.tfvars` or update the `terraform.tfvars.json` (should be in your `.gitignore` or outside source control as it contains sensitive information) file with the following information
  - `instance_count` - The number of worker nodes in your cluster. (Minimum: 3, Maximum 50)
  - `instance_type` - The type of instance used for the provisioned workers.
  - `subscription_id` - Azure subscription ID
  - `resource_group` - An existing Azure Resource Group where resources will be created.
  - `location` - The Azure region where the Resource Group is placed.
  - `client_id` - Azure Service Principal 'appId'
  - `client_secret` - Azure Service Principal 'password'
  - `tenant_id` - "Azure Service Principal 'tenant'"
  - `ssh_username` - SSH username for accessing the cluster.
  - `ssh_public_key` - SSH public key for access to worker nodes.
  - `k8s_version` - Kubernetes version to apply to AKS; must be supported in the selected region. (Run `az aks get-versions --location $REGION --output table` for a list of supported options)
  - `disk_size_gb` - The worker node storage capacity. (Minimum:80, Maximum: 4095)
  - `cluster_labels` - Tags to be applied to resources in your cluster. (Optional)
  - `dns_zone_name` - Name of the Azure DNS Zone created for the cluster.
  - `cap_domain` - The FQDN of your cluster.
  - `dns_prefix` - Prefix for node DNS hostnames. (Must be alphanumeric, may include but not end with dashes)
  - `email` - Email address to send TLS certificate notifications to.

2. In the helm chart values yaml use the following values to allow `cert-manager` to generate certificates for the ingress endpoints, you may use the scf-config-values.yaml as a reference:

  ```
  ingress:
    enabled: true
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: 1024m
      certmanager.k8s.io/cluster-issuer: letsencrypt-prod
      certmanager.k8s.io/acme-challenge-type: dns01
      certmanager.k8s.io/ace-dns01-provider: azuredns
  ```

  If you change the values of the annotations above you'll need to make corresponding changes in the cert-manager setup (see the `cert-manager.tf` template and the associated scripts)

3. `terraform init`

4. `terraform plan -out <PLAN-path>`

5. `terraform apply plan <PLAN-path>`

6. A kubeconfig named `aksk8scfg` is generated in the same directory TF is run from. Set your `KUBECONFIG` env var to point to this file.

7. The `helm install`s should have been triggered as part of step 5. Check the pods in uaa, scf, stratos and metrics namespace to make sure they all come up and are ready.
