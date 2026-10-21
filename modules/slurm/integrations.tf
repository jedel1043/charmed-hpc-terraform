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

resource "juju_integration" "sackd-to-slurmctld" {
  model_uuid = var.model_uuid

  application {
    name     = module.sackd.application.name
    endpoint = module.sackd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.sackd
  }
}

resource "juju_integration" "slurmdbd-to-slurmctld" {
  model_uuid = var.model_uuid

  application {
    name     = module.slurmdbd.application.name
    endpoint = module.slurmdbd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.slurmdbd
  }
}

resource "juju_integration" "slurmrestd-to-slurmctld" {
  model_uuid = var.model_uuid

  application {
    name     = module.slurmrestd.application.name
    endpoint = module.slurmrestd.provides.slurmctld
  }

  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.slurmrestd
  }
}

resource "juju_integration" "slurmdbd-to-mysql" {
  model_uuid = var.model_uuid

  application {
    name     = module.slurmdbd.application.name
    endpoint = module.slurmdbd.requires.database
  }

  application {
    name     = var.database_backend.name
    endpoint = var.database_backend.endpoint
  }
}

# Setup compute plane

resource "juju_integration" "slurmd-to-slurmctld" {
  for_each   = module.slurmd_partitions
  model_uuid = var.model_uuid

  application {
    name     = each.value.application.name
    endpoint = each.value.provides.slurmctld
  }

  application {
    name     = module.slurmctld.application.name
    endpoint = module.slurmctld.requires.slurmd
  }
}
