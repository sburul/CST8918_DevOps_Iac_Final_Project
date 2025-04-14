CST8918 - DevOps: Infrastructure as Code  
Prof. Robert McKenney

# Final Project: Terraform, Azure AKS, and GitHub Actions

## 4. GitHub Secrets
GitHub allows you to store a common set of values (variables or secrets) that can be used in your workflows. These secrets are encrypted and can be used in your workflows to authenticate with external services, or to store sensitive information. Values set at the repository level are available to all workflows in the repository. Values set at the environment level are available only to workflows in the environment and will override repository level values with the same name.

### Repository level secrets
Create four secrets at the repository level. These will be the default values used by  GitHub Actions workflows to authenticate with Azure.
- `AZURE_TENANT_ID` - the `id` of your Azure AD Tenant
- `AZURE_SUBSCRIPTION_ID` - the `id` of your Azure subscription within that tenant
- `AZURE_CLIENT_ID` - the `appId` of the Azure AD application with the `reader` role
- `ARM_ACCESS_KEY` - the `primary_access_key` of the Azure Storage Account that stores the Terraform state file

> [!IMPORTANT]
> See the [Using secrets in GitHub Actions](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-encrypted-secrets-for-a-repository) documentation for more information and instructions for creating them.

### Environment level secrets
In the `production` environment, create a secret for the `AZURE_CLIENT_ID` of the Azure AD application with the `contributor` role. This will allow the `production` environment to deploy the infrastructure and application to Azure.

**The environment level secrets are available only to workflows in the environment and will override repository level values with the same name.**