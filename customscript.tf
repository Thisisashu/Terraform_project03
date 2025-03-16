resource "azurerm_storage_account" "appstore2640" {
  name                     = "appstore2640"
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = local.resource_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"  
  
}

resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_name  = azurerm_storage_account.appstore2640.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "IISConfig" {
  name                   = "IIS.ps1"
  storage_account_name   = azurerm_storage_account.appstore2640.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = "IIS.ps1"
}

resource "azurerm_virtual_machine_extension" "vmextension" {
  name                 = "vmextension"
  virtual_machine_id   = azurerm_windows_virtual_machine.webvm["webvm01"].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "fileUris": ["https://${azurerm_storage_account.appstore2640.name}.blob.core.windows.net/${azurerm_storage_container.scripts.name}/${azurerm_storage_blob.IISConfig.source}"],
          "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file ${azurerm_storage_blob.IISConfig.source}"     
    }
SETTINGS

}