terraform {
  required_version = ">= 1.6.6"

  required_providers {
    juju = {
      source  = "juju/juju"
      version = "~> 1.0"
    }
  }
}

provider "juju" {
  controller_addresses = var.connection != null ? var.connection.controller_addresses : null
  username             = var.connection != null ? var.connection.username : null
  password             = var.connection != null ? var.connection.password : null
  ca_certificate       = var.connection != null ? var.connection.ca_certificate : null
  skip_failed_deletion = true
}

resource "juju_model" "charmed-hpc" {
  name = "charmed-hpc"
}

## MySQL - provides backing database for the accounting node.
module "mysql" {
  source = "git::https://github.com/canonical/mysql-operators//machines/terraform?ref=33d381861060a74c10681eae2feca1ce2ef0c105"

  model        = juju_model.charmed-hpc.uuid
  app_name     = "mysql"
  base         = "ubuntu@26.04"
  channel      = "8.4/edge"
  units        = 1
  storage_size = "10G"
}

module "slurm" {
  source = "../../modules/slurm"

  model_uuid = juju_model.charmed-hpc.uuid
  database_backend = {
    name     = module.mysql.app_name,
    endpoint = module.mysql.provides.database
  }

  # Optional settings for the controller node.
  controller = {
    app_name = "slurmctld"
  }

  # Optional settings for the database node.
  database = {
    app_name = "slurmdbd"
  }

  # Optional settings for the REST API node.
  rest_api = {
    app_name = "slurmrestd"
  }

  # Optional settings for the kiosk node.
  kiosk = {
    app_name = "sackd",
    units    = 1,
  }

  # Compute partitions to be deployed.
  compute_partitions = {
    "default" : {
      units = 1,
    },
    "gpu" : {
      units = 1,
    }
  }
  depends_on = [
    juju_model.charmed-hpc
  ]
}
