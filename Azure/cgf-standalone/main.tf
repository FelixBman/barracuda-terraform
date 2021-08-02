terraform{
    required_providers{
        azurerm={
            version="2.68.0"
            source="hashicorp/azurerm"
        }
    }
}

provider "azurerm" {
  features{

  }
}
resource "azurerm_resource_group" "resourcegroup" {
    name = "${var.prefix}"
    location = var.location 
    tags = {
        "Owner" = "fbueltmann@barracuda.com"
        "deployes-with" = "terraform"
        "persistant"    = "no"
    }
}