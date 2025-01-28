variable "location" {
  description = "The primary Azure region to deploy resources in."
  type        = string
}

variable "container_name" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "db_workspace_name" {
  type = string
}

variable "access_connector_id" {
  type = string
}

variable "access_connector_name" {
  type = string
}

variable "workspace_id" {
  type = string
}

variable "catalog_name" {
  type = string
}
variable "schema_name" {
  type = string
}
variable "table_name" {
  type = string
}
variable "delta_sharing_token_expiry" {
  type = number
}
variable "cluster_vm_sku_type" {
  type = string
}
variable "auto_termination_minutes" {
  type = number
}