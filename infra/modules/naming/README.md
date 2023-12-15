# Terraform Naming Standard

This repo houses the naming standard for Terraform hosted in Azure.

***When creating a new naming standard, please try to adhere to the Azure guidance***: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging

**Output breakdown**
`resource-group       = lower("rg-${var.env}-${var.location-map[var.location]}-${local.subId}")`

| Key                                 | Description                                                  |
| ----------------------------------- | ------------------------------------------------------------ |
| `resource-group`                    | The name of the resource to reference; this example being *resource_group* |
| `lower("...")`                      | Terraform function to make everything within the braces to be of lower case |
| `rg`                                | The acronym for the resource to show in Azure; this example being *resource_group* |
| `-`                                 | Separator                                                    |
| `${var.env}`                        | Passing in the environment name variable; such as `DEV`      |
| `-`                                 | Separator                                                    |
| `${var.location-map[var.location]}` | Using the location variable passed in, this will lookup the corresponding acronym to replace it with; `uksouth` will become `uks` |
| `-`                                 | Separator                                                    |
| `${local.subId`}                    | Utilising the local value to grab the last 6 digits of the subscription ID passed in; `subId = substr(var.subId, -6, 6)`. In this instance `84492f96-2bab-4c53-b8ac-78a83154a2a6` will become `54a2a6` |
| **EXAMPLE OUTPUT**                  | `rg-dev-uks-54a2a6`                                          |

## Importing Module via Terraform Git SSH


module "names" {
    source   = "../../../azure-naming-standard"
    env      = var.ARM_ENVIRONMENT
    location = var.ARM_LOCATION
    subId    = var.ARM_SUBSCRIPTION_ID
}

resource "azurerm_resource_group" "test" {
    name     = "${module.names.standard["resource-group"]}-test"
    location = var.ARM_LOCATION
    tags     = var.global_settings.tags
}
```