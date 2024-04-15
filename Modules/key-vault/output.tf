output "kv-out" {
    value =  azurerm_key_vault.kv
}

output "kv-key" {
    value = azurerm_key_vault_key.sa-sh-cmkey
  
}
