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
| `database_backend`  | object      | MySQL backend for the Slurm database. Set `name` + `endpoint` (in-model) or `offer_url` (cross-model offer) | |    Y     |
| `kiosk`             | object      | Configuration options for the Slurm kiosk node                    | `{ app_name = "login-node" }`  |          |
| `model_uuid`        | string      | UUID of the target Juju model                                     |                                |    Y     |
| `offered_endpoints` | list(string)| Endpoints to expose as cross-model offers                          | `[]`                           |          |
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

The `database_backend` object configures the MySQL-compatible database backing
the Slurm accounting stack. It accepts the following keys:

| Name                  | Type   | Description                                                                    |
|-----------------------|--------|--------------------------------------------------------------------------------|
| `endpoint`            | string | Endpoint of the in-model application. Only needed to disambiguate the relation |
| `name`                | string | Name of the in-model database application                                      |
| `offer_url`           | string | URL of a cross-model offer exposing the `mysql_client` interface               |
| `offering_controller` | string | Name of the controller hosting the offer, when it differs from the target one  |

Set either `name` (in-model backend) or `offer_url` (cross-model backend).

### Outputs

After applying, the module exports the following outputs:

| Name                 | Description                                                                                          |
|----------------------|------------------------------------------------------------------------------------------------------|
| `components`         | Map of deployed applications, keyed by component name. Partition applications are keyed by partition name |
| `compute_partitions` | Information about the Slurm compute partitions.                                                       |
| `controller`         | Information about the Slurm controller application.                                                   |
| `database`           | Information about the Slurm database application.                                                     |
| `kiosk`              | Information about the Slurm kiosk application.                                                        |
| `offers`             | Map of exposed cross-model offer URLs.                                                                |
| `provides`           | Map of `provides` endpoint names.                                                                     |
| `requires`           | Map of `requires` endpoint names.                                                                     |
| `rest_api`           | Information about the Slurm REST API application.                                                     |

The `provides` and `requires` outputs expose only the endpoints available for
external integration. Endpoints that the module wires itself (e.g. the
relations between the Slurm daemons) are omitted; use the `components` output
for the application names to relate against.

The `provides` output exposes the following endpoints:

| Key                       | Endpoint name      |
|---------------------------|--------------------|
| `sackd_metrics_endpoint`  | `metrics-endpoint` |
| `slurmctld_cos_agent`     | `cos-agent`        |
| `slurmctld_mount`         | `mount`            |
| `slurmd_metrics_endpoint` | `metrics-endpoint` |

The `requires` output exposes the following endpoints:

| Key                     | Endpoint name |
|-------------------------|---------------|
| `slurmctld_influxdb`    | `influxdb`    |
| `slurmctld_oci_runtime` | `oci-runtime` |
| `slurmctld_smtp`        | `smtp`        |

Set `offered_endpoints` to expose endpoints as cross-model offers, using the
keys of the `provides` and `requires` outputs as identifiers. The `offers`
output provides the resulting offer URLs for other models to consume. All keys
are valid except `slurmd_metrics_endpoint` (applications deployed per partition
cannot be offered) and endpoints whose only implementors are subordinate or
container-scoped charms (`slurmctld_cos_agent`, `slurmctld_oci_runtime`, and
`slurmctld_mount`), which cannot be related across models.

## Usage

See the [`slurm`](../../examples/slurm/main.tf) example for an usage example.
