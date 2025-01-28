resource "azurerm_resource_group" "main" {
  name     = "rg-${var.name}-${var.suffix}"
  location = var.location
}

resource "azurerm_databricks_access_connector" "main" {
  name                = "databricks-connector-${var.suffix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  identity {
    type = "SystemAssigned" # Managed Identity is system-assigned
  }
}

resource "azurerm_storage_account" "main" {
  name                     = "dbw${var.location}storage"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
}

# Create a container in the ADLS Gen2 Storage Account
resource "azurerm_storage_container" "storage_container" {
  name                  = "datapoc"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private" # Options: private, blob, container
}

# Assign Storage Blob Data Contributor Role
resource "azurerm_role_assignment" "databricks_blob_data_contributor" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.main.identity[0].principal_id
}

resource "azurerm_databricks_workspace" "dbworkspace" {
  name                        = "${var.location}-db-workspace"
  resource_group_name         = azurerm_resource_group.main.name
  location                    = azurerm_resource_group.main.location
  sku                         = "premium"
  managed_resource_group_name = "${azurerm_resource_group.main.name}-managed"
}
