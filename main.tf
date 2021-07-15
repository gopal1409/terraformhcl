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
