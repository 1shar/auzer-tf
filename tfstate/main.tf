provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tfstate" {
  name     = "${var.service}-tfstate-RG" # hws-esh-rg-dev-
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "${var.company}${var.system}tfstorage"
  resource_group_name      = "${local.company}-${local.system}-tfstate-rg"
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
 # allow_blob_public_access = true

  tags = {
    company = local.company
    service = local.system
    location = local.location
    managedby = "iac"
}
}
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "blob"
}

