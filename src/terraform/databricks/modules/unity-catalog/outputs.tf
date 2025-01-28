output "global_metastore_id" {
  value = databricks_metastore.main.global_metastore_id
}

output "cluster_id" {
  value = databricks_cluster.main_cluster.id
}