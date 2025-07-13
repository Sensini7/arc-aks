variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "premium"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "admin_object_ids" {
  type    = list(string)
  default = []
}