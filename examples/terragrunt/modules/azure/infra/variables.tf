terraform {
  required_version = ">= 1.6.6"

  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0, < 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.17"
    }
  }
}

variable "model_name" {
  description = "Name of the Juju model to create."
  type        = string
  default     = "charmed-hpc"
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the Azure resource group to create."
  type        = string
  nullable    = false
}

variable "location" {
  description = "Azure location for the resource group."
  type        = string
  default     = "East US"
  nullable    = false
}

variable "virtual_network_name" {
  description = "Name of the Azure virtual network to create."
  type        = string
  nullable    = false
}

variable "address_space" {
  description = "Address space of the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
  nullable    = false
}

variable "network_security_group_name" {
  description = "Name of the Azure network security group to create."
  type        = string
  nullable    = false
}

variable "subnet_name" {
  description = "Name of the Azure subnet to create."
  type        = string
  nullable    = false
}

variable "subnet_address_prefixes" {
  description = "Address prefixes of the subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
  nullable    = false
}
