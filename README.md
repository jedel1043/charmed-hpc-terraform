# Charmed HPC Terraform

Terraform modules for deploying components of a Charmed HPC cluster.

The [`modules`](./modules) directory contains modules that make use of the
[Juju Terraform Provider](https://github.com/juju/terraform-provider-juju) to interact with a
previously bootstrapped [Juju](https://juju.is) controller.

Furthermore, the [`examples`](./examples) directory offers example deployments that can be copy-pasted
to kickstart your own deployments.

## ✨ Getting started

A Juju 3.x controller [bootstrapped](https://juju.is/docs/juju/bootstrapping) on your choice of cloud is required. Steps for deploying:

```shell
# Prerequisites
juju bootstrap <cloud name> <controller name>
sudo snap install --classic opentofu
```

Then, create a Terraform plan to deploy the core components:

```terraform
terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0, < 3.0"
    }
  }
}

provider "juju" {}

resource "juju_model" "charmed-hpc" {
  name = "charmed-hpc"
}

## MySQL - provides backing database for the accounting node.
module "mysql" {
  source = "git::https://github.com/canonical/mysql-operators//machines/terraform?ref=33d381861060a74c10681eae2feca1ce2ef0c105"

  model         = juju_model.charmed-hpc.uuid
  app_name      = "mysql"
  base          = "ubuntu@26.04"
  channel       = "8.4/edge"
  units         = 1
}

module "slurm" {
  source = "git::https://github.com/canonical/charmed-hpc-terraform//modules/slurm"

  model_uuid = juju_model.charmed-hpc.uuid
  database_backend = {
    name     = module.mysql.app_name,
    endpoint = module.mysql.provides.database
  }

  # Optional settings for the controller node.
  controller = {
    app_name = "slurmctld"
  }

  # Optional settings for the database node.
  database = {
    app_name = "slurmdbd"
  }

  # Optional settings for the REST API node.
  rest_api = {
    app_name = "slurmrestd"
  }

  # Optional settings for the kiosk node.
  kiosk = {
    app_name = "sackd",
    units    = 1,
  }

  # Compute partitions to be deployed.
  compute_partitions = {
    "default" : {
      units = 1,
    },
    "gpu" : {
      units = 1,
    }
  }
  depends_on = [
    juju_model.charmed-hpc
  ]
}
```

Finally, plan and deploy!

```shell
tofu init
tofu plan
tofu apply -auto-approve
```

## 🤔 What's next?

To learn more about the deployment and use of a Charmed HPC cluster, the following resources are available:

* [Charmed HPC Documentation](https://canonical-charmed-hpc.readthedocs-hosted.com/latest)
* [Open an issue](https://github.com/canonical/charmed-hpc-terraform/issues/new?title=ISSUE+TITLE&body=*Please+describe+your+issue*)
* [Ask a question](https://discourse.ubuntu.com/c/project/hpc/151)

## 🛠️ Development

A useful command to help while hacking on the plans is:

```shell
just check  # Checks file formatting and syntax are valid.
```

If you're interested in contributing, take a look at our [contributing guidelines](./CONTRIBUTING.md).

## 🤝 Project and community

The Charmed HPC Terraform plans are a project of the [Ubuntu High-Performance Computing community](https://ubuntu.com/community/governance/teams/hpc). Interested in contributing bug fixes, patches, documentation, or feedback? Want to join the Ubuntu HPC community? You've come to the right place!

Here's some links to help you get started with joining the community:

* [Ubuntu Code of Conduct](https://ubuntu.com/community/ethos/code-of-conduct)
* [Contributing guidelines](./CONTRIBUTING.md)
* [Join the conversation on Matrix](https://matrix.to/#/#hpc:ubuntu.com)
* [Get the latest news or ask and answer questions on the Ubuntu Discourse](https://discourse.ubuntu.com/c/project/hpc/151)

## 📋 License

The Charmed HPC Terraform plans are free software, distributed under the Apache Software License, version 2.0.
See the [Apache-2.0 LICENSE](./LICENSE) file for further details.
