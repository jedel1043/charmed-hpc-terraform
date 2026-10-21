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

locals {
  compute_partitions = {
    for name, partition in var.compute_partitions : name => {
      app_name    = name
      base        = coalesce(partition.base, var.base)
      channel     = coalesce(partition.channel, var.channel)
      revision    = partition.revision
      units       = length(partition.machines) == 0 ? coalesce(partition.units, 1) : null
      machines    = length(partition.machines) == 0 ? null : partition.machines
      config      = partition.config
      constraints = partition.constraints
    }
  }

  controller = {
    app_name    = var.controller.app_name
    base        = coalesce(var.controller.base, var.base)
    channel     = coalesce(var.controller.channel, var.channel)
    revision    = var.controller.revision
    units       = length(var.controller.machines) == 0 ? coalesce(var.controller.units, 1) : null
    machines    = length(var.controller.machines) == 0 ? null : var.controller.machines
    config      = var.controller.config
    constraints = var.controller.constraints
  }

  database = {
    app_name    = var.database.app_name
    base        = coalesce(var.database.base, var.base)
    channel     = coalesce(var.database.channel, var.channel)
    revision    = var.database.revision
    units       = length(var.database.machines) == 0 ? coalesce(var.database.units, 1) : null
    machines    = length(var.database.machines) == 0 ? null : var.database.machines
    config      = var.database.config
    constraints = var.database.constraints
  }

  kiosk = {
    app_name    = var.kiosk.app_name
    base        = coalesce(var.kiosk.base, var.base)
    channel     = coalesce(var.kiosk.channel, var.channel)
    revision    = var.kiosk.revision
    units       = length(var.kiosk.machines) == 0 ? coalesce(var.kiosk.units, 1) : null
    machines    = length(var.kiosk.machines) == 0 ? null : var.kiosk.machines
    config      = var.kiosk.config
    constraints = var.kiosk.constraints
  }

  rest_api = {
    app_name    = var.rest_api.app_name
    base        = coalesce(var.rest_api.base, var.base)
    channel     = coalesce(var.rest_api.channel, var.channel)
    revision    = var.rest_api.revision
    units       = length(var.rest_api.machines) == 0 ? coalesce(var.rest_api.units, 1) : null
    machines    = length(var.rest_api.machines) == 0 ? null : var.rest_api.machines
    config      = var.rest_api.config
    constraints = var.rest_api.constraints
  }
}
