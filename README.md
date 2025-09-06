# User Guide for Azure Function App Deployment

**Author**: nvhai248  
**Last Updated**: September 6, 2025

This guide explains how to set up and deploy a Python-based Azure Function App using Terraform and a Makefile.

---

## Prerequisites

- **Azure CLI**: Install from [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- **Terraform**: Install from [Terraform](https://www.terraform.io/downloads).
- **Make**: Install via `choco install make` (Windows) or equivalent.
- **Python**: Version matching your Function App runtime.
- **zip**: For creating ZIP files.

---

## Setup

1. **Install Azure CLI**:

   ```bash
   az --version
   ```

2. **Log in to Azure**:

   ```bash
   az login
   az account set --subscription <subscription-id>
   ```

   Get `<subscription-id>` with:

   ```bash
   az account list --output table
   ```

3. **Set Environment Variable**:
   - **Windows (PowerShell)**:
     ```powershell
     $env:ARM_SUBSCRIPTION_ID = "<subscription-id>"
     ```
   - **Windows (Command Prompt)**:
     ```cmd
     set ARM_SUBSCRIPTION_ID=<subscription-id>
     ```
   - **macOS/Linux**:
     ```bash
     export ARM_SUBSCRIPTION_ID="<subscription-id>"
     ```

---

## Infrastructure Setup with Terraform

1. **Create Terraform Files**:

   - Use provided `main.tf` and `variables.tf` to create:
     - Resource group (`microleaffunc-rg`)
     - Storage account (`microleaffuncsa`)
     - Storage container (`microleaffunccontainer`)
     - App Service Plan, Application Insights, Key Vault, Function App (`microleaffunc`)

2. **Set Up Terraform Backend (Optional)**:
   Create a resource group, storage account, and container for state:

   ```bash
   az group create --name tfstate-rg --location eastus
   az storage account create --name microtfstatestorage --resource-group tfstate-rg --location eastus --sku Standard_LRS --kind StorageV2
   az storage container create --name microtfstate --account-name microtfstatestorage
   ```

3. **Apply Terraform**:
   ```bash
   terraform init
   terraform plan
   terraform apply --auto-approve
   ```

---

## Publish Code to Azure Function

1. **Example structure**:

   ```
   azure-terraform/
   ├── function_app/
   │   ├── func1/
   │   │   ├── __init__.py
   │   │   ├── function.json
   │   │   ├── requirements.txt
   │   ├── func2/
   │   │   ├── __init__.py
   │   │   ├── function.json
   │   │   ├── requirements.txt
   │   ├── func3/
   │   │   ├── __init__.py
   │   │   ├── function.json
   │   │   ├── requirements.txt
   ├── main.tf
   ├── variables.tf
   ├── Makefile
   ```

2. **Prepare Function Code**:
   Create directories (`func1`, `func2`, `func3`) with:

   - `function.json`: Define triggers/bindings.
   - `__init__.py`: Function logic.
   - `requirements.txt`: Python dependencies.

3. **Deploy with Makefile**:
   Run:

   - All functions: `make deploy`
   - Specific functions: `make deploy FUNCTIONS="func1 func2"`
   - Single function: `make deploy-func1`

   This zips function code, uploads to `microleaffunccontainer`, and updates the Function App to use the ZIP via `WEBSITE_RUN_FROM_PACKAGE`.

4. **Verify Deployment**:
   Check app settings:
   ```bash
   az functionapp config appsettings list --name microleaffunc --resource-group microleaffunc-rg
   ```
   Test a function (e.g., HTTP trigger):
   ```bash
   curl https://microleaffunc.azurewebsites.net/api/func1
   ```

---

## Troubleshooting

- **Terraform Errors**: Verify `ARM_SUBSCRIPTION_ID` and resource existence.
- **Makefile Errors**: Ensure `make`, `zip`, and `az` are installed; check Azure CLI login.
- **Function Not Updating**: Confirm `WEBSITE_RUN_FROM_PACKAGE` in app settings.

---

## Cleanup

Delete resources:

```bash
terraform destroy --auto-approve
az storage container delete --name microtfstate --account-name microtfstatestorage
az storage account delete --name microtfstatestorage --resource-group tfstate-rg
az group delete --name tfstate-rg --yes
```

---

For issues or customization, contact nvhai248 or refer to Azure/Terraform documentation.
