# Bootstrap a Juju controller on the local LXD cloud.
#
# This unit runs first. The lustre unit reads the connection details from this
# unit's outputs via its Terragrunt dependency block.
#
# The LXD certificate credentials come from environment variables when set
# (LXD_CLIENT_CERT, LXD_CLIENT_KEY, LXD_SERVER_CERT), which is how CI provides
# them. Otherwise they are read from the local Juju client's credentials.yaml
# (~/.local/share/juju). The file is read directly
# rather than via `juju show-credentials` because that command contacts the
# active controller and fails after switching to another controller.
#
# $JUJU_DATA is deliberately not honored here: the controller module's
# temporary JUJU_DATA (see its juju_data_dir output) contains no cloud
# credentials (credentials.yaml), so honoring it would break plans run inside
# that environment.
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

locals {
  # Credentials registered with the local Juju client for the localhost cloud.
  # Absent on machines without a Juju client (e.g. CI runners).
  credentials_file = "${get_env("HOME")}/.local/share/juju/credentials.yaml"
  file_credentials = fileexists(local.credentials_file) ? yamldecode(file(local.credentials_file)).credentials.localhost.localhost : null

  # Environment variables take precedence over the Juju client credentials.
  localhost = {
    auth-type   = "certificate"
    client-cert = get_env("LXD_CLIENT_CERT", try(local.file_credentials.client-cert, ""))
    client-key  = get_env("LXD_CLIENT_KEY", try(local.file_credentials.client-key, ""))
    server-cert = get_env("LXD_SERVER_CERT", try(local.file_credentials.server-cert, ""))
  }
}

inputs = {
  name           = "charmed-hpc"
  bootstrap_base = "ubuntu@24.04"

  # Write the controller module's Juju data files into the gitignored
  # Terragrunt cache, so the juju_data_dir output gives a pre-authenticated
  # JUJU_DATA for the Juju CLI (see the README).
  juju_data_dir = "${get_terragrunt_dir()}/.terragrunt-cache/juju-data"

  cloud = {
    name       = "localhost"
    type       = "lxd"
    auth_types = ["certificate"]

    region = {
      name = "localhost"
    }
  }

  cloud_credential = {
    name      = "localhost"
    auth_type = local.localhost.auth-type
    attributes = {
      client-cert = local.localhost.client-cert
      client-key  = local.localhost.client-key
      server-cert = local.localhost.server-cert
    }
  }
}
