
resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location
}

resource "azurerm_virtual_network" "app_network" {
  name                = var.app_environment.production.virtualnetworkname
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = [var.app_environment.production.virtualnetworkcidrblock]
}
resource "azurerm_subnet" "app_network_subnets" {
  for_each = var.app_environment.production.subnets
  name = each.key
  resource_group_name = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes = [each.value.cidrblock]
}

resource "azurerm_network_interface" "webinterfaces" {
  #count=var.network_interface_count
  for_each = var.app_environment.production.subnets["websubnet01"].machines
  name                = each.value.networkinterfacename
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_network_subnets["websubnet01"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.webip[each.key].id
  }
}

resource "azurerm_network_interface" "appinterfaces" {
  #count=var.network_interface_count
  for_each = var.app_environment.production.subnets["appsubnet01"].machines
  name                = each.value.networkinterfacename
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_network_subnets["appsubnet01"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.appip[each.key].id
  }
}
resource "azurerm_public_ip" "webip" {
 # count = var.network_interface_count
 for_each = var.app_environment.production.subnets["websubnet01"].machines
  name = each.value.publicipaddressname
  resource_group_name =azurerm_resource_group.appgrp.name
  location = local.resource_location
  allocation_method ="Static"
}

resource "azurerm_public_ip" "appip" {
 # count = var.network_interface_count
 for_each = var.app_environment.production.subnets["appsubnet01"].machines
  name = each.value.publicipaddressname
  resource_group_name =azurerm_resource_group.appgrp.name
  location = local.resource_location
  allocation_method ="Static"
}


resource "azurerm_network_security_group" "app_nsg" {

  name = "app-nsg"
  location = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  dynamic security_rule {
    for_each = local.networksecuritygroup_rules
    content {
      
    
    name = "Allow-${security_rule.value.destination_port_range}"
    priority = security_rule.value.priority
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = security_rule.value.destination_port_range
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  }
  
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  for_each = azurerm_subnet.app_network_subnets
  subnet_id = azurerm_subnet.app_network_subnets[each.key].id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
  
}
resource "azurerm_windows_virtual_machine" "webvm" {
  for_each = var.app_environment.production.subnets["websubnet01"].machines
  #count = var.network_interface_count
  name                = each.key
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = local.resource_location
  size                = "Standard_B2s"
  admin_username      = "appadmin"
  admin_password      =  var.adminpassword
  #zone = (count.index)+1
  vm_agent_platform_updates_enabled = true
  #availability_set_id = azurerm_availability_set.appset.id
  network_interface_ids = [
    azurerm_network_interface.webinterfaces[each.key].id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "appvm" {
  for_each = var.app_environment.production.subnets["appsubnet01"].machines
  name                = each.key
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = local.resource_location
  size                = "Standard_B1s"
  admin_username      = "linuxadmin"
  admin_password = var.adminpassword
  disable_password_authentication = false
  custom_data = data.local_file.cloudinit.content_base64
  network_interface_ids = [
    azurerm_network_interface.appinterfaces[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
data "local_file" "cloudinit" {
  filename = "cloudinit"
}






