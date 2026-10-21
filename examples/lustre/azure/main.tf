terraform {
  required_version = ">= 1.6.6"

  required_providers {
    juju = {
      source  = "juju/juju"
      version = ">= 1.0, < 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.17"
    }
  }
}

provider "juju" {
  controller_addresses = var.connection != null ? var.connection.controller_addresses : null
  username             = var.connection != null ? var.connection.username : null
  password             = var.connection != null ? var.connection.password : null
  ca_certificate       = var.connection != null ? var.connection.ca_certificate : null
  skip_failed_deletion = true
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lustre-group" {
  name     = "lustre-group"
  location = var.location
}

resource "azurerm_virtual_network" "lustre-vnet" {
  name                = "lustre-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lustre-group.location
  resource_group_name = azurerm_resource_group.lustre-group.name
}

resource "azurerm_subnet" "lustre-subnet" {
  name                 = "lustre-subnet"
  resource_group_name  = azurerm_resource_group.lustre-group.name
  virtual_network_name = azurerm_virtual_network.lustre-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "lustre-nsg" {
  name                = "lustre-nsg"
  location            = azurerm_resource_group.lustre-group.location
  resource_group_name = azurerm_resource_group.lustre-group.name

  security_rule {
    name                       = "Allow-SSH"
    description                = "Open SSH inbound ports"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
  }
}

resource "azurerm_subnet_network_security_group_association" "lustre-nsg-to-subnet" {
  subnet_id                 = azurerm_subnet.lustre-subnet.id
  network_security_group_id = azurerm_network_security_group.lustre-nsg.id
}

resource "juju_model" "charmed-hpc" {
  name = "charmed-hpc"

  cloud {
    name   = "azure"
    region = var.location
  }

  config = {
    resource-group-name = azurerm_resource_group.lustre-group.name
    network             = azurerm_virtual_network.lustre-vnet.name

    # Enable IPoIB before any charm is deployed. See:
    # https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/enable-infiniband#enable-ip-over-infiniband-ib
    # Note: instructions are incorrect, the current waagent.conf does not include `# OS.EnableRDMA=n` and the service
    # name is `walinuxagent`, not `waagent`.
    cloudinit-userdata = <<-EOT
      #cloud-config
      packages:
        - rdma-core
      write_files:
        - path: /etc/waagent.conf
          append: true
          content: |
            OS.EnableRDMA=y
      postruncmd:
        - systemctl restart walinuxagent
    EOT
  }
}

resource "juju_machine" "lustre-server" {
  count       = var.server_units
  model_uuid  = juju_model.charmed-hpc.uuid
  base        = "ubuntu@26.04"
  constraints = "instance-type=${var.server_vm_size}"
  placement   = "subnet=${azurerm_subnet.lustre-subnet.name}"
}

module "lustre-share" {
  source     = "../../../modules/lustre"
  model_uuid = juju_model.charmed-hpc.uuid

  server = {
    machines = [for machine in juju_machine.lustre-server : machine.machine_id]
  }

  client = {
    mountpoint = "/lustre"
  }
}

resource "juju_machine" "ubuntu" {
  model_uuid = juju_model.charmed-hpc.uuid
  base       = "ubuntu@26.04"
  placement  = "subnet=${azurerm_subnet.lustre-subnet.name}"
}

resource "juju_application" "ubuntu" {
  name       = "ubuntu"
  model_uuid = juju_model.charmed-hpc.uuid
  machines   = [juju_machine.ubuntu.machine_id]

  charm {
    name = "ubuntu"
    base = "ubuntu@26.04"
  }
}

# Since the filesystem client is a subordinate charm, it uses
# the `juju-info` endpoint to integrate with other charms.
resource "juju_integration" "ubuntu-to-filesystem-client" {
  model_uuid = juju_model.charmed-hpc.uuid

  application {
    name     = juju_application.ubuntu.name
    endpoint = "juju-info"
  }

  application {
    name     = module.lustre-share.app_name
    endpoint = "juju-info"
  }
}
