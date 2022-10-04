# Resource Group
resource "azurerm_resource_group" "rg1" {
  name     = var.rg
  location = var.location
}

## Web server
locals {
  instance_count = 2
}

resource "azurerm_linux_virtual_machine" "webvm" {
  count                           = local.instance_count
  name                            = "web-vm${count.index}"
  resource_group_name             = var.rg
  location                        = var.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = var.passwordos
  availability_set_id             = azurerm_availability_set.avset.id
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.nicweb[count.index].id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

## App server
resource "azurerm_linux_virtual_machine" "appvm" {
  name                            = "app-vm"
  resource_group_name             = var.rg
  location                        = var.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = var.passwordos
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.nicapp.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

#DB Server
resource "azurerm_virtual_machine" "dbvm" {
  name                  = "db-vm"
  location              = var.location
  resource_group_name   = var.rg
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS14_v2"

  storage_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2017-WS2016"
    sku       = "SQLDEV"
    version   = "latest"
  }

  storage_os_disk {
    name              = "db-OSDisk"
    caching           = "ReadOnly"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "winhost01"
    admin_username = "dbvmadmin"
    admin_password = var.passworddb
  }

  os_profile_windows_config {
    timezone                  = "Pacific Standard Time"
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }
}

resource "azurerm_mssql_virtual_machine" "db" {
  virtual_machine_id = azurerm_virtual_machine.dbvm.id
  sql_license_type   = "PAYG"
}