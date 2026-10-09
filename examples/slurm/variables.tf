# Connection details for the Juju controller to deploy into. When null, the
# provider falls back to its default behavior (JUJU_* environment variables
# or the currently logged-in controller). Terragrunt stacks set this from the
# controller unit's outputs; standalone usage can leave it unset.
variable "connection" {
  type = object({
    controller_addresses = string
    username             = string
    password             = string
    ca_certificate       = string
  })
  sensitive = true
  default   = null
}
