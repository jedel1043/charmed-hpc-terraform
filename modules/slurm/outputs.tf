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

output "components" {
  description = "Map of deployed applications, keyed by component name. Partition applications are keyed by partition name."
  value       = local.component_applications
}

output "compute_partitions" {
  description = "Information about the Slurm compute partitions."
  value = {
    for key, value in module.slurmd_partitions : key => {
      app_name = value.application.name,
      provides = value.provides
    }
  }
}

output "controller" {
  description = "Information about the Slurm controller application."
  value = {
    app_name = module.slurmctld.application.name
    requires = module.slurmctld.requires
  }
}

output "database" {
  description = "Information about the Slurm database application."
  value = {
    app_name = module.slurmdbd.application.name
    provides = module.slurmdbd.provides
    requires = module.slurmdbd.requires
  }
}

output "kiosk" {
  description = "Information about the Slurm kiosk application."
  value = {
    app_name = module.sackd.application.name
    provides = module.sackd.provides
  }
}

output "offers" {
  description = "Map of exposed cross-model offers, keyed by `<charm_name>_<endpoint>`."
  value = { for key, offer in juju_offer.offered : key => {
    kind = "offer"
    url  = offer.url
  } }
}

output "provides" {
  description = "Map of provides endpoints available for external integration, keyed by `<charm_name>_<endpoint>`."
  value = {
    sackd_metrics_endpoint = {
      kind       = "endpoint"
      name       = module.sackd.application.name
      endpoint   = "metrics-endpoint"
      controller = null
    }
    slurmctld_cos_agent = {
      kind       = "endpoint"
      name       = module.slurmctld.application.name
      endpoint   = "cos-agent"
      controller = null
    }
    slurmctld_mount = {
      kind       = "endpoint"
      name       = module.slurmctld.application.name
      endpoint   = "mount"
      controller = null
    }
  }
}

output "requires" {
  description = "Map of requires endpoints available for external integration, keyed by `<charm_name>_<endpoint>`."
  value = {
    slurmctld_influxdb = {
      kind       = "endpoint"
      name       = module.slurmctld.application.name
      endpoint   = "influxdb"
      controller = null
    }
    slurmctld_oci_runtime = {
      kind       = "endpoint"
      name       = module.slurmctld.application.name
      endpoint   = "oci-runtime"
      controller = null
    }
    slurmctld_smtp = {
      kind       = "endpoint"
      name       = module.slurmctld.application.name
      endpoint   = "smtp"
      controller = null
    }
  }
}

output "rest_api" {
  description = "Information about the Slurm REST API application."
  value = {
    app_name = module.slurmrestd.application.name
    provides = module.slurmrestd.provides
  }
}
