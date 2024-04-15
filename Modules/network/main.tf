resource "azurerm_virtual_network" "sh-network" {
  name                = "shsz-network"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "sh-subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.sh-network.name
  address_prefixes     = ["10.254.4.0/24"]
}

resource "azurerm_subnet" "sh-subnet-endpoint" {
  name                 = "shsz-endpoint"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.sh-network.name
  address_prefixes     = ["10.254.5.0/24"]
}

resource "azurerm_private_endpoint" "shsz-private-endpoint" {
  name                = "shsz-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.sh-subnet-endpoint.id

  private_service_connection {
    name                           = "shsz-privateserviceconnection"
    private_connection_resource_id = var.kv_id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}


resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_public_ip" "sh-pip" {
  name                = var.sh_pip
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku = "Standard"
}