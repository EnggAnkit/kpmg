###This section is to create Azure Load Balancer

# Creating Availablilty Set as VM need to in AV set to use LB of Basic SKU
resource "azurerm_availability_set" "avset" {
  name                         = "webavset"
  location                     = var.location
  resource_group_name          = var.rg
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

# Creating LoadBalancer

resource "azurerm_lb" "wlb" {
  name                = "web-lb"
  location            = var.location
  resource_group_name = var.rg

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "backend" {
  resource_group_name = var.rg
  loadbalancer_id     = azurerm_lb.wlb.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_nat_rule" "natrule" {
  resource_group_name            = var.rg
  loadbalancer_id                = azurerm_lb.wlb.id
  name                           = "HTTPSAccess"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.wlb.frontend_ip_configuration[0].name
}

resource "azurerm_network_interface_backend_address_pool_association" "lb-backend" {
  count                   = local.instance_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
  ip_configuration_name   = "internal"
  network_interface_id    = element(azurerm_network_interface.nicweb.*.id, count.index)
}