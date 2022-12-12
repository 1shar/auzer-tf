resource "azurerm_network_security_group" "sql_managed" {
  name                = "${var.sql_managed_instance_name}-nsg"
  location            = var.location
  resource_group_name = var.vnet_resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "sql_managed" {
  name                 = "${var.sql_managed_instance_name}_SUB"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.address_prefixes

  delegation {
    name = "managedinstancedelegation"

    service_delegation {
      name    = "Microsoft.Sql/managedInstances"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}


 resource "azurerm_subnet_network_security_group_association" "sql_managed" {
   subnet_id                 = azurerm_subnet.sql_managed.id
   network_security_group_id = azurerm_network_security_group.sql_managed.id
 }

resource "azurerm_route_table" "sql_managed" {
  name                          = var.route_table_name
  location                      = var.location
  resource_group_name           = var.vnet_resource_group_name
  tags                          = var.tags
  disable_bgp_route_propagation = var.disable_bgp_route_propagation
  depends_on = [
    azurerm_subnet.sql_managed,
  ]
}

resource "azurerm_subnet_route_table_association" "sql_managed" {
  subnet_id      = azurerm_subnet.sql_managed.id
  route_table_id = azurerm_route_table.sql_managed.id
}

resource "azurerm_mssql_managed_instance" "sql_managed" {
  name                = var.sql_managed_instance_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  license_type       = var.license_type
  sku_name           = var.sku_name
  storage_size_in_gb = var.storage_size_in_gb
  subnet_id          = azurerm_subnet.sql_managed.id
  vcores             = var.vcores
  collation          = var.collation
  timezone_id        = var.timezone_id


  administrator_login          = var.admin_user
  administrator_login_password = var.admin_password

  depends_on = [
    azurerm_subnet_network_security_group_association.sql_managed,
    azurerm_subnet_route_table_association.sql_managed,
  ]
}
