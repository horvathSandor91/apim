resource "azurerm_application_insights" "shsz-apim-insight" {
  name                = "shsz-apim-insight"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.shsz-log-an.id
}

resource "azurerm_log_analytics_workspace" "shsz-log-an" {
  name                = "shsz-log-an"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_api_management" "sh-apim" {
  name                = var.sh_apim
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = "Zeiss DI Training"
  publisher_email     = "sandor.horvath@zeiss.com"

  sku_name = "Consumption_0"
}

resource "azurerm_api_management_logger" "shsz-apim-logger" {
  name                = "shsz-apim-logger"
  api_management_name = azurerm_api_management.sh-apim.name
  resource_group_name = var.resource_group_name
  resource_id         = azurerm_application_insights.shsz-apim-insight.id

  application_insights {
    instrumentation_key = azurerm_application_insights.shsz-apim-insight.instrumentation_key
  }
}

resource "azurerm_api_management_api" "sh-api" {
  name                = "shsz-api"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.sh-apim.name
  revision            = "1"
  display_name        = "SH API"
  path                = "api/health-check"
  protocols           = ["https"]

  import {
    content_format = "openapi"
    content_value  = file("${path.module}/health-check.yaml")
  }
}


# Configure Managed Identity Token Validation
# resource "azurerm_api_management_policy" "managed_identity_policy" {
#   api_management_id = azurerm_api_management.sh-apim.id
#   xml_content = <<XML
#   <policies><inbound><authentication-managed-identity resource="18c6d653-5b98-4c79-a12e-addac75ed67d" ignore-error="false" /></inbound></policies>
# XML
# }

