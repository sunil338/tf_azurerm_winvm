terraform {
  cloud {
    organization = "sunilmuradi"
    workspaces {
      name = "tf_cloud-with-ansible_playbook"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "admin_password" { sensitive = true }
variable "allowed_ip" { default = "0.0.0.0/0" }
variable "location" { default = "poland" }
variable "prefix"   { default = "winvm" }

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "3389"
    source_address_prefix      = var.allowed_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowWinRM"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    destination_port_range     = "5986"
    source_address_prefix      = var.allowed_ip
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "${var.prefix}-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = "Standard_D4s_v5"
  admin_username        = "azureadmin"
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.prefix}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
}

resource "azurerm_virtual_machine_extension" "winrm" {
  name                 = "enable-winrm"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    commandToExecute = "powershell -Command \"Enable-PSRemoting -Force; winrm quickconfig -q; winrm set winrm/config/service '@{AllowUnencrypted=\"false\"}'; winrm set winrm/config/service/auth '@{Basic=\"false\"}'; New-NetFirewallRule -Name 'WinRM-HTTPS' -DisplayName 'WinRM over HTTPS' -Protocol TCP -LocalPort 5986 -Action Allow\""
  })
}

output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}
