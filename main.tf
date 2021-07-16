provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "web_server_rg" {
    name = var.web_server_rg
    location = var.web_server_location
}
resource "azurerm_virtual_network" "web_server_net" {
    name = "${var.resource_prefix}-vnet"
    location = var.web_server_location
    resource_group_name = azurerm_resource_group.web_server_rg.name
    address_space = [var.web_server_address_space]
}
resource "azurerm_subnet" "web_server_subnet" {
    name = "${var.resource_prefix}-subnet"
    resource_group_name = azurerm_resource_group.web_server_rg.name
    virtual_network_name = azurerm_virtual_network.web_server_net.name
    address_prefix = var.web_server_address_prefix
}

resource "azurerm_network_interface" "web_server_nic" {
    name = "${var.web_server_name}-nic"
    location = var.web_server_location
    resource_group_name = azurerm_resource_group.web_server_rg.name
    ip_configuration {
        name = "${var.web_server_name}-ip"
        subnet_id = azurerm_subnet.web_server_subnet.id
        private_ip_address_allocation = "dynamic"
    }
}

resource "azurerm_public_ip" "web_server_public_ip" {
    name = "${var.resource_prefix}-public-ip"
    location = var.web_server_location
    resource_group_name = azurerm_resource_group.web_server_rg.name
    allocation_method = var.environment == "production" ? "Static" : "Dynamic"
}

resource "azurerm_network_security_group" "web_server_nsg" {
    name = "${var.resource_prefix}-nsg"
    location = var.web_server_location
    resource_group_name = azurerm_resource_group.web_server_rg.name
    
}

resource "azurerm_network_security_rule" "web_server_nsg_rule_rdp" {
 name                        = "RDP Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.web_server_rg.name
  network_security_group_name = azurerm_network_security_group.web_server_nsg.name
}
resource "azurerm_network_interface_security_group_association" "web_server_nsg_association" {
  network_interface_id      = azurerm_network_interface.web_server_nic.id 
  network_security_group_id = azurerm_network_security_group.web_server_nsg.id
}

resource "azurerm_windows_virtual_machine" "web_server" {
  name                = var.web_server_name
  resource_group_name = azurerm_resource_group.web_server_rg.name 
  location            = var.web_server_location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.web_server_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}





















