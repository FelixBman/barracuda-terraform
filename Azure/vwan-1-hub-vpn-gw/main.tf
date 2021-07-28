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
  
resource "azurerm_virtual_wan" "fbu-terratest-vwan" {
  name                = "${var.prefix}-vwan"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
}
resource "azurerm_virtual_hub" "examples" {
  name                = "terraform-virtualhub"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
  virtual_wan_id      = azurerm_virtual_wan.fbu-terratest-vwan.id
  address_prefix      = var.address_prefix
}