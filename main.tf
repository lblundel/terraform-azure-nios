resource "azurerm_public_ip" "public_ip" {
  for_each            = var.instances
  allocation_method   = "Static"
  domain_name_label   = "nios${each.key}"
  location            = var.location
  zones               = [each.value.zone]
  name                = "nios-public-ip-${each.key}"
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  idle_timeout_in_minutes = 30

  depends_on = [
    var.resource_group_name,
  ]
  tags = var.tags
}

resource "azurerm_network_interface" "lan1_nic" {
  for_each            = var.instances
  location            = var.location
  # name                = "nios-vm-lan1"
  name                = each.value.lan1_nic_name
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
    subnet_id                     = var.vnet_lan1_subnet_id
  }
  depends_on = [
    azurerm_public_ip.public_ip,
    var.vnet_lan1_subnet_id,
  ]
  tags = var.tags
}

resource "azurerm_network_interface" "mgmt_nic" {
  for_each            = var.instances
  location            = var.location
  # name                = "nios-vm-mgmt"
  name                = each.value.mgmt_nic_name
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.vnet_mgmt_subnet_id
  }
  depends_on = [
    var.vnet_mgmt_subnet_id,
  ]
  tags = var.tags
}

resource "azurerm_network_interface" "ha_nic" {
  for_each            = var.instances
  location            = var.location
  name                = "${each.value.ha_nic_name != null ? each.value.ha_nic_name : "nios-vm-ha-${each.key}"}"
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.vnet_lan1_subnet_id
  }
  depends_on = [
    var.vnet_lan1_subnet_id,
  ]
  tags = var.tags
}

resource "azurerm_network_security_group" "nsg" {
  location            = var.location
  name                = "nios-vm-securityGroup"
  resource_group_name = var.resource_group_name
  depends_on = [
    var.resource_group_name,
  ]
  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "lan_nic_nsg_association" {
  for_each                  = var.instances
  network_interface_id      = azurerm_network_interface.lan1_nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [
    azurerm_network_interface.lan1_nic,
    azurerm_network_security_group.nsg,
  ]
}

resource "azurerm_network_interface_security_group_association" "mgmt_nic_nsg_association" {
  for_each                  = var.instances
  network_interface_id      = azurerm_network_interface.mgmt_nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [
    azurerm_network_interface.mgmt_nic,
    azurerm_network_security_group.nsg,
  ]
}

resource "azurerm_network_interface_security_group_association" "ha_nic_nsg_association" {
  for_each                  = var.instances
  network_interface_id      = azurerm_network_interface.ha_nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [
    azurerm_network_interface.ha_nic,
    azurerm_network_security_group.nsg,
  ]
}

resource "azurerm_network_security_rule" "dns_tcp_rule" {
  access                      = "Allow"
  description                 = "Allow DNS TCP"
  destination_address_prefix  = "*"
  destination_port_range      = "53"
  direction                   = "Inbound"
  name                        = "DNS-TCP"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 202
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsg,
  ]
}

resource "azurerm_network_security_rule" "dns_udp_rule" {
  access                      = "Allow"
  description                 = "Allow DNS UDP"
  destination_address_prefix  = "*"
  destination_port_range      = "53"
  direction                   = "Inbound"
  name                        = "DNS-UDP"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 203
  protocol                    = "Udp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsg,
  ]
}


# resource "azurerm_network_security_rule" "dns_rule" {
#   access                      = "Allow"
#   description                 = "Allow DNS"
#   destination_address_prefix  = "*"
#   destination_port_range      = "53"
#   direction                   = "Inbound"
#   name                        = "DNS"
#   network_security_group_name = azurerm_network_security_group.nsg.name
#   priority                    = 101
#   protocol                    = "Udp"
#   resource_group_name         = var.resource_group_name
#   source_address_prefix       = "*"
#   source_port_range           = "*"
#   depends_on = [
#     azurerm_network_security_group.nsg,
#   ]
# }

resource "azurerm_network_security_rule" "grid_traffic_udp_1194_in_rule" {
  access                      = "Allow"
  description                 = "Allow vNIOS Grid traffic 1194 Inbound"
  destination_address_prefix  = "*"
  destination_port_range      = "1194"
  direction                   = "Inbound"
  name                        = "Grid_traffic_UDP_1194_in"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 204
  protocol                    = "Udp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsg,
  ]
}

resource "azurerm_network_security_rule" "grid_traffic_udp_1194_out_rule" {
  access                      = "Allow"
  description                 = "Allow vNIOS Grid traffic 1194 Outbound"
  destination_address_prefix  = "*"
  destination_port_range      = "1194"
  direction                   = "Outbound"
  name                        = "Grid_traffic_UDP_1194_out"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 205
  protocol                    = "Udp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsg,
  ]
}

resource "azurerm_network_security_rule" "grid_traffic_udp_2114_in_rule" {
  access                      = "Allow"
  description                 = "Allow vNIOS Grid traffic 2114 Inbound"
  destination_address_prefix  = "*"
  destination_port_range      = "2114"
  direction                   = "Inbound"
  name                        = "Grid_traffic_UDP_2114_in"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 206
  protocol                    = "Udp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsg,
  ]
}

resource "azurerm_network_security_rule" "grid_traffic_udp_2114_out_rule" {
  access                      = "Allow"
  description                 = "Allow vNIOS Grid traffic 2114 Outbound"
  destination_address_prefix  = "*"
  destination_port_range      = "2114"
  direction                   = "Outbound"
  name                        = "Grid_traffic_UDP_2114_out"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 207
  protocol                    = "Udp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsg,
  ]
}

resource "azurerm_network_security_rule" "https_rule" {
  access                      = "Allow"
  description                 = "Allow HTTPS"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  direction                   = "Inbound"
  name                        = "HTTPS"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 201
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsg,
  ]
}

resource "azurerm_network_security_rule" "ssh_rule" {
  access                      = "Allow"
  description                 = "Allow SSH"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "SSH"
  network_security_group_name = azurerm_network_security_group.nsg.name
  priority                    = 200
  protocol                    = "Tcp"
  resource_group_name         = var.resource_group_name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.nsg,
  ]
}

locals {
  nios_infoblox_config_vars = {
    remote_console_enabled = "y"
    default_admin_password = var.admin_password
    temp_license           = "nios IB-V825 enterprise dns cloud rpz"
  }
  nios_user_data = base64encode(yamlencode(local.nios_infoblox_config_vars))
}

resource "azurerm_linux_virtual_machine" "nios_vm" {
  for_each                        = var.instances
  admin_password                  = var.admin_password
  admin_username                  = var.admin_username
  disable_password_authentication = false
  location                        = var.location
  zone                            = each.value.zone
  name                            = "${var.vm_name_prefix}-${each.key}"
  network_interface_ids           = [
    azurerm_network_interface.lan1_nic[each.key].id,
    azurerm_network_interface.mgmt_nic[each.key].id,
    azurerm_network_interface.ha_nic[each.key].id
  ]
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  boot_diagnostics {
    storage_account_uri = "https://${var.storage_account_name}.blob.core.windows.net/"
  }
  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }
  plan {
    name      = "vsot"
    product   = "infoblox-vm-appliances-905"
    publisher = "infoblox"
  }
  source_image_reference {
    offer     = "infoblox-vm-appliances-905"
    publisher = "infoblox"
    sku       = "vsot"
    version   = "905.52728.0"
  }
  user_data    = local.nios_user_data
  depends_on = [
    azurerm_network_interface.lan1_nic, 
    azurerm_network_interface.mgmt_nic,
    azurerm_network_interface.ha_nic,
  ]
  tags = var.tags
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_shutdown_schedule" {
  for_each              = var.instances
  daily_recurrence_time = "2100"
  location              = var.location
  timezone              = "W. Europe Standard Time"
  virtual_machine_id    = azurerm_linux_virtual_machine.nios_vm[each.key].id
  notification_settings {
    enabled         = true
    time_in_minutes = 30
    email           = var.shutdown_notification_email
  }
  depends_on = [
    azurerm_linux_virtual_machine.nios_vm,
  ]
  tags = var.tags
}
