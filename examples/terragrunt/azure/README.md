# Terragrunt examples on Azure

Each subdirectory deploys a workload on Azure in two Terragrunt units:

1. **`<plan>/controller/`**: bootstraps a Juju controller on Azure (`eastus`).
2. **`<plan>/` (root)**: deploys the workload on that controller. It reads the
   controller's connection details from the `controller` unit's outputs via a
   Terragrunt `dependency` block.

Available plans:

* **`lustre/`**: a Lustre filesystem mounted on an `ubuntu` machine. See `modules/lustre`.
* **`slurm/`**: a Slurm cluster (MySQL, `slurmctld`, `slurmdbd`, `slurmrestd`,
  `sackd`, and two compute partitions). See `modules/slurm`.

Run a plan from its directory:

```shell
cd lustre   # or slurm
terragrunt run --all apply
```

## Prerequisites

* [Terragrunt](https://terragrunt.gruntwork.io/) and
  [OpenTofu](https://opentofu.org/) installed.
* The Juju CLI installed.
* Azure credentials registered with the Juju CLI using the
  `service-principal-secret` auth type (i.e. you have run
  `juju add-credential azure` with an application ID, subscription ID, and
  application password). The plan reuses the same service principal.
* The Azure CLI (`az`), logged in (`az login`).

## Required environment variables

The units take their Azure configuration from the standard `ARM_*` environment
variables.

| Variable              | Description                                    |
| --------------------- | ---------------------------------------------- |
| `ARM_CLIENT_ID`       | Service principal application ID               |
| `ARM_CLIENT_SECRET`   | Service principal application secret           |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID                          |
| `ARM_TENANT_ID`       | Microsoft Entra tenant ID (not stored in Juju) |

The `controller` unit reads these directly for the Juju credential. If you
need to bootstrap the controller with a *different* credential than the one
the `azurerm` provider uses, override the controller's inputs individually
with `TF_VAR_azure_application_id`, `TF_VAR_azure_subscription_id`, and/or
`TF_VAR_azure_application_password`.

## Getting the values

### From the Juju CLI

The application ID, application password, and subscription ID should already be
in your registered Juju credential.

```shell
juju show-credentials azure --show-secrets
```

The credential's `details` section contains `application-id`,
`application-password`, and `subscription-id`.

To export them automatically (requires `yq`):

```shell
cred=$(juju show-credentials azure --show-secrets --format yaml)
export ARM_CLIENT_ID=$(echo "$cred" | yq -r '.["client-credentials"].azure.*.details.application-id')
export ARM_CLIENT_SECRET=$(echo "$cred" | yq -r '.["client-credentials"].azure.*.details.application-password')
export ARM_SUBSCRIPTION_ID=$(echo "$cred" | yq -r '.["client-credentials"].azure.*.details.subscription-id')
```

### From the Azure CLI

The tenant ID is **not** part of the Juju credential, and needs to be fetched
using the Azure CLI:

```shell
export ARM_TENANT_ID=$(az account show --query tenantId -o tsv)
```

## Accessing the controller with the Juju CLI

The controller unit points the controller module's `juju_data_dir` input at a
directory in the gitignored Terragrunt cache. The module writes a minimal Juju
data directory there — a `controllers.yaml` registering the controller and an
`accounts.yaml` with the admin credentials, so the client is pre-authenticated
— and outputs its path as `juju_data_dir`. After `terragrunt run --all apply`
completes, get interactive CLI access to the controller by pointing the
`JUJU_DATA` environment variable at that directory:

```shell
cd examples/terragrunt/azure/lustre/controller   # or azure/slurm/controller

export JUJU_DATA="$(terragrunt output -raw juju_data_dir)"

# Verify access (switch to a model first: a fresh data directory has no
# current model)
juju switch admin/controller
juju status
juju debug-log
```

The `JUJU_DATA` points at a temporary directory containing only the
generated `controllers.yaml` and `accounts.yaml`, so your persistent
`~/.local/share/juju` config is untouched.

## Tearing down

From the plan's directory:

```shell
terragrunt run --all destroy
```

The dependency graph destroys the workload deployment first, then the
controller.
