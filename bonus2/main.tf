provider "azurerm" {
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  features {}
}

data "azurerm_resource_group" "bonus2" {
  name = "bonus2RG"
}

output "id" {
  value = data.azurerm_resource_group.bonus2.id
}

data "azurerm_image" "bonus2" {
  name                = "bonus2Image"
  resource_group_name = "bonus2RG"
}

output "image_id" {
  value = "/subscriptions/XXXXXXXX/resourceGroups/RG-EASTUS-SPT-PLATFORM/providers/Microsoft.Compute/images/bonus2Image"
}

resource "azurerm_network_security_group" "bonus2" {
  name                = "bonus2-SG"
  location            = data.azurerm_resource_group.bonus2.location
  resource_group_name = data.azurerm_resource_group.bonus2.name

  security_rule {
    name                       = "bonus2-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "bonus2" {
  name                = "bonus2-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.bonus2.location
  resource_group_name = data.azurerm_resource_group.bonus2.name
}

resource "azurerm_subnet" "bonus2" {
  name                 = "bonus2-subnet"
  resource_group_name  = data.azurerm_resource_group.bonus2.name
  virtual_network_name = azurerm_virtual_network.bonus2.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "bonus2" {
  name                = "bonus2-public-ip"
  resource_group_name = data.azurerm_resource_group.bonus2.name
  location            = data.azurerm_resource_group.bonus2.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "bonus2" {
  name                = "bonus2-nic"
  location            = data.azurerm_resource_group.bonus2.location
  resource_group_name = data.azurerm_resource_group.bonus2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bonus2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bonus2.id
  }
}

resource "azurerm_virtual_machine" "bonus2VM" {
  name                             = "bonus2VM"
  location                         = data.azurerm_resource_group.bonus2.location
  resource_group_name              = data.azurerm_resource_group.bonus2.name
  network_interface_ids            = ["${azurerm_network_interface.bonus2.id}"]
  vm_size                          = "Standard_DS12_v2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = "${data.azurerm_image.bonus2.id}"
  }

  storage_os_disk {
    name              = "bonus2VM-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
}

  os_profile {
    computer_name  = "Ansible-VM"
    admin_username = "Ansible"
    admin_password = "Ansible123"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  
  tags = {
    environment = "Production"
  }
}