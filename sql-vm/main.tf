data "azurerm_resource_group" "vm" {
  name = var.resource_group_name
}

resource "random_id" "vm-sa" {
  keepers = {
    vm_hostname = var.vm_hostname
  }

  byte_length = 6
}

resource "azurerm_virtual_machine" "vm-windows" {
  count                         = var.nb_instances
  name                          = "${var.vm_hostname}${count.index + 1}"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = coalesce(var.location, data.azurerm_resource_group.vm.location)
  #availability_set_id          = azurerm_availability_set.vm.id
  zones                         = [count.index + 1]
  vm_size                       = var.vm_size
  network_interface_ids         = [element(azurerm_network_interface.vm.*.id, count.index)]
  delete_os_disk_on_termination = var.delete_os_disk_on_termination
  license_type                  = var.license_type

#   dynamic identity {
#     for_each = length(var.identity_ids) == 0 && var.identity_type == "SystemAssigned" ? [var.identity_type] : []
#     content {
#       type = var.identity_type
#     }
#   }

#   dynamic identity {
#     for_each = length(var.identity_ids) > 0 || var.identity_type == "UserAssigned" ? [var.identity_type] : []
#     content {
#       type         = var.identity_type
#       identity_ids = length(var.identity_ids) > 0 ? var.identity_ids : []
#     }
#   }

  storage_image_reference {
    publisher = var.vm_os_publisher
    offer     = var.vm_os_offer
    sku       = var.vm_os_sku
    version   = var.vm_os_version
  }

  storage_os_disk {
    name              = "${var.vm_hostname}${count.index + 1}-osdisk-${count.index + 1}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = var.storage_account_type
  }

  dynamic storage_data_disk {
    for_each = range(var.nb_data_disk)
    content {
      name              = "${var.vm_hostname}${count.index + 1}-datadisk-${count.index + 1}"
      create_option     = "Empty"
      lun               = storage_data_disk.value
      disk_size_gb      = var.data_disk_size_gb
      managed_disk_type = var.data_sa_type
    }
  }

  dynamic storage_data_disk {
    for_each = var.extra_disks
    content {
      name              = "${var.vm_hostname}-extradisk-${count.index + 1}-${storage_data_disk.value.name}"
      create_option     = "Empty"
      lun               = storage_data_disk.key + var.nb_data_disk
      disk_size_gb      = storage_data_disk.value.size
      managed_disk_type = var.data_sa_type
    }
  }

  os_profile {
    computer_name  = "${var.vm_hostname}${count.index + 1}"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  tags = var.tags

  os_profile_windows_config {
    provision_vm_agent = true
  }

#   dynamic "os_profile_secrets" {
#     for_each = var.os_profile_secrets
#     content {
#       source_vault_id = os_profile_secrets.value["source_vault_id"]

#       vault_certificates {
#         certificate_url   = os_profile_secrets.value["certificate_url"]
#         certificate_store = os_profile_secrets.value["certificate_store"]
#       }
#     }
#   }

#   boot_diagnostics {
#     enabled     = var.boot_diagnostics
#     storage_uri = var.boot_diagnostics ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""
#   }
}

# resource "azurerm_availability_set" "vm" {
#   name                         = "${var.vm_hostname}-avset"
#   resource_group_name          = data.azurerm_resource_group.vm.name
#   location                     = coalesce(var.location, data.azurerm_resource_group.vm.location)
#   platform_fault_domain_count  = 2
#   platform_update_domain_count = 2
#   managed                      = true
#   tags                         = var.tags
# }

resource "azurerm_public_ip" "vm" {
  count               = var.nb_public_ip
  name                = "${var.vm_hostname}${count.index + 1}-pip"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = coalesce(var.location, data.azurerm_resource_group.vm.location)
  allocation_method   = var.allocation_method
  sku                 = var.public_ip_sku
  domain_name_label   = element(var.public_ip_dns, count.index)
  tags                = var.tags
}

// Dynamic public ip address will be got after it's assigned to a vm
data "azurerm_public_ip" "vm" {
  count               = var.nb_public_ip
  name                = azurerm_public_ip.vm[count.index].name
  resource_group_name = data.azurerm_resource_group.vm.name
  depends_on          = [azurerm_virtual_machine.vm-windows]
}

resource "azurerm_network_security_group" "vm" {
  name                = "${var.vm_hostname}-nsg"
  resource_group_name = data.azurerm_resource_group.vm.name
  location            = coalesce(var.location, data.azurerm_resource_group.vm.location)

  tags = var.tags
}


resource "azurerm_network_interface" "vm" {
  count                         = var.nb_instances
  name                          = "${var.vm_hostname}${count.index + 1}-nic"
  resource_group_name           = data.azurerm_resource_group.vm.name
  location                      = coalesce(var.location, data.azurerm_resource_group.vm.location)
  enable_accelerated_networking = var.enable_accelerated_networking

  ip_configuration {
    name                          = "${var.vm_hostname}${count.index + 1}-ip"
    subnet_id                     = var.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, tolist([""])), count.index) : ""
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "test" {
  count                     = var.nb_instances
  network_interface_id      = azurerm_network_interface.vm[count.index].id
  network_security_group_id = azurerm_network_security_group.vm.id
}
