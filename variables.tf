variable "admin_password" {
  description = "The admin password for the Linux VM"
  type        = string
  sensitive   = true
}

variable "admin_username" {
  description = "The admin username for the Linux VM"
  type        = string
  default     = "f6ffa7q2bd3iy"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "vm_size" {
  description = "The size of the NIOS VM"
  type        = string
  default     = "Standard_DS11_v2"
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
}

variable "shutdown_notification_email" {
  description = "The email address to send shutdown notifications to"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default = {}
}

variable "vnet_lan1_subnet_id" {
  description = "The ID of the lan1 subnet to deploy the VM into"
  type        = string
}

variable "vnet_mgmt_subnet_id" {
  description = "The ID of the mgmt subnet to deploy the VM into"
  type        = string
}

variable "vm_name_prefix" {
  description = "Name prefix of the NIOS VM"
  type        = string
}

variable "instances" {
  description = "number of NIOS VM instances to deploy"
  type = any
  default = {
    "vm1" = {
      "lan1_nic_name" = "vm1-lan1-nic"
      "mgmt_nic_name" = "vm1-mgmt-nic"
      "ha_nic_name"   = "vm1-ha-nic"
      "zone"          = "1"
    }
    "vm2" = {
      "lan1_nic_name" = "vm2-lan1-nic"
      "mgmt_nic_name" = "vm2-mgmt-nic"
      "ha_nic_name"   = "vm2-ha-nic"
      "zone"          = "2"
    }
  }
}
