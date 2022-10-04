# This file is to create network requirement for infrastructure.

# vNet creation
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet1"
  address_space       = var.vnetcidr
  location            = var.location
  resource_group_name = var.rg
}

# Subnet creation
resource "azurerm_subnet" "web_subnet" {
  name                 = "subnet_web"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.websubnetcidr
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "subnet_app"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.appsubnetcidr
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "subnet_db"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.dbsubnetcidr
}



### NIC ###
#NIC for web server
resource "azurerm_network_interface" "nicweb" {
  count               = local.instance_count
  name                = "nic-web${count.index}"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#NIC for app server
resource "azurerm_network_interface" "nicapp" {
  name                = "nic-app"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#NIC for db server
resource "azurerm_network_interface" "nicdb" {
  name                = "nic-db"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.db_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}


### Public IP for Azure Load Balancer
resource "azurerm_public_ip" "pip" {
  name                = "lbpip"
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = "Dynamic"
}