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
  
resource "azurerm_virtual_wan" "terra-virtual-wan" {
  name                = "${var.prefix}-vwan"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
}
resource "azurerm_virtual_hub" "terra-HUB" {
  name                = "${var.prefix}-virtualhub"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  location            = azurerm_resource_group.resourcegroup.location
  virtual_wan_id      = azurerm_virtual_wan.terra-virtual-wan.id
  address_prefix      = var.address_prefix
}
resource "azurerm_vpn_gateway" "VPNG" {
  name                = "${var.prefix}-vpng"
  location            = var.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  virtual_hub_id      = azurerm_virtual_hub.terra-HUB.id
}