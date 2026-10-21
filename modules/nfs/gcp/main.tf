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

resource "google_filestore_instance" "nfs" {
  name     = "${var.name}-filestore"
  location = var.location
  tier     = var.tier
  protocol = "NFS_V3"

  file_shares {
    name        = local.share_name
    capacity_gb = var.capacity_gb
  }

  networks {
    network = var.network
    modes   = ["MODE_IPV4"]
  }
}

module "nfs-server-proxy" {
  source = "git::https://github.com/canonical/filesystem-charms//charms/nfs-server-proxy/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214"

  app_name   = "${var.name}-server"
  model_uuid = var.model_uuid
  base       = var.base
  channel    = var.nfs_server_proxy_channel
  config = {
    "hostname" : google_filestore_instance.nfs.networks[0].ip_addresses[0]
    "path" : "/${local.share_name}"
  }
}

module "filesystem-client" {
  source = "git::https://github.com/canonical/filesystem-charms//charms/filesystem-client/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214"

  app_name   = "${var.name}-client"
  model_uuid = var.model_uuid
  base       = var.base
  channel    = var.filesystem_client_channel
  config = {
    "mountpoint" : var.mountpoint
  }
}

resource "juju_integration" "nfs" {
  model_uuid = var.model_uuid

  application {
    name     = module.nfs-server-proxy.application.name
    endpoint = module.nfs-server-proxy.provides.filesystem
  }

  application {
    name     = module.filesystem-client.application.name
    endpoint = module.filesystem-client.requires.filesystem
  }
}
