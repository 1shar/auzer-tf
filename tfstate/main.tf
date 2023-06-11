provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tfstate" {
  name     = "${var.company}-${var.system}-rg-tfstate" # hws-esh-rg
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "${var.company}${var.system}tfstorage"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
 # allow_blob_public_access = true

  tags = {
    company = var.company
    service = var.system
    location = var.location
    managedby = "iac"
}
}
resource "azurerm_storage_container" "tfstate" {
  name                  = "${var.company}${var.system}tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "blob"
}

