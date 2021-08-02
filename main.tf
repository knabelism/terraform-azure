provider "azurerm" {
  features {}

  subscription_id = "e09c79ec-3336-49ef-829f-4adbaa01032b"
  skip_provider_registration = true
}

terraform {
    backend "remote" {
        organization = "akauto"
        workspaces {
            name = "akauto-tf-tower"
        }
    }
}