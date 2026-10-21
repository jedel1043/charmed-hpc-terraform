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

output "api_addresses" {
  description = "API addresses of the controller."
  value       = juju_controller.this.api_addresses
}

output "ca_cert" {
  description = "CA certificate for the controller."
  value       = juju_controller.this.ca_cert
  sensitive   = true
}

output "connection" {
  description = "Connection details for the controller, suitable for configuring a Juju provider in a separate plan."
  value = {
    controller_addresses = join(",", juju_controller.this.api_addresses)
    username             = juju_controller.this.username
    password             = juju_controller.this.password
    ca_certificate       = juju_controller.this.ca_cert
  }
  sensitive = true
}

output "controller_uuid" {
  description = "UUID of the bootstrapped controller."
  value       = juju_controller.this.controller_uuid
}

output "juju_data_dir" {
  description = "Path to the Juju data directory with the controller registered and the admin user already logged in."
  value       = var.juju_data_dir != null ? abspath(var.juju_data_dir) : null
  sensitive   = true
}

output "password" {
  description = "Admin password for the controller."
  value       = juju_controller.this.password
  sensitive   = true
}

output "username" {
  description = "Admin username for the controller."
  value       = juju_controller.this.username
  sensitive   = true
}
