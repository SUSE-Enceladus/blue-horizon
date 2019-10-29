provider "azurerm" {
  # Remember to set the env variables ARM_TENANT_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET and ARM_SUBSCRIPTION_ID
  # to allow the SP to login to Azure. 
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "~> 1.27"
}

terraform {
# If you want to use the Azure backend storage accounts to save Terraform state, uncomment the following block. You 
# will have to set the ARM_ACCESS_KEY for the storage account acccess.
#  backend "azurerm" {
#    
#  }
}
