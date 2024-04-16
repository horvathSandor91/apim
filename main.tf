provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "key-vault" {
  source              = "./Modules/key-vault"
  kv_name             = var.kv_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

module "network" {
  source              = "./Modules/network"
  subnet_name         = var.subnet_name
  nsg_name            = var.nsg_name
  sh_pip              = var.sh_pip
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kv_id               = module.key-vault.kv-out.id
}

module "storage" {
  source              = "./Modules/storage"
  saq_name            = var.saq_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sh_sc               = var.sh_sc
  sh_blob             = var.sh_blob
  kv-key-name         = module.key-vault.kv-key.name
  kv-id               = module.key-vault.kv-out.id

  depends_on = [module.key-vault]
}

module "apim" {
  source              = "./Modules/apim"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sh_apim             = var.sh_apim
}

module "apigtw" {
  source              = "./Modules/apigtw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  appgtw              = var.appgtw
  network-name        = module.network.network-output.name
  subnet-id           = module.network.subnet.id
  network-pip-id      = module.network.pip.id

}

module "function" {
  source              = "./Modules/function"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  storage_name        = module.storage.storage-out.name
  saakey              = module.storage.storage-out.primary_access_key
  storage_id          = module.storage.storage-out.id
  #insight             = module.apim.appinsight.application_insights_connection_string
  #insightkey          = module.apim.appinsight.application_insights.instrumentation_key
}




# since these variables are re-used - a locals block makes this more maintainable
#locals {
#  backend_address_pool_name      = "${var.network-name.name}-beap"
#  frontend_port_name             = "${var.network-name.name}-feport"
#  frontend_ip_configuration_name = "${var.network-name.name}-feip"
#  http_setting_name              = "${var.network-name.name}-be-htst"
#  listener_name                  = "${var.network-name.name}-httplstn"
#  request_routing_rule_name      = "${var.network-name.name}-rqrt"
#  redirect_configuration_name    = "${var.network-name.name}-rdrcfg"
#}
#
#resource "azurerm_application_gateway" "network" {
#  name                = var.appgtw
#  resource_group_name = azurerm_resource_group.rg.name
#  location            = azurerm_resource_group.rg.location
#
#  sku {
#    name     = "Standard_v2"
#    tier     = "Standard_v2"
#    capacity = 2
#  }
#
#  gateway_ip_configuration {
#    name      = "sh-gateway-ip-configuration"
#    subnet_id = module.network.subnet.id
#  }
#
#  frontend_port {
#    name = local.frontend_port_name
#    port = 80
#  }
#
#  frontend_ip_configuration {
#    name                 = local.frontend_ip_configuration_name
#    public_ip_address_id = module.network.pip.id
#  }
#
#  backend_address_pool {
#    name = local.backend_address_pool_name
#  }
#
#  backend_http_settings {
#    name                  = local.http_setting_name
#    cookie_based_affinity = "Disabled"
#    path                  = "/path1/"
#    port                  = 80
#    protocol              = "Http"
#    request_timeout       = 60
#  }
#
#  http_listener {
#    name                           = local.listener_name
#    frontend_ip_configuration_name = local.frontend_ip_configuration_name
#    frontend_port_name             = local.frontend_port_name
#    protocol                       = "Http"
#  }
#
#  request_routing_rule {
#    name                       = local.request_routing_rule_name
#    priority                   = 9
#    rule_type                  = "Basic"
#    http_listener_name         = local.listener_name
#    backend_address_pool_name  = local.backend_address_pool_name
#    backend_http_settings_name = local.http_setting_name
#  }
#}
#
#module "apigtw" {
#  source              = "./Modules/apigtw"
#  resource_group_name = azurerm_resource_group.rg.name
#  location            = azurerm_resource_group.rg.location
#  appgtw              = var.appgtw
#
#}


#resource "azurerm_policy_definition" "nsg_operations_policy" {
#  name         = "Allow NSG Operations"
#  display_name = "Allow NSG Operations"
#  description  = "Allows Network Security Group operations, including creation and update, for a specific NSG."
#  policy_type  = "Custom"
#  mode         = "All"
#
#
#  policy_rule = jsonencode({
#    "if" : {
#      "allOf" : [
#        {
#          "field" : "type",
#          "equals" : "Microsoft.Network/networkSecurityGroups"
#        },
#        {
#          "not" : {
#            "field" : "name",
#            "equals" : "shnsg0013"
#          }
#        }
#      ]
#    },
#    "then" : {
#      "effect" : "audit"
#    }
#  })
#}





## Configure Application Gateway Listener with SSL
#resource "azurerm_application_gateway_listener" "example" {
#  name                                = "example-listener"
#  resource_group_name                 = azurerm_resource_group.example.name
#  application_gateway_name            = azurerm_application_gateway.example.name
#  frontend_ip_configuration_name      = azurerm_application_gateway_frontend_ip_configuration.example.name
#  frontend_port_name                  = "https"
#  protocol                            = "Https"
#  ssl_certificate_name                = "example-ssl-cert"
#}
#
## Enable Client Certificate Authentication
#resource "azurerm_application_gateway_ssl_certificate" "example" {
#  name                = "example-ssl-cert"
#  resource_group_name = azurerm_resource_group.example.name
#  application_gateway_name = azurerm_application_gateway.example.name
#  public_cert_data     = "-----BEGIN CERTIFICATE-----\nYour SSL Certificate Here\n-----END CERTIFICATE-----"
#}
#
## Configure Backend Pools and Routing Rules
## Define backend pools for Key Vault and Storage Queue
#
## Integrate Application Gateway with Virtual Network
#resource "azurerm_application_gateway_subnet_configuration" "example" {
#  name                 = "example-subnet"
#  application_gateway_name = azurerm_application_gateway.example.name
#  subnet_id            = azurerm_subnet.example.id
#}
#
## Configure Client Certificate Authentication for Application Gateway
##resource "azurerm_application_gateway_ssl_certificate" "client_cert" {
##  name            = "client-certificate"
##  application_gateway_id = azurerm_application_gateway.network.id
#  data            = filebase64("${path.module}/client-certificate.pfx")
#  password        = "your-certificate-password"
// Other necessary configurations
#}

# Configure VNET integration
#resource "azurerm_virtual_network_gateway" "vnet_gateway" {
#  name                = "sh-test"
#  location            = var.location
#  resource_group_name = var.resource_group_name
#
#  type     = "Vpn"
#  vpn_type = "RouteBased"
#
#  active_active = false
#  enable_bgp    = false
#  sku           = "VpnGw1AZ"
#
#  ip_configuration {
#    name                          = "vnetGatewayConfig"
#    public_ip_address_id          = azurerm_public_ip.sh-pip.id
#    private_ip_address_allocation = "Dynamic"
#    subnet_id                     = azurerm_subnet.sh-subnet.id
#  }
#}



# # Configure RBAC role assignments for Key Vault and Storage Account
#resource "azurerm_role_assignment" "kv_role_assignment" {
#  scope                = azurerm_key_vault.kv.id
#  role_definition_name = "Contributor"
#  principal_id         = "d2cee13b-4515-4c4b-a61f-9e784d3855c2"
#}

#resource "azurerm_role_assignment" "sa_role_assignment" {
#  scope                = azurerm_storage_account.sa.id
#  role_definition_name = "Contributor"
#  principal_id         = "744d2705-1c2d-443f-a2f4-6dc5e7593105"
#}
#
#
