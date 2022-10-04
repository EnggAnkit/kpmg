## This section is to create NSG's and attach it with subnets

# Creating NSG for web server and attaching it with web subnet
resource "azurerm_network_security_group" "nsg_web" {
  name                = "web-nsg"
  location            = var.location
  resource_group_name = var.rg
  security_rule {
    name                       = "https"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"            
    source_port_range          = "*"
    destination_port_range     = "443"
    destination_address_prefix = azurerm_subnet.web_subnet.address_prefix
  }
      security_rule {
    name                       = "ssh_Rule"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"                # Define Jump box
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
}

resource "azurerm_subnet_network_security_group_association" "web-nsg-subnet" {
  subnet_id                 = azurerm_subnet.web_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_web.id
}

# Creating NSG for app server and attaching it with app subnet
resource "azurerm_network_security_group" "nsg_app" {
  name                = "app-nsg"
  location            = var.location
  resource_group_name = var.rg

  security_rule {
    name                       = "https"          
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = azurerm_network_interface.nicweb.private_ip_address
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "443"           
  }
    security_rule {
    name                       = "ssh_Rule"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"                # Define Jump box
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }
}

resource "azurerm_subnet_network_security_group_association" "app-nsg-subnet" {
  subnet_id                 = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}

# Creating NSG for db server and attaching it with db subnet and nic
resource "azurerm_network_security_group" "nsg_db" {
  name                = "db-nsg"
  location            = var.location
  resource_group_name = var.rg
  security_rule {
    name                       = "RDP_Rule"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"              # Define Jump box IP/IPrange   
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "3389"
  }
  security_rule {
    name                       = "MSSQL_Rule"
    priority                   = 1011
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = azurerm_network_interface.nicapp.private_ip_address
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "1433"
  }
    security_rule {
    name                       = "Deny_Rule"
    priority                   = 10000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "db-nsg-subnet" {
  subnet_id                 = azurerm_subnet.db_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}

resource "azurerm_network_interface_security_group_association" "db-nsg-nic" {
  network_interface_id      = azurerm_network_interface.nicdb.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}