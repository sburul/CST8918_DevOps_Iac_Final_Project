CST8918 - DevOps: Infrastructure as Code  
Prof. Robert McKenney

# Final Project: Terraform, Azure AKS, and GitHub Actions

## 2. Create Azure infrastructure to store Terraform state

As you will be using GitHub Actions to run Terraform, you will need to store the Terraform state file in a remote location. In this lab, you will use an Azure Storage Account to store the Terraform state file.

All of the Terraform configuration for the storage account and container should be created in the `infra/tf-backend` folder. This will keep the Terraform configuration for the storage account and container separate from the configuration for the AKS cluster.

> [!WARNING]
> The `tf-backend` and `tf-app` folders are separate Terraform configurations. Commands like `terraform init`, `terraform plan`, and `terraform apply` should be run in each folder separately.

The reason for separating the two configurations is because the storage account and container are used to store the Terraform state file for the app infrastructure configuration. If the backend infrastructure and app infrastructure are in the same configuration, you will run into a chicken-and-egg problem where the Terraform state file is stored in the storage account that is being created by Terraform.

### Create the backend Terraform configuration

This will be a simple configuration with only the necessary resources to store the Terraform state file. It can all go in the `main.tf` file. The configuration should include:

- the `terraform` block
- the `provider` block
- a resource group called `cst8918-final-project-group-<group-number>-backend-rg`
- a storage account named `cst8918storageaccountgr<group-number>`
- the storage account should require a minimum version of `TLS1_2`
- a container in the storage account called `tfstate` - make sure it is private

> [!TIP]
> Remember that the storage account name must be unique across all of Azure, and must be between 3 and 24 characters in length. **Use only lowercase letters and numbers.**

The output of the configuration should be the _resource group name_, _storage account name_, the _container name_ and the _primary access key_ (which will be added to the GitHub secrets). These will be the values that you need to use in the app infrastructure configuration's `backend` block.

### Verify the and deploy the backend Terraform configuration

You will deploy the backend Terraform configuration using your local AZ CLI credentials. You will need to have the Azure CLI installed and be logged in to your Azure account. Then you can run the following commands to validate and deploy the backend configuration.

#### Add main.tf configuration
In the `infra/tf-backend` directory, create a new file called `main.tf` and add the following content.

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
  subscription_id = "<subsciption-id>"
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "cst8918-final-project-group-2-backend-rg"
  location = "canadacentral"
}

# Storage Account Info
resource "azurerm_storage_account" "storage" {
  name                     = "cst8918storageaccountgr2"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

# Storage Account Container
resource "azurerm_storage_container" "container" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}
```

#### Add variables.tf configuration
In the `infra/tf-backend` directory, create a new file called `variables.tf` and add the following content.

```hcl
# Define config variables
variable "labelPrefix" {
  type        = string
  default     = "cst8918-final-project-group-2"
  description = "Prefix label for resources"

}

# Region
variable "region" {
  default = "canadacentral"
}
```

#### Add outputs.tf configuration
In the `infra/tf-backend` directory, create a new file called `outputs.tf` and add the following content.

```hcl
# Define outputs
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "container_name" {
  value = azurerm_storage_container.container.name
}

output "arm_access_key" {
  value     = azurerm_storage_account.storage.primary_access_key
  sensitive = true
} 
```

```bash
cd infra/tf-backend
terraform init
terraform fmt
terraform validate
terraform plan --out=tf-backend.plan
terraform apply tf-backend.plan
```

## Create the base Terraform configuration for the app infrastructure

#### Add terraform.tf configuration
In the `infra/tf-app` directory, create a new file called `terraform.tf` and add the following content.

```hcl
terraform {
  required_version = ">= 1.0.0"

  backend "azurerm" {
    resource_group_name  = "cst8918-final-project-group-2-backend-rg"
    storage_account_name = "cst8918storageaccountgr2"
    container_name       = "tfstate"
    key                  = "prod.app.tfstate"
    use_oidc             = true
    subscription_id = "<subscription-id>"
  }
} 
```

#### Add main.tf configuration
In the `infra/tf-app` directory, create a new file called `main.tf` and add the following content.

```hcl
# Create resource group for all resources
resource "azurerm_resource_group" "rg" {
  name     = "${var.labelPrefix}-rg"
  location = var.region
}
 
```

In the `infra/tf-app` directory, create a new file called `provider.tf` and add the following content.

```hcl
# Configure the Terraform runtime requirements.
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    # Azure Resource Manager provider and version
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.6" 
    }
  }

}

provider "azurerm" {
  # Leave the features block empty to accept all defaults
  features {}
  subscription_id = "<subsciption-id>"

}

provider "cloudinit" {
  # Configuration options
}
```

In the `infra/tf-app` directory, create a new file called `variables.tf` and add the following content.

```hcl
# Define config variables
variable "labelPrefix" {
  type        = string
  default     = "cst8918-final-project-group-2"
  description = "Prefix label for resources"

}

# Region
variable "region" {
  default = "canadacentral"
}
```

In the `infra/tf-app` directory, create a new file called `outputs.tf` and add the following content.

```hcl
# Define output values for later reference
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
```

### Test it!

Remember, one of the best practice strategies from software development is to develop in small increments and test often. Run the following commands to validate and deploy the Terraform configuration.

> [!IMPORTANT]
> Before you can test the Terraform configuration, you will need to set the `ARM_ACCESS_KEY` environment variable to the primary access key of the storage account. You can get this from the output of the backend Terraform configuration. You can set the environment variable with the following command:

```bash
# in the infra/tf-backend folder

export ARM_ACCESS_KEY=$(terraform output -raw arm_access_key)
```

Then you can run the following commands to validate and deploy the Terraform configuration.

```bash
# in the infra/tf-app folder

terraform init
terraform fmt
terraform validate
terraform plan --out=tf-app.plan
terraform apply tf-app.plan
```

- Verify that there were no errors in the output of the `terraform apply` command.
- Verify that the resource group was created in the Azure portal.
- Verify that the Terraform state file was created in the storage account.

OK - now you have the base Terraform configuration for the app infrastructure, and it correctly connects to Azure Blob Storage for the remote Terraform state file. You will add the AKS cluster and the deployment of the sample web application later in this lab. For now, you will complete the steps to create the GitHub Actions CI/CD workflows.

