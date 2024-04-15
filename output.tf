output "application_gateway_backend_urls" {
  value = {
    key_vault_list_secrets = module.key-vault.kv-out.vault_uri
    key_vault_get_secret   = "${module.key-vault.kv-out.vault_uri}/secrets/czm01-cur-dev-euw-zeiss-id-client-id-app-shell?api-version=7.4"
    storage_queue_send     = "${module.storage.storage-out.primary_blob_endpoint}/audit-logs/messages?messagettl=-1"
    storage_queue_peek     = "${module.storage.storage-out.primary_blob_endpoint}/audit-logs/messages?peekonly=true&numofmessages=32"
  }
}

#output "module-apim-out" {
#  value = module.apim
#}
