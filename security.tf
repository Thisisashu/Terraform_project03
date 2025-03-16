resource "azurerm_resource_group" "security" {
  name     = "security-grp"
  location = local.resource_location
}

resource "azurerm_key_vault" "appvault2640" {
  name                        = "appvault2640"
  location                    = local.resource_location
  resource_group_name         = "security-grp"
  tenant_id                   = "00250d23-984e-450f-978d-ecffad695877"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"
  
}

# data "azurerm_key_vault" "appvault26400" {
#   name         = "appvault26400"
#   resource_group_name = "security-grp"
# }

# resource "azurerm_key_vault_secret" "vmpassword" {
#   name         = "vmpassword"
#   value        = var.adminpassword
#   key_vault_id = data.azurerm_key_vault.appvault2640.id
# } 