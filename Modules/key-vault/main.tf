
data "azurerm_client_config" "current" {}

# Create Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "kv-${var.stage_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  purge_protection_enabled = true
  soft_delete_retention_days = 90

#RBAC role setup
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    #object_id = "744d2705-1c2d-443f-a2f4-6dc5e7593105"
   

    key_permissions = [
      "List", "Get", "Create", "Delete", "Recover", "GetRotationPolicy"
    ]

    secret_permissions = [
      "List", "Get", "Set", "Delete"
    ]

    storage_permissions = [
      "List", "Get", "Set", "Delete"
    ]
  }
}

# Create Secrets in Key Vault
resource "azurerm_key_vault_secret" "sh-secret013" {
  name         = "shsz013780-secret"
  value        = "supersecret"
  key_vault_id = azurerm_key_vault.kv.id
}


# creating key in the sa 
resource "azurerm_key_vault_key" "sa-sh-cmkey" {
  name         = "sashsz-key01030"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]

}
