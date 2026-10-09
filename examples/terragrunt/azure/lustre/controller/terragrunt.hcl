# Bootstrap a Juju controller on Azure.
#
# This unit runs first. The lustre unit reads the connection details from this
# unit's outputs via its Terragrunt dependency block.
#
# Azure credentials come from the environment:
#   ARM_CLIENT_ID, ARM_SUBSCRIPTION_ID, ARM_CLIENT_SECRET
#
# The module's `connection` output is read directly by the dependency block
# in the parent plan.

terraform {
  source = "../../../../..//modules/controller"
}

# The module declares the juju provider but does not configure it; bootstrap
# requires controller mode.
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "juju" {
      controller_mode = true
    }
  EOF
}

inputs = {
  name           = "charmed-hpc"
  bootstrap_base = "ubuntu@24.04"

  # Write the controller module's Juju data files into the gitignored
  # Terragrunt cache, so the juju_data_dir output gives a pre-authenticated
  # JUJU_DATA for the Juju CLI (see the README).
  juju_data_dir = "${get_terragrunt_dir()}/.terragrunt-cache/juju-data"

  cloud = {
    name       = "azure"
    type       = "azure"
    auth_types = ["service-principal-secret"]

    region = {
      name = "eastus"
    }
  }

  cloud_credential = {
    name      = "azure-sp"
    auth_type = "service-principal-secret"
    attributes = {
      "application-id"       = get_env("ARM_CLIENT_ID", "")
      "subscription-id"      = get_env("ARM_SUBSCRIPTION_ID", "")
      "application-password" = get_env("ARM_CLIENT_SECRET", "")
    }
  }

  bootstrap_constraints = {
    "instance-type" = "Standard_D4s_v3"
    "arch"          = "amd64"
  }
}
