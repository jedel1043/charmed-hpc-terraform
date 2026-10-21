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

variable "name" {
  description = "Name for the exported NFS share and the prefix of all the related resources."
  type        = string
  default     = "nfs-share"
  nullable    = false
}

variable "model_uuid" {
  description = "UUID of the target Juju model."
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "Name of the Azure resource group where the NFS share will be allocated."
  type        = string
  nullable    = false
}

variable "subnet_info" {
  description = "Information about the subnet where the NFS share will be allocated."
  type        = object({ name = string, virtual_network_name = string })
  nullable    = false
}

variable "quota" {
  description = "The maximum size of the share, in gigabytes."
  type        = number
  default     = 100
  nullable    = false
}

variable "mountpoint" {
  description = "Path to the directory where the NFS share will be mounted."
  type        = string
  default     = "/nfs/home"
  nullable    = false
}

variable "applications" {
  description = "Names of the Juju applications to integrate with the NFS share's filesystem client."
  type        = list(string)
  nullable    = false
}
