# nested values in terraform file

resource "azurerm_resource_group" "rg1" {
  name     = "vnet-testrg"
  location = "west us"
}

# vNet creation
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet1"
  address_space       = ["10.130.0.0/16"]
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "subnet_app"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.130.1.0/24"]
}

resource "azurerm_network_interface" "nicapp" {
  name                = "nic-app"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

output "subnetid" {
	value = azurerm_subnet.app_subnet.id
}