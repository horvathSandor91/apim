data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "sa" {
  name                     = "${lower(var.saq_name)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  identity {
  type = "SystemAssigned"
  
  }


}

resource "azurerm_storage_container" "sh-sc" {
  name                  = var.sh_sc
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "sh-blob" {
  name                   = var.sh_blob
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.sh-sc.name
  type                   = "Block"
}


resource "azurerm_container_registry" "crshszsanyi" {
  name                = "crshszsanyi03"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

# RBAC Role Setup
#resource "azurerm_role_assignment" "sh-rbac" {
#  scope                = azurerm_storage_queue.shstgrqueue.id
#  role_definition_name = "Storage Queue Data Contributor"
#  principal_id         = azurerm_api_management.sh-apim.identity[0].principal_id
#}

# Define Storage Queue
resource "azurerm_storage_queue" "shstgrqueue" {
  name                  = "shsz013-queue"
  storage_account_name  = azurerm_storage_account.sa.name
}

# settings within sa , which key will be used
resource "azurerm_storage_account_customer_managed_key" "sa-sh-cmk" {
  storage_account_id = azurerm_storage_account.sa.id
  key_vault_id       = var.kv-id
  key_name           = var.kv-key-name

  depends_on = [azurerm_key_vault_access_policy.sh-policy ]
}

resource "azurerm_key_vault_access_policy" "sh-policy" {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_storage_account.sa.identity.0.principal_id
    key_vault_id = var.kv-id
    key_permissions = [  "UnwrapKey", "WrapKey", "GetRotationPolicy", "Get"  ]

}

resource "azurerm_storage_table" "shsz-satable" {
  name                 = "shszsatable"
  storage_account_name = azurerm_storage_account.sa.name
}

# resource "azurerm_role_assignment" "kv_role_sa_kvcseu" {
#   scope                = var.kv-id
#   role_definition_name = "Key Vault Crypto Service Encryption User"
#   principal_id         = azurerm_storage_account.sa.identity.0.principal_id
# }