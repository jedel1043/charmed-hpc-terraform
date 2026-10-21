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

variable "base" {
  description = "Base operating system to deploy the Lustre charms on."
  type        = string
  default     = "ubuntu@26.04"
  nullable    = false
}

variable "client" {
  description = "Configuration options for the filesystem client that mounts the Lustre share."
  type = object({
    app_name   = optional(string, "lustre-client")
    channel    = optional(string, "latest/edge")
    mountpoint = string
    config     = optional(map(string), {})
  })
  nullable = false
}

variable "model_uuid" {
  description = "UUID of the target Juju model."
  type        = string
  nullable    = false
}

variable "server" {
  description = "Configuration options for the Lustre server."
  type = object({
    app_name    = optional(string, "lustre-server")
    units       = optional(number, 1)
    channel     = optional(string, "latest/edge")
    config      = optional(map(string), {})
    constraints = optional(string, "")
    machines    = optional(list(string), [])
  })
  nullable = false
  default  = {}
}
