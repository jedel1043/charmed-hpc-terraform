# CC008 compliance checker report — `canonical/charmed-hpc-terraform` @ `main`

| | |
| :--- | :--- |
| **Repository state** | `main` @ `74094c2` (*feat: add machine placement to Slurm module*), pre-CC008-migration |
| **Checker** | `canonical/operator-workflows` `terraform-compliance` @ main (`c81a9cdd5acfba473f2f52a4cfbeed7132062df1`), via `terraform_check.py` with `DEFAULT_SPEC` (CC008) |
| **Date** | 2026-10-23 |
| **Command** | `check_cc008.sh modules/{slurm,lustre,controller,nfs/aws,nfs/azure,nfs/gcp}` |
| **Result** | **6 checked, 0 passed, 6 failed** |

## Summary

| Module | Checker classification | `required-files` | `terraform-config` | `variable-order` | `output-order` | `module-interface` | `module-sources` |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `modules/slurm` | product | ❌ | skip¹ | ❌ | ❌ | ❌ (3) | ✅ |
| `modules/lustre` | product | ❌ | skip¹ | ❌ | ✅ | ❌ (3) | ✅ |
| `modules/controller` | charm | ❌ | skip¹ | ❌ | ❌ | ❌ (8) | ✅ |
| `modules/nfs/aws` | product | ❌ | skip¹ | ❌ | ✅ | ❌ (3) | ✅ |
| `modules/nfs/azure` | product | ❌ | skip¹ | ❌ | ✅ | ❌ (3) | ✅ |
| `modules/nfs/gcp` | product | ❌ | skip¹ | ❌ | ✅ | ❌ (3) | ✅ |

¹ skipped because `terraform.tf` is missing (the modules use the legacy `versions.tf` name).

¹ *No* `terraform.tf` on `main` anywhere, so `Terraform configuration` (required\_version / Juju
provider pin) is skipped repo-wide; the modules do carry a `terraform` block in `versions.tf`
(`required_version >= 1.6.6`, `juju ~> 1.0`).

## Violation classes

The 37 violations fall into two distinct classes:

### 1. Pre-CC008 file/layout debt (15 violations) — being fixed by the migration

* `missing required file: terraform.tf` — all 6 modules use legacy `versions.tf`.
* `missing required file: README.md` — `modules/controller` only.
* Non-alphabetical `variable` / `output` blocks — all 6 modules.

These are mechanical and are addressed by the in-progress CC008 migration of this repository.

### 2. Classification-driven interface demands (22 violations) — the reason for this issue

The checker classifies any module that composes other modules **and** declares a
`juju_integration` (or `juju_offer` / `juju_model` / `juju_secret`) resource as a **product**
module, and then requires the product interface (`risk` variable, `metadata` and `models`
outputs). All four integration-wiring modules of this repository (`slurm`, `lustre`,
`nfs/{aws,azure,gcp}`) are affected.

We believe this classification is incorrect for these modules, per CC008 itself:

* **§Component modules** states component modules "*may NOT work out of the box, but they may be
  dependent on other modules to be fully working. Examples of these may be KFP that depends on
  Kubeflow core services, but also **Kyuubi that requires a PostgreSQL database to be used as
  backend**. These should be handled as external components/charm modules to be integrated
  with.*" — `modules/slurm` is exactly this case: it requires an external MySQL backend, supplied
  through the `database_backend` input variable, and therefore cannot be deployed standalone,
  which is the defining trait of a component module rather than a product.
* **§Component modules → Inputs** itself depicts a `juju_integration` resource created *inside* a
  component module ("Ideally, this can then be used when creating the `juju_integration`
  resource"), so the presence of `juju_integration` cannot be what distinguishes products from
  components.
* **§Product modules** states "*Juju models are defined in Product modules, and then fed to the
  various charm modules and component models that consume juju model UUIDs as inputs*" — all four
  modules consume `model_uuid` as a mandatory input and never create models, which is the
  component-module trait.

`modules/controller` is affected from the opposite direction: it bootstraps a Juju controller,
so a model (and therefore `model_uuid`, `app_name`, a `juju_application`…) cannot exist by
construction. The checker classifies it as a *charm* module (it composes nothing) and demands
the full charm interface, which is structurally inapplicable.

## Raw checker output

<details>
<summary>Full <code>terraform_check.py</code> output (6 modules)</summary>

```
⬇️  Fetching the CC008 compliance checker...
🔍 Checking CC008 compliance for: <worktree>/modules/slurm <worktree>/modules/lustre <worktree>/modules/controller <worktree>/modules/nfs/aws <worktree>/modules/nfs/azure <worktree>/modules/nfs/gcp
Checking 6 Terraform module(s) for compliance (all checks)

Checking <worktree>/modules/slurm (product module)
  Variables: model_uuid, database_backend, base, channel, controller, database, rest_api, kiosk, compute_partitions
  Outputs: controller, database, rest_api, kiosk, compute_partitions
  Module sources: git::https://github.com/canonical/slurm-charms//charms/slurmctld/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae, git::https://github.com/canonical/slurm-charms//charms/slurmdbd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae, git::https://github.com/canonical/slurm-charms//charms/slurmrestd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae, git::https://github.com/canonical/slurm-charms//charms/sackd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae, git::https://github.com/canonical/slurm-charms//charms/slurmd/terraform?ref=9943f751b39268c24167ccddf9dc7145ce69cdae
  FAIL Required files
  - missing required file: terraform.tf
  SKIP Terraform configuration (terraform.tf is missing)
  FAIL Variable ordering
  - variables.tf: variable blocks are not alphabetical: found ['model_uuid', 'database_backend', 'base', 'channel', 'controller', 'database', 'rest_api', 'kiosk', 'compute_partitions'], expected ['base', 'channel', 'compute_partitions', 'controller', 'database', 'database_backend', 'kiosk', 'model_uuid', 'rest_api']
  FAIL Output ordering
  - outputs.tf: output blocks are not alphabetical: found ['controller', 'database', 'rest_api', 'kiosk', 'compute_partitions'], expected ['compute_partitions', 'controller', 'database', 'kiosk', 'rest_api']
  FAIL Module interface
  - product module missing mandatory variable: risk
  - product module missing mandatory output: metadata
  - product module missing mandatory output: models
  PASS Module sources
FAIL <worktree>/modules/slurm

Checking <worktree>/modules/lustre (product module)
  Variables: model_uuid, base, server, client
  Outputs: app_name, mountpoint
  Module sources: git::https://github.com/canonical/filesystem-charms//charms/lustre-server/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214, git::https://github.com/canonical/filesystem-charms//charms/filesystem-client/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214
  FAIL Required files
  - missing required file: terraform.tf
  SKIP Terraform configuration (terraform.tf is missing)
  FAIL Variable ordering
  - variables.tf: variable blocks are not alphabetical: found ['model_uuid', 'base', 'server', 'client'], expected ['base', 'client', 'model_uuid', 'server']
  PASS Output ordering
  FAIL Module interface
  - product module missing mandatory variable: risk
  - product module missing mandatory output: metadata
  - product module missing mandatory output: models
  PASS Module sources
FAIL <worktree>/modules/lustre

Checking <worktree>/modules/controller (charm module)
  Variables: name, cloud, cloud_credential, juju_binary, bootstrap_base, agent_version, bootstrap_constraints, controller_config
  Outputs: controller_uuid, api_addresses, username, password, ca_cert, juju_cli_setup_command, connection
  Module sources: none
  FAIL Required files
  - missing required file: terraform.tf
  - missing required file: README.md
  SKIP Terraform configuration (terraform.tf is missing)
  FAIL Variable ordering
  - variables.tf: variable blocks are not alphabetical: found ['name', 'cloud', 'cloud_credential', 'juju_binary', 'bootstrap_base', 'agent_version', 'bootstrap_constraints', 'controller_config'], expected ['agent_version', 'bootstrap_base', 'bootstrap_constraints', 'cloud', 'cloud_credential', 'controller_config', 'juju_binary', 'name']
  FAIL Output ordering
  - outputs.tf: output blocks are not alphabetical: found ['controller_uuid', 'api_addresses', 'username', 'password', 'ca_cert', 'juju_cli_setup_command', 'connection'], expected ['api_addresses', 'ca_cert', 'connection', 'controller_uuid', 'juju_cli_setup_command', 'password', 'username']
  FAIL Module interface
  - charm module missing mandatory variable: app_name
  - charm module missing mandatory variable: channel
  - charm module missing mandatory variable: config
  - charm module missing mandatory variable: constraints
  - charm module missing mandatory variable: model_uuid
  - charm module missing mandatory variable: revision
  - charm module missing mandatory output: application
  PASS Module sources
FAIL <worktree>/modules/controller

Checking <worktree>/modules/nfs/aws (product module)
  Variables: name, vpc_id, subnet_id, mountpoint, model_uuid, base, nfs_server_proxy_channel, filesystem_client_channel
  Outputs: app_name
  Module sources: terraform-aws-modules/efs/aws, git::https://github.com/canonical/filesystem-charms//charms/nfs-server-proxy/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214, git::https://github.com/canonical/filesystem-charms//charms/filesystem-client/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214
  FAIL Required files
  - missing required file: terraform.tf
  SKIP Terraform configuration (terraform.tf is missing)
  FAIL Variable ordering
  - variables.tf: variable blocks are not alphabetical: found ['name', 'vpc_id', 'subnet_id', 'mountpoint', 'model_uuid', 'base', 'nfs_server_proxy_channel', 'filesystem_client_channel'], expected ['base', 'filesystem_client_channel', 'model_uuid', 'mountpoint', 'name', 'nfs_server_proxy_channel', 'subnet_id', 'vpc_id']
  PASS Output ordering
  FAIL Module interface
  - product module missing mandatory variable: risk
  - product module missing mandatory output: metadata
  - product module missing mandatory output: models
  PASS Module sources
FAIL <worktree>/modules/nfs/aws

Checking <worktree>/modules/nfs/azure (product module)
  Variables: name, quota, mountpoint, resource_group_name, subnet_info, model_uuid, base, nfs_server_proxy_channel, filesystem_client_channel
  Outputs: app_name
  Module sources: git::https://github.com/canonical/filesystem-charms//charms/nfs-server-proxy/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214, git::https://github.com/canonical/filesystem-charms//charms/filesystem-client/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214
  FAIL Required files
  - missing required file: terraform.tf
  SKIP Terraform configuration (terraform.tf is missing)
  FAIL Variable ordering
  - variables.tf: variable blocks are not alphabetical: found ['name', 'quota', 'mountpoint', 'resource_group_name', 'subnet_info', 'model_uuid', 'base', 'nfs_server_proxy_channel', 'filesystem_client_channel'], expected ['base', 'filesystem_client_channel', 'model_uuid', 'mountpoint', 'name', 'nfs_server_proxy_channel', 'quota', 'resource_group_name', 'subnet_info']
  PASS Output ordering
  FAIL Module interface
  - product module missing mandatory variable: risk
  - product module missing mandatory output: metadata
  - product module missing mandatory output: models
  PASS Module sources
FAIL <worktree>/modules/nfs/azure

Checking <worktree>/modules/nfs/gcp (product module)
  Variables: name, network, location, tier, capacity_gb, mountpoint, model_uuid, base, nfs_server_proxy_channel, filesystem_client_channel
  Outputs: app_name
  Module sources: git::https://github.com/canonical/filesystem-charms//charms/nfs-server-proxy/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214, git::https://github.com/canonical/filesystem-charms//charms/filesystem-client/terraform?ref=0a49f1705d62e4fbb8c52360ad4b2372e8b64214
  FAIL Required files
  - missing required file: terraform.tf
  SKIP Terraform configuration (terraform.tf is missing)
  FAIL Variable ordering
  - variables.tf: variable blocks are not alphabetical: found ['name', 'network', 'location', 'tier', 'capacity_gb', 'mountpoint', 'model_uuid', 'base', 'nfs_server_proxy_channel', 'filesystem_client_channel'], expected ['base', 'capacity_gb', 'filesystem_client_channel', 'location', 'model_uuid', 'mountpoint', 'name', 'network', 'nfs_server_proxy_channel', 'tier']
  PASS Output ordering
  FAIL Module interface
  - product module missing mandatory variable: risk
  - product module missing mandatory output: metadata
  - product module missing mandatory output: models
  PASS Module sources
FAIL <worktree>/modules/nfs/gcp

Summary: 6 checked, 0 passed, 6 failed
```

</details>

## Notes

* `<worktree>` above is a read-only `git worktree` checkout of `main`; paths have been
  abbreviated. All findings are reproducible with the command in the header table.
* The full checker rules referenced here are encoded in
  [`terraform_spec.py`](https://github.com/canonical/operator-workflows/blob/main/terraform-compliance/terraform_spec.py)
  (`tying_resource_types = {juju_model, juju_secret, juju_integration, juju_offer}`,
  `module_interfaces[PRODUCT] = {risk, metadata, models, ...}`).
