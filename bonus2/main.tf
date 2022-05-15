terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.93.0"
    }
  }
}
provider "azurerm" {
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  features {}
}

locals {
  resource_group = "choco_vm_grp"
  location       = "Dubai"
}

resource "azurerm_public_ip" "choco_vm_ip" {
  name                = "chocovmip"
  resource_group_name = azurerm_resource_group.choco_vm_grp.name
  location            = azurerm_resource_group.choco_vm_grp.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

data "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  virtual_network_name = "choco_vm-network"
  resource_group_name  = local.resource_group
}

resource "azurerm_resource_group" "choco_vm_grp" {
  name     = local.resource_group
  location = local.location
}

resource "azurerm_virtual_network" "choco_vm_network" {
  name                = "choco_vm-network"
  location            = local.location
  resource_group_name = azurerm_resource_group.choco_vm_grp.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "SubnetA"
    address_prefix = "10.0.1.0/24"
  }
}

resource "azurerm_network_interface" "choco_vm_interface" {
  name                = "choco_vm-interface"
  location            = local.location
  resource_group_name = local.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network.choco_vm_network
  ]
}

resource "azurerm_windows_virtual_machine" "choco_vm" {
  name                = "chocovm"
  resource_group_name = local.resource_group
  location            = local.location
  size                = "Standard_D2s_v3"
  admin_username      = "Ansible"
  admin_password      = "Ansible@123"
  network_interface_ids = [
    azurerm_network_interface.choco_vm_interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.choco_vm_interface
  ]
}