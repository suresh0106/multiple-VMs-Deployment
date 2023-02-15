#   Demo main file
################# DEMO ########################
provider "azurerm" {
    skip_provider_registration = true
    features {}
    }
    
    #RG01
    resource "azurerm_resource_group" "rg01" {
      name = "rg-Dev"
      location = "uaenorth"
      tags = {
        "Environment" = "Dev"
        "Deployed from" = "Azure DevOps"

      }
    }

    #RG02
    resource "azurerm_resource_group" "rg02" {
     name = "rg-Prod"
      location = "uaenorth"
      tags = {
      "Environment" = "Prod"
      "Deployed from" = "Azure DevOps"
      }
    }
   
    #RG03
    resource "azurerm_resource_group" "rg03" {
      name = "rg-QA"
      location = "uaenorth"
      tags = {
        "Environment" = "QA"
        "Deployed from" = "Azure DevOps"
      }
    }

    #VNET01
    resource "azurerm_virtual_network" "vnet01" {
        name = "vnet-DevOps-uaen-001"
        location = "uaenorth"
        resource_group_name = azurerm_resource_group.rg01.name
        address_space       = ["10.10.0.0/22"]
        tags = {
        "Deployed from" = "Azure DevOps"
      }
    }
    
    #SNET01
    resource "azurerm_subnet" "snet01" {
      name                 = "snet-Dev-001"
      resource_group_name  = azurerm_resource_group.rg01.name
      virtual_network_name = azurerm_virtual_network.vnet01.name
      address_prefixes     = ["10.10.2.0/24"]
    }
    
    #SNET02
    resource "azurerm_subnet" "snet02" {
      name                 = "snet-Prod-001"
      resource_group_name  = azurerm_resource_group.rg01.name
      virtual_network_name = azurerm_virtual_network.vnet01.name
      address_prefixes     = ["10.10.1.0/24"]
    }
    
    #SNET03
    resource "azurerm_subnet" "snet03" {
      name                 = "snet-QA-001"
      resource_group_name  = azurerm_resource_group.rg01.name
      virtual_network_name = azurerm_virtual_network.vnet01.name
      address_prefixes     = ["10.10.3.0/24"]
    }

    #NSG
    
    resource "azurerm_network_security_group" "nsg01" {
      name = "nsg-snet-QA-001"
      resource_group_name = azurerm_resource_group.rg03.name
      location = "uaenorth" 
      tags = {
        "Environment" = "QA"
        "Deployed from" = "Azure DevOps"
      }
    }
    
    resource "azurerm_network_security_group" "nsg02" {
      name = "nsg-snet--Prod-001"
      resource_group_name = azurerm_resource_group.rg02.name
      location = "uaenorth" 
      tags = {
        "Environment" = "Prod"
        "Deployed from" = "Azure DevOps"
      }
    }
    
    resource "azurerm_network_security_group" "nsg03" {
      name = "nsg-snet-Dev-001"
      resource_group_name = azurerm_resource_group.rg01.name
      location = "uaenorth"
      tags = {
        "Environment" = "Dev"
        "Deployed from" = "Azure DevOps"
      }
    }

    #NSG Association
    
    resource "azurerm_subnet_network_security_group_association" "nsgDev01" {
      subnet_id                 = azurerm_subnet.snet01.id
      network_security_group_id = azurerm_network_security_group.nsg01.id
      depends_on = [azurerm_network_security_group.nsg01
      ]
    }
    
    resource "azurerm_subnet_network_security_group_association" "nsgProd02" {
      subnet_id                 = azurerm_subnet.snet02.id
      network_security_group_id = azurerm_network_security_group.nsg02.id
      depends_on = [azurerm_network_security_group.nsg02
      ]
    }
    
    resource "azurerm_subnet_network_security_group_association" "nsgQA03" {
      subnet_id                 = azurerm_subnet.snet03.id
      network_security_group_id = azurerm_network_security_group.nsg03.id
      depends_on = [azurerm_network_security_group.nsg03
      ]
    }

    # VM Creation - DEV

resource "azurerm_public_ip" "Devpublicip" {
  name                = "Dev"
  location            = "uaenorth"
  resource_group_name = azurerm_resource_group.rg01.name
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "Devvmnic" {
  name                = "Devvm-nic"
  location            = "uaenorth"
  resource_group_name = azurerm_resource_group.rg01.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.snet01.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.Devpublicip.id
    private_ip_address = "10.10.2.8"
  }
}
resource "azurerm_windows_virtual_machine" "VM-01" {
  name                  = "Dev-VM"
  location              = "uaenorth"
  resource_group_name   = azurerm_resource_group.rg01.name
  network_interface_ids = [azurerm_network_interface.Devvmnic.id]
  size                  = "Standard_D2as_v5"
  admin_username        = "adminuser"
  admin_password        = "Password123!"
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    name                 = "DevOsDisk"
    disk_size_gb         = "128"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  tags = {
        "Environment" = "DEV"
        "Deployed from" = "Azure DevOps"
  
    }
}
# VM Creation Ended - DEV

# VM Creation - PROD

resource "azurerm_public_ip" "Prodpublicip" {
  name                = "Prod"
  location            = "uaenorth"
  resource_group_name = azurerm_resource_group.rg02.name
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "Prodvmnic" {
  name                = "Prodvm-nic"
  location            = "uaenorth"
  resource_group_name = azurerm_resource_group.rg02.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.snet02.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.Prodpublicip.id
    private_ip_address = "10.10.1.7"
  }
}
resource "azurerm_windows_virtual_machine" "VM-02" {
  name                  = "Prod-VM"
  location              = "uaenorth"
  resource_group_name   = azurerm_resource_group.rg02.name
  network_interface_ids = [azurerm_network_interface.Prodvmnic.id]
  size                  = "Standard_D2as_v5"
  admin_username        = "adminuser"
  admin_password        = "Password123!"
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  os_disk {
    name                 = "ProdOsDisk"
    disk_size_gb         = "128"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  tags = {
        "Environment" = "PROD"
        "Deployed from" = "Azure DevOps"
  
    }
}
# VM Creation Ended - PROD

# VM Creation - QA

resource "azurerm_public_ip" "QApublicip" {
  name                = "QA"
  location            = "uaenorth"
  resource_group_name = azurerm_resource_group.rg03.name
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "QAvmnic" {
  name                = "QAvm-nic"
  location            = "uaenorth"
  resource_group_name = azurerm_resource_group.rg03.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.snet03.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.QApublicip.id
    private_ip_address = "10.10.3.9"
  }
}
resource "azurerm_windows_virtual_machine" "VM-03" {
  name                  = "QA-VM"
  location              = "uaenorth"
  resource_group_name   = azurerm_resource_group.rg03.name
  network_interface_ids = [azurerm_network_interface.QAvmnic.id]
  size                  = "Standard_D2as_v5"
  admin_username        = "adminuser"
  admin_password        = "Password123!"
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    name                 = "QAOsDisk"
    disk_size_gb         = "128"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  tags = {
        "Environment" = "QA"
        "Deployed from" = "Azure DevOps"
  
    }
}
# VM Creation Ended - QA