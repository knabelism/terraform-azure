provider "azurerm" {
  features {}

  subscription_id            = var.subscriptionID
  client_id                  = var.clientID
  client_secret              = var.clientSecret
  tenant_id                  = var.tenantID
  skip_provider_registration = true
}