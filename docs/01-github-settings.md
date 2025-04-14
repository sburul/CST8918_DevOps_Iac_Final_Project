CST8918 - DevOps: Infrastructure as Code  
Prof. Robert McKenney

# Final Project: Terraform, Azure AKS, and GitHub Actions

## 1. GitHub Repository Initial Settings

One lab partner, create a new repository on GitHub called `cst8918-w25-final-project`. Initialize the repository with a README file and a `.gitignore` file for Terraform.

### Add a Collaborator

Add your lab partner as a collaborator to the repository. This will allow them to push changes, and create or approve pull-requests in the repository.

Near the top of your README.md note the names and college usernames of your team members, and link to their GitHub profiles.

### Branch Protection Rules

To protect the `main` branch, create a branch protection rule-set that:

- Prevents direct pushes to the branch. This will require all changes to be made through a pull-request.
- Restricts deletion of the branch.
- Requires at least one approving review before merging.

Later you should add more rules to this set, but for now, these are the minimum requirements.

### GitHub Environment

The GitHub Actions workflows that you will create utilize GitHub Environments and Secrets to store the azure identity information and setup an approval process for deployments. In the `Settings > Environments` tab of your repository, create an environment named `dev, test, prod`.


#### Deployment Protection Rules

On a bigger team, you may want to require approval before deploying to production. Or, you may want to restrict which branches can deploy to production. These rules can be set in the `Settings > Environments` tab of your repository.

For this lab, set the `prod` environment to only deploy from the `main` branch and require approval before deploying. Set both team members as the only people who can approve the deployment and check the box to `Prevent self-review`.


