variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(string)

  default = {
    environment = "dev"
  }
}


variable "vnet_resource_group_name" {
  type = string
  default = "sql"
}


variable "vnet_name" {
  type = string
  default = "sql"
}


variable "route_table_name" {
  type = string
  default = "sql"
}

variable "sql_managed_instance_name" {
  type = string
  default = "sql"
}


variable "address_prefixes" {
  description = "The address prefix to use for the subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "disable_bgp_route_propagation" {
  type = string
  default = "false"
}

variable "resource_group_name" {
  type = string
  default = "rg"
}

variable "location" {
  type = string
  default = "koreacentral"
}

variable "license_type" {
  type = string
  default = "BasePrice"
}

variable "sku_name" {
  type = string
  default = "GP_Gen5"
}

variable "storage_size_in_gb" {
  type = string
  default = "16"
}

variable "vcores" {
  type = string
  default = "4"
}


variable "admin_user" {
  type = string
  default = "admin"
}

variable "admin_password" {
  type = string
  default = "thisIsDog11"
}

variable "collation" {
  type = string
  default = "Korean_Wansung_CI_AS"
}

variable "timezone_id" {
  type = string
  default = "Korea Standard Time"
}



