# core-github-actions-templates


## Build and Deploy
To use the build and deploy actions, you must first add your Github repository to https://github.com/3lvia/github-repositories-terraform.

### Example

```yaml
name: Build and Deploy to Kubernetes

on:
  push:
    branches: [trunk]
  pull_request:
    branches: [trunk]
  workflow_dispatch:
    branches:
      - feature/github-action

permissions:
  actions: read
  contents: read
  id-token: write
  security-events: write

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    steps:
      - uses: 3lvia/core-github-actions-templates/analyze@trunk

  build:
    name: Build and Scan
    runs-on: ubuntu-latest
    environment: build
    steps:
      - uses: 3lvia/core-github-actions-templates/build@trunk
        with:
          name: demo-api
          namespace: core
          dockerfile: core-demo-api/Dockerfile
          AZURE_CLIENT_ID: ${{ vars.ACR_CLIENT_ID }}

  deploy_dev:
    name: Deploy
    needs: [build, analyze]
    runs-on: ubuntu-latest
    environment: dev
    steps:
      - uses: 3lvia/core-github-actions-templates/deploy@trunk
        with:
          name: demo-api
          namespace: core
          environment: dev
          AZURE_CLIENT_ID: ${{ vars.AKS_CLIENT_ID }}
```

### Build 

Template that build docker image, analyze it using CodeQL, scans for vulnerabilities and uploads to Azure Container Registry.

### Inputs

| Name                  | Type   | Default                  | Description                                                                                                                                |
| --------------------- | ------ | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `name`                | String |                          | Name of application.                                                                                                                       |
| `namespace`           | String |                          | Namespace of application.                                                                                                                  |
| `dockerfile`          | String |                          | Path to Dockerfile.                                                                                                                        |
| `dockerBuildContext`  | String | directory of dockerfile  | Path to Docker build context.                                                                                                              |
| `languages`           | String | `[csharp]`               | List of language to run CodeQL on. The supported languages are c-cpp, csharp, go, java-kotlin, javascript-typescript, python, ruby, swift. |
| `severity`            | String | `CRITICAL,HIGH`          | Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.              |
| `AZURE_CLIENT_ID`     | String | Elvia default AKS        | ClientId of a service principal that can push to Container Registry.                                                                       |
| `AZURE_TENANT_ID`     | String | Elvia Tenant             | TenantId of a service principal that can push to Azure Container Registry.                                                                 |
| `ACR_SUBSCRIPTION_ID` | String | Elvia default ACR        | Subscription ID of the Azure Container Registry to push to.                                                                                |
| `ACR_NAME`            | String | Elvia default ACR        | Name of the Azure Container Registry to push to.                                                                                           |

### Deploy

Template that deploys an Elvia Helm chart to Kubernetes

### Inputs

| Name                  | Type   | Default                  | Description         
| --------------------- | ------ | ------------------------ | --------------------
| `name`                | String |                          | Name of application.
| `namespace`           | String |                          | Namespace of application.
| `environment`         | String |                          | Environment to deploy to. `dev`, `test` or `prod`.
| `AZURE_CLIENT_ID`     | String | Elvia default AKS        | ClientId of a service principal that can push to Container Registry.
| `AZURE_TENANT_ID`     | String | Elvia Tenant             | TenantId of a service principal that can push to Azure Container Registry.
| `AKS_SUBSCRIPTION_ID` | String | Elvia default AKS        | Subscription ID of the AKS cluster.
| `AKS_CLUSTER_NAME`    | String | Elvia default AKS        | Name of the AKS cluster.
| `AKS_RESOURCE_GROUP`  | String | Elvia default AKS        | Resource group of the AKS cluster.



## Trivy scanning

Uses https://github.com/aquasecurity/trivy-action to scan IaC and report security issues.
The action will report any vulnerabilities to GitHub Advanced Security, which will be visible
in the Security tab on GitHub.

### Inputs

| Name             | Type    | Default                            | Description                                                                                                                   |
| ---------------- | ------- | ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `path`           | String  | `.`                                | Path to IaC to scan.                                                                                                          |
| `skip-dirs`      | String  |                                    | Comma-separated list of directories to skip                                                                                   |
| `severity`       | String  | `CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN` | Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information. |
| `upload-report`  | Boolean | `true`                             | Upload Trivy report to GitHub Security tab.                                                                                   |
| `ignore-unfixed` | Boolean | `false`                            | Ignore unpatched/unfixed vulnerabilities.                                                                                     |

### Example

```yaml
name: Scan Terraform code with Trivy

on:
  push:
    branches: [develop, master]
  pull_request:
    branches: [develop, master]
  schedule:
    - cron: '0 0 * * 0' # every sunday at 00:00

jobs:
  trivy_scan:
    permissions:
      actions: read
      contents: read
      security-events: write
    uses: 3lvia/core-github-actions-templates/.github/workflows/trivy-scan.yaml@v2
    with:
      skip-dirs: 'frontend'
      upload-report: false
```

## Terraform format

Uses built-in formatter for Terraform CLI to check format of Terraform code.

### Inputs

| Name   | Type   | Default | Description      |
| ------ | ------ | ------- | ---------------- |
| `path` | String | `.`     | Path to process. |

### Example

```yaml
name: Check Terraform code formatting

on:
  pull_request:
    branches: [develop]

jobs:
  terraform_format_check:
    permissions:
      contents: read
    uses: 3lvia/core-github-actions-templates/.github/workflows/terraform-format.yaml@v2
```
