terraform {
  required_version = ">= 1.6.6"

  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0, < 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~>6.41"
    }
  }
}

provider "juju" {}

provider "google" {}

data "google_client_config" "current" {}

# ==== Juju resources ====

resource "juju_model" "charmed-hpc" {
  name = "charmed-hpc"

  cloud {
    name   = "google"
    region = data.google_client_config.current.region
  }
}

module "nfs-share" {
  source      = "../../../modules/nfs/gcp"
  capacity_gb = 1024
  tier        = "STANDARD"
  network     = "default"
  name        = "nfs-share"
  mountpoint  = "/nfs/home"
  model_uuid  = juju_model.charmed-hpc.uuid
}

resource "juju_application" "ubuntu" {
  name       = "ubuntu"
  model_uuid = juju_model.charmed-hpc.uuid

  charm {
    name = "ubuntu"
    base = "ubuntu@26.04"
  }
}

# Since the filesystem client is a subordinate charm, it uses
# the `juju-info` endpoint to integrate with other charms.
resource "juju_integration" "ubuntu-to-filesystem-client" {
  model_uuid = juju_model.charmed-hpc.uuid

  application {
    name     = juju_application.ubuntu.name
    endpoint = "juju-info"
  }

  application {
    name     = module.nfs-share.app_name
    endpoint = "juju-info"
  }
}
