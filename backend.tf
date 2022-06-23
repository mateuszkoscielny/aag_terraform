terraform {
    backend "azurerm" {
    resource_group_name  = "TerraformTestRG"
    storage_account_name = "mkterraformstate"
    container_name       = "terraform-state"
    key                  = "terraformstate"
  }
}