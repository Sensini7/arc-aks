variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/22"]
}

variable "aks_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "pe_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "tags" {
  type    = map(string)
  default = {}
}