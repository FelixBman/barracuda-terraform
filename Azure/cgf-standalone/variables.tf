variable "location" {
  default = "west europe"
}
variable "prefix" {
      description = "An abbreviation which represents your resource group as well as it is added in front of some resources"
      default = "fbu-CGF-single"
}

variable "vnet" {
    description = "Network range of the VNET (e.g. 10.123.0.0/22)"
    default = "10.123.0.0/22"
}

variable "subnet_cgf" {
    description = "Network range of the Subnet containing the CloudGen Firewall (e.g. 10.123.0.0/24)"
    default = "10.123.0.0/24"
}

variable "subnet_protected" {
    description = "Network range of the protected subnet (e.g. 10.123.1.0/24)"
    default = "10.123.1.0/24"
}
variable "cgf_ipaddress" {
    description = "Private IP address of the Barracuda CGF VM"
    default = "10.123.0.10"
}
variable "cgf_subnetmask" {
    description = "Subnetmask of the internal IP address of the CGF (e.g. 24)"
    default = "24"
}

variable "cgf_defaultgateway" {
    description = "Default gateway of the CGF network. This is always the first IP in the Azure subnet where the CGF is located. (e.g. 10.123.0.1)"
    default = "10.123.0.1"
}


variable "cgf_imagesku" {
    description = "SKU Hourly (PAYG) or Bring your own license (BYOL)"
    default     = "byol"
}

variable "cgf_vmsize" {
    description = "Size of the Barracuda CGF VMs to be created"
    default     = "Standard_DS1_v2"
}
variable "password" { 
    description = "The password for the Barracuda CloudGen Firewall to use"
}

