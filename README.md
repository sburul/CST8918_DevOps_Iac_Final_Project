## Team Member 1: [Gulsah Avsar](https://github.com/GulsahAvsar)

## Team Member 2: [Lokman Avsar](https://github.com/Lokmanavsar)

## Team Member 3: [Serpil Dundar](https://github.com/Serpil-Dndr)

## Team Member 4: [Seyfullah Burul](https://github.com/sburul)


# Note:This instruction file has been added temporarily, it will be rearranged before submission.


## Instructions
CST8918 - DevOps: Infrastructure as Code \ Prof: Robert McKenney

# Final Project: Terraform, Azure AKS, and GitHub Actions

## Overview

This capstone project applies the many Infrastructure as Code (IaC) topics that you have learned this term. You will revisit the Remix Weather Application from week 3 and use Terraform to creat the required Azure resources. Your project will deploy Azure Kubernetes Service (AKS) clusters and a managed Redis DB to support the Remix Weather Application. You will use GitHub Actions to automate the Terraform workflows.

The Azure configuration will be stored in a Terraform backend in Azure Blob Storage. The Terraform code will be organized into modules to manage the resources. The project will simulate a real-world scenario with multiple team members collaborating on the project, and multiple environments (dev, test, prod) to manage.

### Automated tests

For this project you can ignore application level tests. The focus is on the infrastructure tests. You should include the following tests in your GitHub Actions workflows:

- All static tests should run on any push to any branch.
- Terraform plan and tflint should run on any pull request to the main branch.

### Deployment

To assist with PR reviews and approval, if there is an application code change, the Remix Weather Application should be built and deployed to the test environment on any pull request to the main branch.

Any infrastructure changes should be deployed when the pull request is approved and merged to the main branch. If there is an application code change, the Remix Weather Application should be deployed to the production environment once the pull request is approved and merged to the main branch.

This workflow assumes that the application code and infrastructure code are in the same repository, and that infrastructure changes and application changes are managed in _separate_ pull requests.

## Requirements

### Collaboration

- One team member: create a GitHub repository for the project
- Add your professor (rlmckenney) as a collaborator to the repository
- Add your team members as collaborators to the repository
- Configure branch protection rules for the main branch
  - Require pull request reviews before merging (no direct push to main branch)
  - Require status checks to pass before merging
  - Require branches to be up to date before merging
  - Require at least one approving review before merging (no self-approval)
- Include a README.md file the describes the project, names the team members with links to their GitHub profiles and any special instructions for running the project.
- Each team member must contribute to the project by creating pull requests to the main branch. Remember to create a new branch for each feature or bug fix and keep the unit of work small.

### Define Resources

The application code and the infrastructure code should be in the same repository. The infrastructure code should be organized into Terraform modules to manage the resources. The Terraform code should be organized into the following modules:

- Create a Terraform module to configure Azure Blob Storage as the Terraform backend
- Create a Terraform module for the base network infrastructure
  - resource group named `cst8918-final-project-group-<your group number from Brightspace>`
  - virtual network with IP address space 10.0.0.0/14
  - 4 subnets, where the second octet of the IP address space is used to represent the environment
    - `prod` with IP address space 10.0.0.0/16
    - `test` with IP address space 10.1.0.0/16
    - `dev` with IP address space 10.2.0.0/16
    - `admin` with IP address space 10.3.0.0/16
- Create a Terraform module for the AKS clusters
  - Create an AKS cluster in the `test` environment
    - 1 node
    - Standard B2s VM size
    - Kubernetes version 1.32
  - Create an AKS cluster in the `prod` environment
    - min 1 node
    - max 3 nodes
    - Standard B2s VM size
    - Kubernetes version 1.32
- Create a Terraform module to define the resources for the Remix Weather Application
  - Use the Remix Weather Application from week 3
  - Create an Azure Container Registry (ACR) to store the Docker image
  - Create an Azure Kubernetes Service (AKS) cluster to host the application in the test environment
  - Create an Azure Kubernetes Service (AKS) cluster to host the application in the production environment
  - Create a managed Redis DB (Azure Cache for Redis) to cache the weather API data in the test environment
  - Create a managed Redis DB (Azure Cache for Redis) to cache the weather API data in the production environment
  - Create a Kubernetes deployment and service for the Remix Weather Application

### Automate Workflows

- Create Azure federated identities for the GitHub Actions workflows (see lab from week 12)
- Create a GitHub Actions workflow to run all Terraform static code analysis tasks (fmt, validate, tfsec) on "push" to any branch
- Create a GitHub Actions workflow to run "tflint" and "terraform plan" on "pull_request" to the main branch
- Create a GitHub Actions workflow to run "terraform apply" on "push" to the main branch
- Create a GitHub Actions workflow to build and push the Docker image for the Weather App to the ACR
  - only when the application code changes
  - on "pull_request" to the main branch
  - tag the Docker image with the commit SHA
- Create a GitHub Actions workflow to deploy the Remix Weather Application to the AKS cluster
  - only when the application code changes
  - to the test environment on "pull_request" to the main branch
  - to the production environment on "push" to the main branch (merge of pull request)

## Submission

Only one submission per team is required. Include the following in your submission:

- Submit the URL to your GitHub repository in Brightspace
- Do not forget to add your professor (rlmckenney) as a collaborator to the repository!
- Include a README.md file that describes the project, names the team members with links to their GitHub profiles, and any special instructions for running the project
  - Include a screenshot of the completed GitHub Actions workflows in your repository

## Clean Up

Once you have tested and submitted your project, you should delete the Azure resources to avoid incurring overuse charges and a potential 10% grade penalty.