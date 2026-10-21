# Copyright 2025 Canonical Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# slurmdbd and slurmrestd do not support HA setups
resource "terraform_data" "single_unit_services" {
  lifecycle {
    precondition {
      condition     = coalesce(var.database.units, 1) <= 1 && length(var.database.machines) <= 1
      error_message = "The Slurm database charm (slurmdbd) does not support HA setups and must be deployed with at most one unit or machine."
    }

    precondition {
      condition     = coalesce(var.rest_api.units, 1) <= 1 && length(var.rest_api.machines) <= 1
      error_message = "The Slurm REST API charm (slurmrestd) does not support HA setups and must be deployed with at most one unit or machine."
    }
  }
}

module "slurmctld" {
  source = "git::https://github.com/canonical/slurm-charms//charms/slurmctld/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae"

  model_uuid = var.model_uuid
  app_name   = local.controller.app_name
  base       = local.controller.base

  channel     = local.controller.channel
  revision    = local.controller.revision
  machines    = local.controller.machines
  units       = local.controller.units
  config      = local.controller.config
  constraints = local.controller.constraints
}

module "slurmdbd" {
  source = "git::https://github.com/canonical/slurm-charms//charms/slurmdbd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae"

  model_uuid = var.model_uuid
  app_name   = local.database.app_name
  base       = local.database.base

  channel     = local.database.channel
  revision    = local.database.revision
  machines    = local.database.machines
  units       = local.database.units
  config      = local.database.config
  constraints = local.database.constraints
}

module "slurmrestd" {
  source = "git::https://github.com/canonical/slurm-charms//charms/slurmrestd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae"

  model_uuid = var.model_uuid
  app_name   = local.rest_api.app_name
  base       = local.rest_api.base

  channel     = local.rest_api.channel
  revision    = local.rest_api.revision
  machines    = local.rest_api.machines
  units       = local.rest_api.units
  config      = local.rest_api.config
  constraints = local.rest_api.constraints
}

module "sackd" {
  source = "git::https://github.com/canonical/slurm-charms//charms/sackd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae"

  model_uuid = var.model_uuid
  app_name   = local.kiosk.app_name
  base       = local.kiosk.base

  channel     = local.kiosk.channel
  revision    = local.kiosk.revision
  machines    = local.kiosk.machines
  units       = local.kiosk.units
  config      = local.kiosk.config
  constraints = local.kiosk.constraints
}

# Setup compute plane

module "slurmd_partitions" {
  for_each = var.compute_partitions
  source   = "git::https://github.com/canonical/slurm-charms//charms/slurmd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae"

  model_uuid = var.model_uuid
  app_name   = local.compute_partitions[each.key].app_name
  base       = local.compute_partitions[each.key].base

  channel     = local.compute_partitions[each.key].channel
  revision    = local.compute_partitions[each.key].revision
  machines    = local.compute_partitions[each.key].machines
  units       = local.compute_partitions[each.key].units
  config      = local.compute_partitions[each.key].config
  constraints = local.compute_partitions[each.key].constraints
}
