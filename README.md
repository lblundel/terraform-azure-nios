# terraform-azure-nios

This Terraform module deploys one or more Infoblox NIOS (Network Identity Operating System) virtual machines (VMs) on Microsoft Azure. It automates the creation of all required Azure resources, including network interfaces, public IPs, network security groups, and VM shutdown schedules, to provide a ready-to-use Infoblox NIOS environment.

## Features

- Deploys one or more NIOS VMs using a map variable for flexible instance configuration.
- Creates and attaches LAN and MGMT network interfaces.
- Assigns static public IP addresses.
- Configures Azure Network Security Groups with rules for DNS, SSH, HTTPS, and Infoblox Grid traffic.
- Supports VM shutdown schedules with notification emails.
- Supports custom admin credentials, VM sizing, and tagging.
- Integrates with Ansible for post-provisioning automation (optional).

## Usage

```hcl
module "nios_vm" {
  source = "github.com/lblundel/terraform-azure-nios"

  vm_name_prefix              = "nios"
  admin_username              = var.admin_username
  admin_password              = var.admin_password
  location                    = var.location
  resource_group_name         = azurerm_resource_group.this.name
  vm_size                     = "Standard_D2s_v3"
  storage_account_name        = azurerm_storage_account.storage_account.name
  vnet_lan1_subnet_id         = module.vnet.subnets["lan1"].resource_id
  vnet_mgmt_subnet_id         = module.vnet.subnets["mgmt"].resource_id
  shutdown_notification_email = var.shutdown_notification_email
  tags                        = var.tags
  
  // deploy these instances
  instances = {
    "vm1" = {
      zone           = "1"
      lan1_nic_name  = "nios-vm1-lan1"
      mgmt_nic_name  = "nios-vm1-mgmt"
    }
    "vm2" = {
      zone           = "2"
      lan1_nic_name  = "nios-vm2-lan1"
      mgmt_nic_name  = "nios-vm2-mgmt"
    }
  }
}
```

## Inputs

| Name                        | Description                                      | Type   | Default | Required |
|-----------------------------|--------------------------------------------------|--------|---------|----------|
| `vm_name_prefix`            | Prefix for VM names                              | string | n/a     | yes      |
| `admin_username`            | Admin username for the VM                        | string | n/a     | yes      |
| `admin_password`            | Admin password for the VM                        | string | n/a     | yes      |
| `location`                  | Azure region                                     | string | n/a     | yes      |
| `resource_group_name`       | Name of the resource group                       | string | n/a     | yes      |
| `vm_size`                   | Azure VM size                                    | string | n/a     | yes      |
| `storage_account_name`      | Storage account name for boot diagnostics        | string | n/a     | yes      |
| `vnet_lan1_subnet_id`       | Subnet ID for LAN1 NIC                           | string | n/a     | yes      |
| `vnet_mgmt_subnet_id`       | Subnet ID for MGMT NIC                           | string | n/a     | yes      |
| `shutdown_notification_email` | Email for VM shutdown notifications            | string | n/a     | yes      |
| `tags`                      | Tags to apply to resources                       | map    | `{}`    | no       |
| `instances`                 | Map of VM instance configs (see example above)   | map    | n/a     | yes      |

## Outputs

- `nios_vm_ids` – IDs of the deployed NIOS VMs.
- `nios_vm_public_ips` – Public IP addresses of the NIOS VMs.
- `nios_vm_private_ips` – Private IP addresses of the NIOS VMs.

## Example: Deploying Two NIOS VMs

```hcl
module "nios_vm" {
  source = "./modules/terraform-azure-nios"
  # ...other variables...
  instances = {
    "vm1" = {
      zone           = "1"
      lan1_nic_name  = "nios-vm1-lan1"
      mgmt_nic_name  = "nios-vm1-mgmt"
    }
    "vm2" = {
      zone           = "2"
      lan1_nic_name  = "nios-vm2-lan1"
      mgmt_nic_name  = "nios-vm2-mgmt"
    }
  }
}
```

## Requirements

- Terraform >= 1.9
- AzureRM provider >= 3.74
- Ansible provider (optional, for automation)

## License

MIT
