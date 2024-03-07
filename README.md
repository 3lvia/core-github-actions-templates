# core-github-actions-templates

## Build

Template that build docker image, analyze it using CodeQL, scans for vulnerabilities and uploads to Azure Container Registry.

### Inputs

| Name                  | Type   | Default                  | Description                                                                                                                                |
| --------------------- | ------ | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `name`                | String |                          | Name of application.                                                                                                                       |
| `namespace`           | String |                          | Namespace of application.                                                                                                                  |
| `environment`         | String |                          | Github environment. This environment should contain the variable AZURE_CLIENT_ID, AZURE_TENANT_ID and ACR_SUBSCRIPTION_ID.                 |
| `dockerfile`          | String |                          | Path to Dockerfile.                                                                                                                        |
| `dockerBuildContext`  | String | directory of dockerfile  | Path to Docker build context.                                                                                                              |
| `languages`           | String | `[csharp]`               | List of language to run CodeQL on. The supported languages are c-cpp, csharp, go, java-kotlin, javascript-typescript, python, ruby, swift. |
| `severity`            | String | `CRITICAL,HIGH`          | Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.              |
| `AZURE_CLIENT_ID`     | String | `$AZURE_CLIENT_ID`       | ClientId of a service principal that can push to Container Registry.                                                                       |
| `AZURE_TENANT_ID`     | String | `$AZURE_TENANT_ID`       | TenantId of a service principal that can push to Azure Container Registry.                                                                 |
| `ACR_SUBSCRIPTION_ID` | String | `$ACR_SUBSCRIPTION_ID`   | Subscription ID of the Azure Container Registry to push to.                                                                                |
| `acrName `            | String | `containerregistryelvia` | Name of the Azure Container Registry to push to.                                                                                           |

### Example

```yaml
name: Build

on:
  push:
    branches: [trunk]
  pull_request:
    branches: [trunk]

jobs:
  build:
    permissions:
      actions: read
      contents: read
      id-token: write
      security-events: write
    uses: 3lvia/core-github-actions-templates/.github/workflows/build.yaml@v2
    with:
      name: 'my-cool-app'
      namespace: 'my-system'
      environment: 'dev'
      dockerfile: 'src/Dockerfile'
```

## Deploy

Template that deploys an Elvia Helm chart to Kubernetes

### Inputs

| Name                  | Type   | Default                  | Description                                                                                                                                                      |
| --------------------- | ------ | ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                | String |                          | Name of application.                                                                                                                                             |
| `namespace`           | String |                          | Namespace of application.                                                                                                                                        |
| `environment`         | String |                          | Github environment. This environment should contain the variable AZURE_CLIENT_ID, AZURE_TENANT_ID, AKS_SUBSCRIPTION_ID, AKS_CLUSTER_NAME and AKS_RESOURCE_GROUP. |
| `AZURE_CLIENT_ID`     | String | `$AZURE_CLIENT_ID`       | ClientId of a service principal that can push to Container Registry.                                                                                             |
| `AZURE_TENANT_ID`     | String | `$AZURE_TENANT_ID`       | TenantId of a service principal that can push to Azure Container Registry.                                                                                       |
| `AKS_SUBSCRIPTION_ID` | String | `$AKS_SUBSCRIPTION_ID`   | Subscription ID of the Azure Container Registry to push to.                                                                                                      |
| `AKS_CLUSTER_NAME`    | String | `$AKS_CLUSTER_NAME`      | Name of the AKS cluster                                                                                                                                          |
| `AKS_RESOURCE_GROUP`  | String | `$AKS_RESOURCE_GROUP`    | Resource group of the AKS cluster                                                                                                                                |
| `acrName `            | String | `containerregistryelvia` | Name of the Azure Container Registry to push to.                                                                                                                 |

### Example

```yaml
name: Deploy

on:
  push:
    branches: [trunk]
  pull_request:
    branches: [trunk]

jobs:
  deploy:
    permissions:
      actions: read
      contents: read
    uses: 3lvia/core-github-actions-templates/.github/workflows/deploy.yaml@v2
    with:
      name: 'my-cool-app'
      namespace: 'my-system'
      environment: 'dev'
```

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
