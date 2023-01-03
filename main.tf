# provider "azurerm" {
#   features {}

#   subscription_id = var.subscriptionID
#   skip_provider_registration = true
# }

# terraform {
#     backend "remote" {
#         organization = "akauto"
#         workspaces {
#             name = "automation_platform"
#         }
#     }
# }

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.70.0"
    }
  }
}


resource "azurerm_resource_group" "automation_platform" {
  location = var.location
  name     = "automation_platform"
  tags     = {}

  timeouts {}
}

resource "azurerm_virtual_network" "automation_platform_vnet" {
  address_space = [
    "10.0.0.0/16",
  ]
  location            = azurerm_resource_group.automation_platform.location
  name                = "automation_platform-vnet"
  resource_group_name = azurerm_resource_group.automation_platform.name
}

resource "azurerm_subnet" "automation_platform_subnet" {
  address_prefixes = [
    "10.0.0.0/24",
  ]
  enforce_private_link_endpoint_network_policies = false
  enforce_private_link_service_network_policies  = false
  name                                           = "auto-platform-cluster"
  resource_group_name                            = azurerm_resource_group.automation_platform.name
  virtual_network_name                           = azurerm_virtual_network.automation_platform_vnet.name

  timeouts {}
}

resource "azurerm_public_ip" "automation_platform_pub" {
  count                   = var.server_count
  allocation_method       = "Dynamic"
  availability_zone       = "No-Zone"
  idle_timeout_in_minutes = 4
  ip_version              = "IPv4"
  location                = azurerm_resource_group.automation_platform.location
  name                    = "${var.vm_prefix}${format("%02d", count.index)}-pubip"
  resource_group_name     = azurerm_resource_group.automation_platform.name
  sku                     = "Basic"
  timeouts {}
}

resource "azurerm_network_interface" "automation_platform_nic" {
  count                         = var.server_count
  enable_accelerated_networking = false
  location                      = azurerm_resource_group.automation_platform.location
  name                          = "${var.vm_prefix}${format("%02d", count.index)}-nic"
  resource_group_name           = azurerm_resource_group.automation_platform.name

  ip_configuration {
    name                          = "ipconfig1"
    primary                       = true
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    public_ip_address_id          = element(azurerm_public_ip.automation_platform_pub.*.id, count.index)
    subnet_id                     = azurerm_subnet.automation_platform_subnet.id
  }

  timeouts {}
}

resource "azurerm_linux_virtual_machine" "automation_platform_server" {
  count          = var.server_count
  location       = azurerm_resource_group.automation_platform.location
  name           = "${var.vm_prefix}${format("%02d", count.index)}-vm"
  admin_username = var.admin_username
  network_interface_ids = [
    element(azurerm_network_interface.automation_platform_nic.*.id, count.index),
  ]
  resource_group_name = azurerm_resource_group.automation_platform.name
  size                = "Standard_D2s_v3"

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("files/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    offer     = "RHEL"
    publisher = "RedHat"
    sku       = "8_6"
    version   = "latest"
  }

  timeouts {}
}

resource "azurerm_postgresql_server" "example" {
  name                = "${var.vm_prefix}-postgresql-db-vm"
  location            = azurerm_resource_group.automation_platform.location
  resource_group_name = azurerm_resource_group.automation_platform.name

  administrator_login          = "knabelism"
  administrator_login_password = "codigo123"

  sku_name   = "B_Gen5_2"
  version    = "11"
  storage_mb = 100000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}