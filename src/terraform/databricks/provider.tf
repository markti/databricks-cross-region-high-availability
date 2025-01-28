data "azurerm_databricks_workspace" "main" {
  name                = "${var.primary_location}-db-workspace"
  resource_group_name = "rg-${var.name}-${var.primary_suffix}"
}

data "azurerm_databricks_access_connector" "main" {
  name                = "databricks-connector-${var.primary_suffix}"
  resource_group_name = "rg-${var.name}-${var.primary_suffix}"
}

data "azurerm_databricks_workspace" "alternate" {
  name                = "${var.alternate_location}-db-workspace"
  resource_group_name = "rg-${var.name}-${var.alternate_suffix}"
}

data "azurerm_databricks_access_connector" "alternate" {
  name                = "databricks-connector-${var.alternate_suffix}"
  resource_group_name = "rg-${var.name}-${var.alternate_suffix}"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "databricks" {
  # Configuration options
  alias = "primary"
  host  = data.azurerm_databricks_workspace.main.workspace_url
}

provider "databricks" {
  # Configuration options
  alias = "alternate"
  host  = data.azurerm_databricks_workspace.alternate.workspace_url
}

provider "databricks" {
  alias      = "accounts"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}
