# Introduction
This repository contains the POC blueprint/solution (terraform code) for compute availability issues seen by Azure Databricks due to regional outage or capacity crunch.

The details of the solution are highlighted in [this document](docs/Azure_Databricks_Compute_Availability.md).

# Prerequisites
- Install `terraform`
- You'll need to the be the Global admin on the subscription or you must request from Global admin to add you as the admin for Azure Databricks. This is required to access the Databricks account page: https://accounts.azuredatabricks.net/

# Usage
This repository contains 2 main modules:
| Name                   | Notes                 |
| -----------------------|---------------------- |
| azure                  | This provisions the Azure resources such as Resource Groups, Storage Accounts, Access Connectors and Azure Databricks workspace in primary and alternate regions.                      |
| databricks             | This provisions Databricks specific features such as Unity Catalog (with schema and table), Delta Sharing across primary and alternate regions and the respective Jobs/Notebooks.      |

Follow the steps mentioned below to setup the provision the infrastruture:

## Installing `Azure` module

- Open a new terminal window and run the command: `az login` and select the relevant subscription.
- Fetch the Azure Subscription ID from the Azure Portal. Add the fetched value in the 'subscription_id' variable in terraform.tfvars file.
- Also, add primary and alternate region names (azure regions) in terraform.tfvars
- Once the the required values such as 'subscription_id', 'primary' and 'alternate' regions are added, run the following terraform commands on the terminal.
    - `terraform init`
    - `terraform plan`
    - `terraform apply`
- NOTE: Sometimes, it takes time for the created resources to show up and hence might throw some errors due to missing dependencies. Its OK to run `terraform apply` multi-times. It will only create the resources which are not created or errored out before.

## Installing `Databricks` features

- The Azure Databricks installed comes up with default metastore. We need to delete those default metastores as there can only be 1 metastore per region. To delete the metastore, go to https://accounts.azuredatabricks.net/ and then select the `Catalog` tab on left pane. There you'll see the default metastore for that region. Click on it and in options (3 ellipsis) tab, you'll find the option to delete the metastore.
- Open a new terminal window. Run command `az login` and select the same subscription as selected in earlier step.
- Fetch the Azure Subscription ID from the Azure Portal. Add the fetched value in the 'subscription_id' variable in terraform.tfvars file.
- Fetch the Account ID from the https://accounts.azuredatabricks.net/. It will be under the My Account tab/icon (top right corner). Add this value in the `databricks_account_id` variable in terraform.tfvars in databricks folder.
- Add primary and alternate region names (azure regions) in terraform.tfvars (databricks folder).
- Also, you can change the default value of the following variables in terraform.tfvars as per requirements: 'delta_sharing_token_expiry', 'cluster_vm_sku_type', 'auto_termination_minutes' 
- Once the the required values are added, run the following terraform commands on the terminal.
    - `terraform init`
    - `terraform plan`
    - `terraform apply`
- NOTE: Sometimes, it takes time for the created resources to show up and hence might throw some errors due to missing dependencies. Its OK to run `terraform apply` multi-times. It will only create the resources which are not created or errored out before.

## Destroying the resources

- To remove the provisioned resources, run the following commands:
    - In terminal, go to databricks folder and run `terraform destroy`
    - In terminal, go to azure folder and run `terraform destroy`.
- NOTE: Once, the azure resources are destroyed, there are 2 managed resource groups created for Databricks workspaces. You'll need to delete them manually from the Azure portal.
