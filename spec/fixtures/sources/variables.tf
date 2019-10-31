variable "resource_group" {
    type = "string"
    description = "Name of the resource group where CAP will be deployed."
}

variable "location" {
    type = "string"
}

variable "instance_count" {
    type = "number"
    default = 1
}

variable "instance_type" {
    default = "Standard_DS4_v2"
}

variable "agent_admin" {
    type = "string"
}

variable "dns_prefix" {
    default = "cap-on-aks"
}

variable "cluster_labels" {
    type = "map"
}

variable "disk_size_gb" {
    type = "number"
    default = 60
}

variable "client_id" {
    type = "string"
}

variable "client_secret" {
    type = "string"
}

variable "ssh_public_key" {
    type = "string"
}

variable "azure_dns_json" {
    type = "string"
}

variable "are_you_sure" {
    type = "boolean"
}

variable "test_list" {
    type = "list"
}

variable "empty_number" {
    type = "number"
}

variable "test_description" {
    description = "test description"
}
