provider "azurerm" {
  features {}

  subscription_id = var.subscriptionID
  skip_provider_registration = true
}