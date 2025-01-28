## Delta Sharing 

# Create a Delta Sharing recipient
resource "databricks_recipient" "main" {
  name                               = var.recipient_name
  comment                            = "Recipient for Delta Sharing"
  authentication_type                = "DATABRICKS"
  data_recipient_global_metastore_id = var.data_recipient_global_metastore_id
}

# Create a share for the recipient.
resource "databricks_share" "main" {
  name     = var.share_name
  object {
    name                        = var.object_name
    data_object_type            = "TABLE"
    history_data_sharing_status = "ENABLED"
  }
}

# Assign and grant permissions on the share to the provider
resource "databricks_grants" "share_perms_grants" {
  share    = databricks_share.main.name
  grant {
    principal  = databricks_recipient.main.name
    privileges = ["SELECT"]
  }
}

# Create a catalog from the share and grant permissions.
resource "databricks_catalog" "share_catalog" {
  name          = var.share_catalog_name
  provider_name = databricks_recipient.main.data_recipient_global_metastore_id
  share_name    = var.alt_share_name
}

resource "databricks_grants" "prim_share_catalog_grants" {
  catalog  = databricks_catalog.share_catalog.name
  grant {
    principal  = "account users"
    privileges = ["BROWSE", "USE_CATALOG", "USE_SCHEMA", "SELECT"]
  }
}