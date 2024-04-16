resource "azurerm_service_plan" "shsz-fapp-service-plan" {
  name                = "shsz-fapp-service-plan01378"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "sh-linux-function-app" {
  name                = "sh-linux-function-app01378"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = var.storage_name  #module.storage.storage-out.name
  storage_account_access_key = var.saakey #module.storage.storage-out.primary_access_key
  service_plan_id            = azurerm_service_plan.shsz-fapp-service-plan.id

  site_config {
   # application_insights_connection_string = var.insight
   # application_insights_key = var.insightkey
  }
  
}

resource "azurerm_monitor_diagnostic_setting" "function_app_diagnostic_setting" {
  name                = "function-app-insights-diagnostic-setting01378"
  storage_account_id  =  var.storage_id
  target_resource_id  =  azurerm_linux_function_app.sh-linux-function-app.id  # Replace with your Function App resource ID


#    enabled_log {
#      category = "FunctionApplicationLogs"
#    }

  metric {
    category = "AllMetrics"
  }
}