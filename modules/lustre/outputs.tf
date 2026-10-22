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

output "app_name" {
  value       = module.filesystem-client.application.name
  description = "The name of the filesystem client application."
}

output "components" {
  description = "Map of deployed applications, keyed by component name."
  value = {
    filesystem_client = module.filesystem-client.application
    lustre_server     = module.lustre-server.application
  }
}

output "mountpoint" {
  value       = var.client.mountpoint
  description = "Path where the Lustre filesystem is mounted on client machines."
}

output "offers" {
  description = "Map of exposed cross-model offer URLs, keyed by `<charm_name>_<endpoint>`."
  value       = { for key, offer in juju_offer.offered : key => offer.url }
}

output "provides" {
  description = "Map of provides endpoint names available for external integration, keyed by `<charm_name>_<endpoint>`."
  value = {
    lustre_server_filesystem = "filesystem"
  }
}

output "requires" {
  description = "Map of requires endpoint names available for external integration, keyed by `<charm_name>_<endpoint>`."
  value = {
    filesystem_client_juju_info = "juju-info"
    filesystem_client_mount     = "mount"
  }
}
