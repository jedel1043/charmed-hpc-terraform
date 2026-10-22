# Copyright 2026 Canonical Ltd.
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
  client = {
    app_name = var.client.app_name
    base     = coalesce(var.client.base, var.base)
    channel  = var.client.channel
    config = merge(
      {
        "mountpoint" : var.client.mountpoint
        # Required for the filesystem-client to mount Lustre filesystems.
        "enable-lustre" : "true"
      },
      var.client.config
    )
    revision = var.client.revision
  }

  create_machines = length(var.server.machines) == 0

  offerable_endpoints = {
    lustre_server_filesystem = {
      application = module.lustre-server.application.name
      endpoint    = "filesystem"
    }
  }

  server = {
    app_name    = var.server.app_name
    base        = coalesce(var.server.base, var.base)
    channel     = var.server.channel
    revision    = var.server.revision
    units       = local.create_machines ? var.server.units : null
    machines    = local.create_machines ? null : var.server.machines
    config      = var.server.config
    constraints = var.server.constraints
  }
}
