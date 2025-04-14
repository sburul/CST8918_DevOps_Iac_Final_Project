CST8918 - DevOps: Infrastructure as Code  
Prof. Robert McKenney

# Final Project: Terraform, Azure AKS, and GitHub Actions

## 3. Create Azure credentials to be used by GitHub Actions


## Overview
You will configure a CI/CD pipeline on Azure using GitHub Actions and Terraform. The process involves creating Azure credentials for GitHub Actions to authenticate with Azure, configuring federated credentials for different environments (such as production and pull request), and setting up the necessary roles for deployment and validation tasks.

### 1. **Create Azure Credentials for GitHub Actions**
To enable GitHub Actions to perform CI/CD tasks, you need to create two service accounts:
- **Read-Only Access**: This will be used for pre-deployment validation tasks.
- **Read/Write Access**: This will be used for deploying infrastructure and applications.

### Prerequisites
- **Azure Subscription ID** and **Azure Tenant ID**: Retrieve these values with the `az account show` command and set them as environment variables for easier access.
  
  ```bash
  export subscriptionId=$(az account show --query id -o tsv)
  export tenantId=$(az account show --query tenantId -o tsv)
  ```

- **Resource Group Name**: You can fetch this with the `terraform output` command.

  ```bash
  export resourceGroupName=$(terraform output -raw resource_group_name)
  ```

### 2. **Create Azure AD Applications with Service Principals**
Next, you'll create two Azure AD applications and service principals. These will be used for GitHub Actions to authenticate and authorize different actions within Azure.

#### **Contributor Role (For Deployment)**
1. Create the Azure AD application for the contributor role:

   ```bash
   az ad app create --display-name <your-college-id>-githubactions-rw
   ```

2. Get the `appId` and store it in a variable:

   ```bash
   export appIdRW=<appId>
   ```

3. Create the service principal:

   ```bash
   az ad sp create --id $appIdRW
   ```

4. Get the service principal object ID:

   ```bash
   export assigneeObjectId=$(az ad sp show --id $appIdRW --query id -o tsv)
   ```

5. Assign the **Contributor role** to the service principal for the resource group:

   ```bash
   az role assignment create \
     --role Contributor \
     --subscription $subscriptionId \
     --assignee-object-id $assigneeObjectId \
     --assignee-principal-type ServicePrincipal \
     --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName
   ```

#### **Reader Role (For Validation)**
1. Create the Azure AD application for the reader role:

   ```bash
   az ad app create --display-name <your-college-id>-githubactions-r
   ```

2. Get the `appId` and store it in a variable:

   ```bash
   export appIdR=<appId>
   ```

3. Create the service principal:

   ```bash
   az ad sp create --id $appIdR
   ```

4. Get the service principal object ID:

   ```bash
   export assigneeObjectId=$(az ad sp show --id $appIdR --query id -o tsv)
   ```

5. Assign the **Reader role** to the service principal for the resource group:

   ```bash
   az role assignment create \
     --role Reader \
     --subscription $subscriptionId \
     --assignee-object-id $assigneeObjectId \
     --assignee-principal-type ServicePrincipal \
     --scope /subscriptions/$subscriptionId/resourceGroups/$resourceGroupName
   ```

### 3. **Create Federated Credentials**
Federated credentials will allow GitHub Actions to authenticate using Azure AD and perform specific tasks in the CI/CD pipeline.

#### **Production Deployment Federated Credential**
Create a federated credential for GitHub Actions triggered during production deployment (when a pull request is merged to the main branch). This will map to the **Contributor** service principal.

1. Create the federated credential JSON file:

   ```json
   {
     "name": "production-deploy",
     "issuer": "https://token.actions.githubusercontent.com",
     "subject": "repo:<your-github-username>/<repo-name>:environment:production",
     "description": "CST8918 Lab12 - GitHub Actions",
     "audiences": ["api://AzureADTokenExchange"]
   }
   ```

2. Create the federated credential:

   ```bash
   az ad app federated-credential create \
     --id $appIdRW \
     --parameters az-federated-credential-params/production-deploy.json
   ```

#### **Pull Request Federated Credential**
Create a federated credential for GitHub Actions triggered during pre-merge checks (pull request events). This will map to the **Reader** service principal.

1. Create the federated credential JSON file:

   ```json
   {
     "name": "pull-request",
     "issuer": "https://token.actions.githubusercontent.com",
     "subject": "repo:<your-github-username>/<repo-name>:pull_request",
     "description": "CST8918 Lab12 - GitHub Actions",
     "audiences": ["api://AzureADTokenExchange"]
   }
   ```

2. Create the federated credential:

   ```bash
   az ad app federated-credential create \
     --id $appIdR \
     --parameters az-federated-credential-params/pull-request.json
   ```

#### **Branch Main Federated Credential**
Create a federated credential for GitHub Actions triggered on any push or pull request event on the `main` branch. This will again map to the **Reader** service principal.

1. Create the federated credential JSON file:

   ```json
   {
     "name": "branch-main",
     "issuer": "https://token.actions.githubusercontent.com",
     "subject": "repo:<your-github-username>/<repo-name>:branch:main",
     "description": "CST8918 Lab12 - GitHub Actions",
     "audiences": ["api://AzureADTokenExchange"]
   }
   ```

2. Create the federated credential:

   ```bash
   az ad app federated-credential create \
     --id $appIdR \
     --parameters az-federated-credential-params/branch-main.json
   ```

### 4. **Final Steps**
At this point, you have created the necessary Azure Active Directory (AAD) applications, service principals, and federated credentials. GitHub Actions will use these credentials to authenticate with Azure and perform CI/CD tasks securely. The credentials are now stored in Azure AD and ready to be used by GitHub Actions to access the resources.

### References
- [Microsoft Learn: Create Federated Credentials](https://learn.microsoft.com)
- [GitHub Actions Azure Integration](https://learn.microsoft.com/en-us/azure/developer/github-actions)

