variable "subscription_id" {
  type = string
}
variable "primary" {
  description = "The primary Azure region to deploy resources in."
  type        = string
}
variable "alternate" {
  description = "The alternate Azure region to deploy resources in."
  type        = string
}
variable "name" {
  type = string
}