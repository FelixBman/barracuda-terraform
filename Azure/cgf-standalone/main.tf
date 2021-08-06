provider "azurerm" {
  features{

  }
}
resource "azurerm_resource_group" "cgf-rg" {
    name = "${var.prefix}"
    location = var.location 
    tags = {
        "Owner" = "fbueltmann@barracuda.com"
        "deployes-with" = "terraform"
        "persistant"    = "no"
    }
}
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-VNET"
  address_space       = ["${var.vnet}"]
  location            = "${azurerm_resource_group.cgf-rg.location}"
  resource_group_name = "${azurerm_resource_group.cgf-rg.name}"
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.prefix}-SUBNET-CGF"
  resource_group_name  = "${azurerm_resource_group.cgf-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet_cgf}"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "${var.prefix}-SUBNET-Protected"
  resource_group_name  = "${azurerm_resource_group.cgf-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet_protected}"
  #route_table_id       = "${azurerm_route_table.frontendroute.id}"
}

resource "azurerm_public_ip" "cgf-pip" {
  name                         = "${var.prefix}-VM-NGF-PIP"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.cgf-rg.name}"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "cgf-ifc" {
  name                = "${var.prefix}-VM-CGF-IFC"
  location            = "${azurerm_resource_group.cgf-rg.location}"
  resource_group_name = "${azurerm_resource_group.cgf-rg.name}"
  enable_ip_forwarding  = true
  ip_configuration {
    name                          = "interface1"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.cgf_ipaddress}"
    public_ip_address_id          = "${azurerm_public_ip.cgf-pip.id}"
  }
}

resource "azurerm_network_security_group" "cgf_nsg" {
  name                = "${var.prefix}-CGF-NSG"
  location            = var.location
  resource_group_name = "${azurerm_resource_group.cgf-rg.name}"
}

resource "azurerm_network_security_rule" "csg_nsg_allowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = "${azurerm_resource_group.cgf-rg.name}"
  network_security_group_name = "${azurerm_network_security_group.cgf_nsg.name}"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "csg_nsg_allowallssh" {
  name                        = "Allow-SSH-Inbound"
  resource_group_name         = "${azurerm_resource_group.cgf-rg.name}"
  network_security_group_name = "${azurerm_network_security_group.cgf_nsg.name}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "94.79.184.0/24"
  destination_address_prefix  = "*"
}



resource "azurerm_virtual_machine" "ngfvm" {
  name                  = "${var.prefix}-VM-NGF"
  location              = "${azurerm_resource_group.cgf-rg.location}"
  resource_group_name   = "${azurerm_resource_group.cgf-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.cgf-ifc.id}"]
  vm_size               = "${var.cgf_vmsize}"

  storage_image_reference {
    publisher = "barracudanetworks"
    offer     = "barracuda-ng-firewall"
    sku       = "${var.cgf_imagesku}"
    version   = "latest"
  }

  plan {
    publisher = "barracudanetworks"
    product   = "barracuda-ng-firewall"
    name      = "${var.cgf_imagesku}"
  }

  storage_os_disk {
    name              = "${var.prefix}-VM-CGF-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-VM-CGF"
    admin_username = "azureuser"
    admin_password = "${var.password}"
    custom_data = "${base64encode("#!/bin/bash\n\nNGFIP=${var.cgf_ipaddress}\n\nNGFNM=${var.cgf_subnetmask}\n\nNGFGW=${var.cgf_defaultgateway}\n\n${file("${path.module}/provisioncgf.sh")}")}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}
