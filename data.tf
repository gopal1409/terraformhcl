data "azurerm_key_vault" "key_vault" {
    name = "learntf-gopal"
    resource_group_name = "remote-state-gopal"
}
data "azurerm_key_vault_secret" "admin_password" {
    name = "admin-password" 
    key_vault_id = data.azurerm_key_vault.key_vault.id
}