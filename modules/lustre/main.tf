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

module "lustre-server" {
  source = "git::https://github.com/canonical/filesystem-charms//charms/lustre-server/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214"

  app_name   = local.server.app_name
  model_uuid = var.model_uuid
  base       = local.server.base

  channel     = local.server.channel
  revision    = local.server.revision
  machines    = local.server.machines
  units       = local.server.units
  config      = local.server.config
  constraints = local.server.constraints
}

module "filesystem-client" {
  source = "git::https://github.com/canonical/filesystem-charms//charms/filesystem-client/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214"

  app_name   = local.client.app_name
  model_uuid = var.model_uuid
  base       = local.client.base

  channel  = local.client.channel
  revision = local.client.revision
  config   = local.client.config
}

resource "juju_integration" "lustre" {
  model_uuid = var.model_uuid

  application {
    name     = module.lustre-server.application.name
    endpoint = module.lustre-server.provides.filesystem
  }

  application {
    name     = module.filesystem-client.application.name
    endpoint = module.filesystem-client.requires.filesystem
  }
}
