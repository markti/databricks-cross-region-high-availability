resource "databricks_metastore" "main" {
  name                                              = "metastore-${var.location}"
  force_destroy                                     = true
  storage_root                                      = "abfss://${var.container_name}@${var.storage_account_name}.dfs.core.windows.net/"
  region                                            = var.location
  delta_sharing_scope                               = "INTERNAL"
  delta_sharing_recipient_token_lifetime_in_seconds = var.delta_sharing_token_expiry
}

resource "databricks_metastore_data_access" "main" {
  metastore_id = databricks_metastore.main.id
  name         = "${var.access_connector_name}_metastore_access"
  is_default   = true
  azure_managed_identity {
    access_connector_id = var.access_connector_id
  }
}

resource "databricks_metastore_assignment" "main" {
  workspace_id = var.workspace_id
  metastore_id = databricks_metastore.main.id
}

resource "databricks_grants" "grant_all_users" {
  metastore = databricks_metastore.main.id

  grant {
    principal  = "account users"
    privileges = ["CREATE_CATALOG", "CREATE_PROVIDER", "CREATE_RECIPIENT", "CREATE_SHARE", "USE_SHARE", "USE_PROVIDER", "USE_RECIPIENT"]
  }
}

resource "databricks_catalog" "main" {
  metastore_id = databricks_metastore.main.id
  name         = var.catalog_name
  comment      = "this catalog is managed by terraform"
}

resource "databricks_grants" "catalog_grants" {
  catalog = databricks_catalog.main.name
  grant {
    principal  = "account users"
    privileges = ["USE_CATALOG", "ALL_PRIVILEGES"]
  }
}

resource "databricks_schema" "main" {
  catalog_name = databricks_catalog.main.id
  name         = var.schema_name
  comment      = "this database is managed by terraform"
}

resource "databricks_grants" "schema_grants" {
  schema = databricks_schema.main.id
  grant {
    principal  = "account users"
    privileges = ["USE_SCHEMA", "ALL_PRIVILEGES"]
  }
}

resource "databricks_sql_table" "main_table" {
  name               = var.table_name
  catalog_name       = databricks_catalog.main.name
  schema_name        = databricks_schema.main.name
  table_type         = "MANAGED"
  data_source_format = "DELTA"

  column {
    name = "id"
    type = "int"
  }
  column {
    name = "name"
    type = "string"
  }
  column {
    name = "price"
    type = "int"
  }
  column {
    name = "updated_on"
    type = "date"
  }
  column {
    name = "updated_by"
    type = "string"
  }
  comment = "this table is managed by terraform"
}

# Code to provision the Spark Cluster
data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "main_cluster" {
  cluster_name            = "shared_spark_cluster"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = var.cluster_vm_sku_type
  autotermination_minutes = var.auto_termination_minutes
  data_security_mode      = "USER_ISOLATION"

  autoscale {
    min_workers = 1
    max_workers = 2
  }

  enable_local_disk_encryption = true
  runtime_engine               = "PHOTON"
}