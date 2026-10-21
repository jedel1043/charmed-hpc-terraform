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

variable "agent_version" {
  description = "Controller agent version to bootstrap. If null, the latest stable version is used."
  type        = string
  default     = null
  nullable    = true
}

variable "bootstrap_base" {
  description = "Base operating system for the bootstrap machine."
  type        = string
  default     = "ubuntu@24.04"
  nullable    = false
}

variable "bootstrap_constraints" {
  description = "Constraints for the bootstrap machine."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "cloud" {
  description = <<-EOT
    Definition of the cloud where the controller will operate. `name`, `type`,
    and `auth_types` are required. `endpoint` is required for non-public clouds
    (for example, a private LXD or OpenStack endpoint). `region` selects the
    cloud region the controller operates in. `ca_certificates` are required
    when the cloud endpoint uses self-signed certificates.
  EOT
  type = object({
    name            = string
    type            = string
    auth_types      = list(string)
    endpoint        = optional(string)
    region          = optional(object({ name = string, endpoint = optional(string), identity_endpoint = optional(string), storage_endpoint = optional(string) }))
    ca_certificates = optional(list(string), [])
  })
  nullable = false
}

variable "cloud_credential" {
  description = "Cloud credentials used to bootstrap the controller."
  type = object({
    name       = string
    auth_type  = string
    attributes = map(string)
  })
  nullable  = false
  sensitive = true
}

variable "controller_config" {
  description = "Configuration options for the bootstrapped controller."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "juju_binary" {
  description = "Path to the Juju CLI binary. Use /snap/juju/current/bin/juju when Juju is installed as a snap."
  type        = string
  default     = "/snap/juju/current/bin/juju"
  nullable    = false
}

variable "juju_data_dir" {
  description = <<-EOT
    Directory where the Juju data files (controllers.yaml and accounts.yaml) are
    written. Setting this variable opts in to writing them: point the JUJU_DATA
    environment variable at the directory to use the Juju CLI with the
    controller. If null, no Juju data files are written and only the connection
    outputs are available. Existing files with the same names are overwritten.
  EOT
  type        = string
  default     = null
  nullable    = true
}

variable "name" {
  description = "Name to assign to the controller."
  type        = string
  nullable    = false
}
