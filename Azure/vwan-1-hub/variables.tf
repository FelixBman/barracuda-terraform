variable "location" {
  default = "eastus2"
}
variable "prefix" {
      description = "An abbreviation which represents your resource group as well as it is added in front of some resources"
}
variable "address_prefix" {
  default = "10.1.0.0/24"
}