## Provisioning Unity Catalog, relevant tables and compute cluster.
module "primary_uc" {
  source                     = "./modules/unity-catalog"
  location                   = var.primary_location
  container_name             = var.container_name
  storage_account_name       = "dbw${var.primary_location}storage"
  resource_group_name        = "rg-${var.name}-${var.primary_suffix}"
  db_workspace_name          = data.azurerm_databricks_workspace.main.name
  access_connector_id        = data.azurerm_databricks_access_connector.main.id
  access_connector_name      = data.azurerm_databricks_access_connector.main.name
  workspace_id               = data.azurerm_databricks_workspace.main.workspace_id
  catalog_name               = var.catalog_name
  schema_name                = var.schema_name
  table_name                 = var.table_name
  delta_sharing_token_expiry = var.delta_sharing_token_expiry
  cluster_vm_sku_type        = var.cluster_vm_sku_type
  auto_termination_minutes   = var.auto_termination_minutes

  providers = {
    databricks = databricks.primary
  }
}

module "alternate_uc" {
  source                     = "./modules/unity-catalog"
  location                   = var.alternate_location
  container_name             = var.container_name
  storage_account_name       = "dbw${var.alternate_location}storage"
  resource_group_name        = "rg-${var.name}-${var.alternate_suffix}"
  db_workspace_name          = data.azurerm_databricks_workspace.alternate.name
  access_connector_id        = data.azurerm_databricks_access_connector.alternate.id
  access_connector_name      = data.azurerm_databricks_access_connector.alternate.name
  workspace_id               = data.azurerm_databricks_workspace.alternate.workspace_id
  catalog_name               = "${var.catalog_name}_temp"
  schema_name                = "${var.schema_name}_temp"
  table_name                 = "${var.table_name}_temp"
  delta_sharing_token_expiry = var.delta_sharing_token_expiry
  cluster_vm_sku_type        = var.cluster_vm_sku_type
  auto_termination_minutes   = var.auto_termination_minutes

  providers = {
    databricks = databricks.alternate
  }
}

## Delta Sharing
module "primary_delta_sharing" {
  source                             = "./modules/delta-sharing"
  recipient_name                     = "${var.primary_suffix}_recipient"
  data_recipient_global_metastore_id = module.alternate_uc.global_metastore_id
  share_name                         = "prim_alt_share"
  object_name                        = "${var.catalog_name}.${var.schema_name}.${var.table_name}"
  share_catalog_name                 = "${var.catalog_name}_temp"
  alt_share_name                     = "alt_prim_share"

  providers = {
    databricks = databricks.primary
  }
}

module "alternate_delta_sharing" {
  source                             = "./modules/delta-sharing"
  recipient_name                     = "${var.alternate_suffix}_recipient"
  data_recipient_global_metastore_id = module.primary_uc.global_metastore_id
  share_name                         = "alt_prim_share"
  object_name                        = "${var.catalog_name}_temp.${var.schema_name}_temp.${var.table_name}_temp"
  share_catalog_name                 = var.catalog_name
  alt_share_name                     = "prim_alt_share"

  providers = {
    databricks = databricks.alternate
  }
}

## Provision the notebooks and jobs.
## Primary region
module "prim_notebook_jobs" {
  source       = "./modules/jobs"
  cluster_id   = module.primary_uc.cluster_id
  input_table  = "${var.catalog_name}.${var.schema_name}.${var.table_name}"
  output_table = "${var.catalog_name}.${var.schema_name}.${var.table_name}"
  job_type     = "primary"
  is_primary   = true

  providers = {
    databricks = databricks.primary
  }
}

# Alternate region
module "alt_notebook_jobs" {
  source       = "./modules/jobs"
  cluster_id   = module.alternate_uc.cluster_id
  input_table  = "${var.catalog_name}.${var.schema_name}.${var.table_name}"
  output_table = "${var.catalog_name}_temp.${var.schema_name}_temp.${var.table_name}_temp"
  job_type     = "alternate"
  is_primary   = false

  providers = {
    databricks = databricks.alternate
  }
}