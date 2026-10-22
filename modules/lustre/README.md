# Terraform module for Lustre

This is a Terraform module facilitating the deployment of a [Lustre](https://www.lustre.org/) parallel file system using
the `lustre-server` charm, and the corresponding `filesystem-client` charm to mount the filesystem on Juju machines.

The `lustre-server` charm provisions all Lustre server components (MGS, MDS, and OSS) with ZFS-backed storage pools.
The first unit acts as the MGS+MDS; additional units act as OSSes. A minimum of two units is required for a usable
filesystem.

## Requirements

* Lustre requires kernel modules (built via DKMS) and ZFS, so the server units must run on **virtual machines**, not
  LXD containers.
* On the LXD cloud, the LXD profile Juju generates for the model must have Secure Boot disabled
  (`boot.mode=uefi-nosecureboot`) so the unsigned DKMS modules can be loaded. See the
  [example](../../examples/lustre/main.tf) for how to apply this automatically.

## API

### Inputs

This module offers the following configurable units:

| Name         | Type   | Description                                     | Default        | Required |
|--------------|--------|-------------------------------------------------|----------------|:--------:|
| `model_uuid` | string | UUID of the target Juju model                   |                |    Y     |
| `offered_endpoints` | list(string) | Endpoints to expose as cross-model offers  | `[]`           |          |
| `base`       | string | Base operating system for the Lustre charms     | "ubuntu@26.04" |          |
| `server`     | object | Configuration options for the Lustre server     | `{}`           |          |
| `client`     | object | Configuration options for the filesystem client |                |    Y     |

The `server` object accepts the following properties:

| Name          | Type        | Description                                                                     | Default         | Required |
|---------------|-------------|---------------------------------------------------------------------------------|-----------------|:--------:|
| `app_name`    | string      | Name of the server application                                                  | "lustre-server" |          |
| `base`        | string      | Base operating system for the server. Defaults to the module-level `base`       |                 |          |
| `channel`     | string      | Charm channel to deploy the server from                                         | "latest/edge"   |          |
| `config`      | map(string) | Juju configuration options for the server                                       | `{}`            |          |
| `constraints` | string      | Juju constraints for the server                                                 | ""              |          |
| `machines`    | array       | Machines where the server nodes are deployed. If set, `units` is ignored        | `[]`            |          |
| `revision`    | number      | Charm revision to deploy. Null deploys the latest revision on the given channel |                 |          |
| `units`       | number      | Number of Lustre server units                                                   | 1               |          |

If the `machines` property is set, the `units` variable is ignored.

The `client` object accepts the following properties:

| Name         | Type        | Description                                                                     | Default         | Required |
|--------------|-------------|---------------------------------------------------------------------------------|-----------------|:--------:|
| `app_name`   | string      | Name of the client application                                                  | "lustre-client" |          |
| `base`       | string      | Base operating system for the client. Defaults to the module-level `base`       |                 |          |
| `channel`    | string      | Charm channel to deploy the client from                                         | "latest/edge"   |          |
| `config`     | map(string) | Juju configuration options for the client                                       | `{}`            |          |
| `mountpoint` | string      | Path where the filesystem will be mounted                                       |                 |    Y     |
| `revision`   | number      | Charm revision to deploy. Null deploys the latest revision on the given channel |                 |          |

### Outputs

After applying, the module exports the following outputs:

| Name         | Description                                                                          |
|--------------|--------------------------------------------------------------------------------------|
| `app_name`   | Application name for the `filesystem-client` that is ready to mount the Lustre share |
| `components` | Map of deployed applications, keyed by component name                                |
| `mountpoint` | Path where the Lustre filesystem is mounted on client machines                       |
| `offers`     | Map of exposed cross-model offer URLs.                                               |
| `provides`   | Map of `provides` endpoint names.                                                    |
| `requires`   | Map of `requires` endpoint names.                                                    |

The `provides` and `requires` outputs expose only the endpoints available for
external integration. Endpoints that the module wires itself (the relation
between the Lustre server and the filesystem client) are omitted; use the
`components` output for the application names to relate against.

The `provides` output exposes the following endpoints:

| Key                        | Endpoint name |
|----------------------------|---------------|
| `lustre_server_filesystem` | `filesystem`  |

The `requires` output exposes the following endpoints:

| Key                            | Endpoint name |
|--------------------------------|---------------|
| `filesystem_client_juju_info`  | `juju-info`   |
| `filesystem_client_mount`      | `mount`       |

Set `offered_endpoints` to expose endpoints as cross-model offers, using the
keys of the `provides` and `requires` outputs as identifiers. The `offers`
output provides the resulting offer URLs for other models to consume. Only
`lustre_server_filesystem` can be offered: subordinate and container-scoped
endpoints (`juju-info`, `mount`) cannot be related across models.

## Usage

See the [`lustre`](../../examples/lustre/main.tf) example for an usage example.
