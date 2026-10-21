terraform {
  required_version = ">= 1.6.6"

  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0, < 3.0"
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

# Disable Secure Boot on the LXD profile. Required since the Lustre packages
# use DKMS.
resource "null_resource" "disable-secure-boot" {
  depends_on = [juju_model.charmed-hpc]

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      profile=$(lxc profile list --all-projects --format json \
        | python3 -c "import json,sys; print(next(p['name'] for p in json.load(sys.stdin) if p['name'].startswith('juju-${juju_model.charmed-hpc.name}')))")
      lxc profile set "$profile" boot.mode=uefi-nosecureboot \
        || lxc profile set "$profile" security.secureboot=false
    EOT
  }
}

module "lustre-share" {
  source     = "../../../modules/lustre"
  model_uuid = juju_model.charmed-hpc.uuid

  server = {
    # One unit acts as MGS+MDS, the rest as OSSes.
    units = 2
    # Easier to install kernel modules on VMs.
    constraints = "virt-type=virtual-machine"
  }

  client = {
    mountpoint = "/lustre"
  }

  depends_on = [null_resource.disable-secure-boot]
}

resource "juju_application" "ubuntu" {
  name       = "ubuntu"
  model_uuid = juju_model.charmed-hpc.uuid
  units      = 1
  # Easier to install kernel modules on VMs.
  constraints = "virt-type=virtual-machine"

  charm {
    name = "ubuntu"
    base = "ubuntu@26.04"
  }

  depends_on = [null_resource.disable-secure-boot]
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
    name     = module.lustre-share.app_name
    endpoint = "juju-info"
  }
}
