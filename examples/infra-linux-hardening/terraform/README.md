# Testing Effortless Infra Packages with Terraform

## Purpose

This folder contains all the files needed create the resources for testing
Effortless Infra Packages.

At a high level it does the following:
  - Creates the infrastructure for testing
  - Does the following locally:
    - Builds a Chef Habitat artifact
    - Exports the artifact as a tar
    - Uploads the artifact to the remote machine
  - Does the following remotely:
    - Remotely extracts artifact
    - Runs the Chef Infra code in the artifact
  - Finally, it does the following locally
    - Runs Chef InSpec tests located in `../test/functional/` on the remote
      machine

## Requirements

In order to use this testing method you'll need to do the following:
  - Install and configure Chef Habitat
    - [Install Habitat](https://www.habitat.sh/docs/install-habitat/)
    - [Configure Habitat](https://www.habitat.sh/docs/install-habitat/#configure-workstation)
  - Install and configure Terraform (for AWS)
    - [Install Terraform](https://www.terraform.io/downloads.html)
    - [Configure Terraform](https://learn.hashicorp.com/terraform/getting-started/build.html)
  - Install Chef InSpec
    - [Install Chef InSpec](https://www.inspec.io/downloads/)

## Testing

1. Enter the `terraform` directory. This directory contains a pre-configured
   Terraform plan

    ```
    cd terraform/
    ```

2. Copy `example.tfvars`, rename it to `terraform.tfvars`, and modify it with
   the necessary information

3. Use Terraform to provision the infrastructure

    ```
    terraform init
    terraform plan
    terraform apply -auto-approve
    ```

    If you see something incorrect (or the tests fail) do the following:

    ```
    terraform taint aws_instance.default
    terraform apply -auto-approve
    ```

    > NOTE: This will destroy and recreate the server.

4. When you're done testing, use Terraform to destroy the resources

    ```
    terraform destroy -auto-approve
    ```
