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

resource "juju_controller" "this" {
  name           = var.name
  juju_binary    = var.juju_binary
  bootstrap_base = var.bootstrap_base

  agent_version = var.agent_version

  cloud = merge(
    {
      name       = var.cloud.name
      type       = var.cloud.type
      auth_types = var.cloud.auth_types
    },
    var.cloud.endpoint != null ? { endpoint = var.cloud.endpoint } : {},
    var.cloud.region != null ? { region = var.cloud.region } : {},
    length(var.cloud.ca_certificates) > 0 ? { ca_certificates = var.cloud.ca_certificates } : {},
  )

  cloud_credential = {
    name       = var.cloud_credential.name
    auth_type  = var.cloud_credential.auth_type
    attributes = var.cloud_credential.attributes
  }

  bootstrap_constraints = var.bootstrap_constraints
  controller_config     = var.controller_config
}

# Write a minimal controllers.yaml into the juju_data_dir, for temporary
# CLI access to the controller. Nothing is written when juju_data_dir is
# unset.
resource "local_sensitive_file" "juju-controllers-yaml" {
  count = var.juju_data_dir != null ? 1 : 0

  filename = "${var.juju_data_dir}/controllers.yaml"
  content = yamlencode({
    controllers = {
      (var.name) = {
        uuid          = juju_controller.this.controller_uuid
        api-endpoints = juju_controller.this.api_addresses
        ca-cert       = juju_controller.this.ca_cert
        cloud         = var.cloud.name
      }
    }
    current-controller = var.name
  })
  file_permission = "0600"
}

# Write an accounts.yaml with the admin credentials next to the
# controllers.yaml, so the data directory is pre-authenticated: pointing
# JUJU_DATA at it gives a logged-in client without running `juju login`.
resource "local_sensitive_file" "juju-accounts-yaml" {
  count = var.juju_data_dir != null ? 1 : 0

  filename = "${var.juju_data_dir}/accounts.yaml"
  content = yamlencode({
    controllers = {
      (var.name) = {
        user              = juju_controller.this.username
        password          = juju_controller.this.password
        last-known-access = "superuser"
      }
    }
  })
  file_permission = "0600"
}
