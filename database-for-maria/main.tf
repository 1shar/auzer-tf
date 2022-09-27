resource "azurerm_subnet" "mariadb" {
  name                 = var.subnet_name
  resource_group_name = var.resource_group_name
  virtual_network_name = var.virtual_network_name 
  address_prefixes     = var.address_prefixes
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_mariadb_server" "mariadb" {
  name                = var.mariadb_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = var.admin_user
  administrator_login_password = var.admin_password

  sku_name   = var.sku_name
  storage_mb = var.storage_mb
  version    = var.version

  auto_grow_enabled             = var.auto_grow_enabled
  backup_retention_days         = var.backup_retention_days
  geo_redundant_backup_enabled  = var.geo_redundant_backup_enabled
  public_network_access_enabled = var.public_network_access_enabled
  ssl_enforcement_enabled       = var.ssl_enforcement_enabled
}
