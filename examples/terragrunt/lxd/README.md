# Terragrunt examples on LXD

Each subdirectory deploys a workload on the local LXD cloud in two Terragrunt
units:

1. **`<plan>/controller/`**: bootstraps a Juju controller on LXD.
2. **`<plan>/` (root)**: deploys the workload on that controller. It reads the
   controller's connection details from the `controller` unit's outputs via a
   Terragrunt `dependency` block.

Available plans:

* **`lustre/`**: a Lustre filesystem mounted on an `ubuntu` machine. The plan
  disables Secure Boot on the LXD profile Juju generates for the model (see
  `examples/lustre/lxd/README.md` for the underlying OpenTofu plan).
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
* LXD installed on the system, with certificate credentials registered
  with the Juju CLI (i.e. you have run `juju add-credential localhost`).

## LXD credentials

The `controller` units take their LXD certificate credentials from the
`LXD_CLIENT_CERT`, `LXD_CLIENT_KEY`, and `LXD_SERVER_CERT` environment
variables when set. Otherwise they fall back to the `localhost` credential
registered with the local Juju client, read directly from
`~/.local/share/juju/credentials.yaml`.

## Accessing the controller with the Juju CLI

The controller unit points the controller module's `juju_data_dir` input at a
directory in the gitignored Terragrunt cache. After `terragrunt run --all apply`
completes, get interactive CLI access to the controller by setting the
`JUJU_DATA` environment variable to that directory:

```shell
cd examples/terragrunt/lxd/lustre/controller   # or lxd/slurm/controller

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
