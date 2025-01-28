variable "subscription_id" {
  type = string
}
variable "databricks_account_id" {
  description = "Account Id for Databricks Account."
  type        = string
}

variable "primary_location" {
  description = "The primary Azure region to deploy resources in."
  type        = string
}

variable "alternate_location" {
  description = "The alternate Azure region to deploy resources in."
  type        = string
}

variable "container_name" {
  type = string
}

variable "name" {
  type = string
}

variable "primary_suffix" {
  type = string
}

variable "alternate_suffix" {
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
  type        = number
  description = "Delta Sharing recipient's token lifetime in seconds"
}
variable "cluster_vm_sku_type" {
  type = string
}
variable "auto_termination_minutes" {
  type        = number
  description = "Auto termination of VMs in cluster in minutes."
}