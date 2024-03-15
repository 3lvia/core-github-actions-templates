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
  issues: read
  checks: write
  pull-requests: write

jobs:
  unittests:
    name: Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: 3lvia/core-github-actions-templates/unittest@trunk

  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    if: github.ref != 'refs/heads/trunk' # only run analyze on PR
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
    name: Deploy Dev
    needs: [build, unittests]
    # if: github.ref == 'refs/heads/trunk'
    runs-on: ubuntu-latest
    environment: dev
    steps:
      - uses: 3lvia/core-github-actions-templates/deploy@trunk
        with:
          name: demo-api
          namespace: core
          environment: dev
          AZURE_CLIENT_ID: ${{ vars.AKS_CLIENT_ID }}
          helmValuesPath: '.github/deploy/values.yaml'

  deploy_test:
    name: Deploy Test
    needs: [deploy_dev]
    runs-on: ubuntu-latest
    environment: test
    if: github.ref == 'refs/heads/trunk'
    steps:
      - uses: 3lvia/core-github-actions-templates/deploy@trunk
        with:
          name: demo-api
          namespace: core
          environment: test
          AZURE_CLIENT_ID: ${{ vars.AKS_CLIENT_ID }}
          helmValuesPath: '.github/deploy/values.yaml'

  deploy_prod:
    name: Deploy Prod
    needs: [deploy_test]
    runs-on: ubuntu-latest
    environment: prod
    if: github.ref == 'refs/heads/trunk'
    steps:
      - uses: 3lvia/core-github-actions-templates/deploy@trunk
        with:
          name: demo-api
          namespace: core
          environment: prod
          AZURE_CLIENT_ID: ${{ vars.AKS_CLIENT_ID }}
          helmValuesPath: '.github/deploy/values.yaml'
```

### Build

Template that builds Docker image, scans for vulnerabilities and uploads to Azure Container Registry.

### Inputs

| Name                          | Type    | Default                 | Description                                                                                                                                            |
| ----------------------------- | ------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `name`                        | String  |                         | Name of application.                                                                                                                                   |
| `namespace`                   | String  |                         | Namespace of application.                                                                                                                              |
| `dockerfile`                  | String  |                         | Path to Dockerfile.                                                                                                                                    |
| `dockerBuildContext`          | String  | directory of Dockerfile | Path to Docker build context.                                                                                                                          |
| `severity`                    | String  | `CRITICAL,HIGH`         | Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.                          |
| `trivy-cve-ignores`           | String  |                         | Comma-separated list of CVEs for Trivy to ignore. See https://aquasecurity.github.io/trivy/v0.49/docs/configuration/filtering/#trivyignore for syntax. |
| `trivy-enable-secret-scanner` | Boolean | `true`                  | Enable Trivy secret scanner.                                                                                                                           |
| `trivy-skip-dirs`             | String  |                         | Directories/files skipped by Trivy. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.                   |
| `AZURE_CLIENT_ID`             | String  | Elvia default AKS       | ClientId of a service principal that can push to Container Registry.                                                                                   |
| `AZURE_TENANT_ID`             | String  | Elvia Tenant            | TenantId of a service principal that can push to Azure Container Registry.                                                                             |
| `ACR_SUBSCRIPTION_ID`         | String  | Elvia default ACR       | Subscription ID of the Azure Container Registry to push to.                                                                                            |
| `ACR_NAME`                    | String  | Elvia default ACR       | Name of the Azure Container Registry to push to.                                                                                                       |

### Deploy

Template that deploys an Elvia Helm chart to Kubernetes

### Inputs

| Name                  | Type    | Default                      | Description                                                                                                                      |
| --------------------- | ------- | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `name`                | String  |                              | Name of application.                                                                                                             |
| `namespace`           | String  |                              | Namespace of application.                                                                                                        |
| `environment`         | String  |                              | Environment to deploy to. `dev`, `test` or `prod`.                                                                               |
| `helmValuesPath`      | String  | `.github/deploy/values.yaml` | Path to Helm values file, relative to the root of the repository.                                                                |
| `checkout`            | Boolean | `true`                       | If true, the action will check out the repository. If false, the action will assume the repository has already been checked out. |
| `AZURE_CLIENT_ID`     | String  | Elvia default AKS            | ClientId of a service principal that has access to AKS.                                                                          |
| `AZURE_TENANT_ID`     | String  | Elvia Tenant                 | TenantId of a service principal that has access to AKS.                                                                          |
| `AKS_SUBSCRIPTION_ID` | String  | Elvia default AKS            | Subscription ID of the AKS cluster to deploy to.                                                                                 |
| `AKS_CLUSTER_NAME`    | String  | Elvia default AKS            | Name of the AKS cluster to deploy to.                                                                                            |
| `AKS_RESOURCE_GROUP`  | String  | Elvia default AKS            | Resource group of the AKS cluster to deploy to.                                                                                  |

## Trivy IaC scanning

Uses https://github.com/aquasecurity/trivy-action to scan IaC and report security issues.
The action will report any vulnerabilities to GitHub Advanced Security, which will be visible in the Security tab on GitHub.

### Inputs

| Name            | Type    | Default                            | Description                                                                                                                      |
| --------------- | ------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `path`          | String  | `.`                                | Path to IaC to scan.                                                                                                             |
| `skip-dirs`     | String  |                                    | Comma-separated list of directories to skip                                                                                      |
| `severity`      | String  | `CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN` | Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.    |
| `upload-report` | Boolean | `true`                             | Upload Trivy report to GitHub Security tab.                                                                                      |
| `checkout`      | Boolean | `true`                             | If true, the action will check out the repository. If false, the action will assume the repository has already been checked out. |

### Example

```yaml
name: Scan IaC with Trivy
on:
  push:
    branches: [develop, master]
  pull_request:
    branches: [develop, master]
  schedule:
    - cron: '1 2 * * 3' # every Wednesday at 02:01

jobs:
  trivy_scan:
    runs-on: ubuntu-latest
    name: 'Scan IaC with Trivy'
    permissions:
      actions: read
      contents: read
      security-events: write
    steps:
      - uses: 3lvia/core-github-actions-templates/trivy-iac-scan@trunk
        with:
          path: 'terraform'
          skip-dirs: 'terraform/modules'
```

## Terraform format

Uses built-in formatter for Terraform CLI to check format of Terraform code.

### Inputs

| Name       | Type    | Default | Description                                                                                                                      |
| ---------- | ------- | ------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `path`     | String  | `.`     | Path to process.                                                                                                                 |
| `checkout` | Boolean | `true`  | If true, the action will check out the repository. If false, the action will assume the repository has already been checked out. |

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
    steps:
      - uses: 3lvia/core-github-actions-templates/terraform-format@trunk
        with:
          path: 'terraform'
```

# Development

## Yaml format

```bash
yarn global add prettier
prettier --single-quote .github/workflows/* **/action.yml README.md -w
# OR
prettier --single-quote .github/workflows/* **/action.yml README.md -w --end-of-line crlf
```
