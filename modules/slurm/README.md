# Terraform module for Slurm Core

This is a Terraform module facilitating the deployment of the core components of a Slurm-based HPC cluster.

## API

### Inputs

This module offers the following configurable units:

| Name                | Type        | Description                                                        | Default                        | Required |
|---------------------|-------------|--------------------------------------------------------------------|--------------------------------|:--------:|
| `base`              | string      | Base operating system for the Slurm charms                        | "ubuntu@26.04"                 |          |
| `channel`           | string      | Channel to deploy the Slurm charms from                           | "latest/edge"                  |          |
| `compute_partitions`| map(object) | Map of Slurm compute partitions to deploy                         | `{ "compute": { units = 1 } }` |          |
| `controller`        | object      | Configuration options for the Slurm controller node               | `{ app_name = "controller" }`  |          |
| `database`          | object      | Configuration options for the Slurm database node                 | `{ app_name = "database" }`    |          |
| `database_backend`  | object      | Information about the application provisioning the Slurm database |                                |    Y     |
| `kiosk`             | object      | Configuration options for the Slurm kiosk node                    | `{ app_name = "login-node" }`  |          |
| `model_uuid`        | string      | UUID of the target Juju model                                     |                                |    Y     |
| `rest_api`          | object      | Configuration options for the Slurm REST API node                 | `{ app_name = "rest-api" }`    |          |

Each deployment option object (`controller`, `database`, `rest_api`, `kiosk`) and
each entry of `compute_partitions` accepts the following keys:

| Name          | Type         | Description                                                                                     |
|---------------|--------------|-------------------------------------------------------------------------------------------------|
| `app_name`    | string       | Name of the deployed Juju application                                                           |
| `base`        | string       | Base operating system for this component. Defaults to the module-level `base`                   |
| `channel`     | string       | Charm channel for this component. Defaults to the module-level `channel`                        |
| `config`      | map(string)  | Charm configuration options                                                                     |
| `constraints` | string       | Juju constraints to apply to the deployment                                                     |
| `machines`    | list(string) | Machines to place the application on. If set, `units` is ignored.                               |
| `revision`    | number       | Charm revision to deploy. Null deploys the latest revision on the given channel                 |
| `units`       | number       | Number of units to deploy when no `machines` are provided (defaults to 1)                       |

### Outputs

After applying, the module exports the following outputs:

| Name                 | Description                                        |
|----------------------|----------------------------------------------------|
| `compute_partitions` | Information about the Slurm compute partitions.    |
| `controller`         | Information about the Slurm controller application |
| `database`           | Information about the Slurm database application.  |
| `kiosk`              | Information about the Slurm kiosk application.     |
| `rest_api`           | Information about the Slurm REST API application.  |

## Usage

See the [`slurm`](../../examples/slurm/main.tf) example for an usage example.
