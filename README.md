# core-github-actions-templates

<!-- action-docs-header source="build/action.yml" -->

<!-- action-docs-header source="build/action.yml" -->
<!-- action-docs-description source="build/action.yml" -->

## Description

Builds Docker image, scans for vulnerabilities using Trivy and pushes to Azure Container Registry. To use the `Build` and `Deploy` actions, you must first add your Github repository to https://github.com/3lvia/github-repositories-terraform.

<!-- action-docs-description source="build/action.yml" -->

### Example usage in a full workflow

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

<!-- action-docs-inputs source="build/action.yml" -->

## Inputs

| name                          | description                                                                                                                                                   | required | default                                |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------- |
| `name`                        | <p>Name of application. Do not include namespace.</p>                                                                                                         | `true`   | `halloj`                               |
| `namespace`                   | <p>Namespace or system of the application.</p>                                                                                                                | `true`   | `""`                                   |
| `dockerfile`                  | <p>Path to Dockerfile.</p>                                                                                                                                    | `true`   | `""`                                   |
| `dockerBuildContext`          | <p>Docker build context, which is the working directory needed to build the dockerfile. Defaults to the directory of the Dockerfile.</p>                      | `false`  | `""`                                   |
| `severity`                    | <p>Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.</p>                          | `false`  | `CRITICAL,HIGH`                        |
| `trivy-cve-ignores`           | <p>Comma-separated list of CVEs for Trivy to ignore. See https://aquasecurity.github.io/trivy/v0.49/docs/configuration/filtering/#trivyignore for syntax.</p> | `false`  | `""`                                   |
| `trivy-enable-secret-scanner` | <p>Enable Trivy secret scanner.</p>                                                                                                                           | `false`  | `true`                                 |
| `trivy-skip-dirs`             | <p>Directories/files skipped by Trivy. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.</p>                   | `false`  | `""`                                   |
| `AZURE_CLIENT_ID`             | <p>ClientId of a service principal that can push to Container Registry.</p>                                                                                   | `true`   | `""`                                   |
| `AZURE_TENANT_ID`             | <p>TenantId of a service principal that can push to Azure Container Registry. Default to Elvia's Tenant ID.</p>                                               | `false`  | `2186a6ec-c227-4291-9806-d95340bf439d` |
| `ACR_SUBSCRIPTION_ID`         | <p>Subscription ID of the Azure Container Registry to push to. Defaults to subscription ID of Elvia's standard ACR.</p>                                       | `false`  | `9edbf217-b7c1-4f6a-ae76-d046cf932ff0` |
| `ACR_NAME`                    | <p>Name of the Azure Container Registry to push to. Defaults to Elvia's standard ACR.</p>                                                                     | `false`  | `containerregistryelvia`               |

<!-- action-docs-inputs source="build/action.yml" -->
<!-- action-docs-usage source="build/action.yml" project="core-github-actions-templates" version="trunk" -->

## Usage

```yaml
- uses: core-github-actions-templates@trunk
  with:
    name:
    # Name of application. Do not include namespace.
    #
    # Required: true
    # Default: halloj

    namespace:
    # Namespace or system of the application.
    #
    # Required: true
    # Default: ""

    dockerfile:
    # Path to Dockerfile.
    #
    # Required: true
    # Default: ""

    dockerBuildContext:
    # Docker build context, which is the working directory needed to build the dockerfile. Defaults to the directory of the Dockerfile.
    #
    # Required: false
    # Default: ""

    severity:
    # Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.
    #
    # Required: false
    # Default: CRITICAL,HIGH

    trivy-cve-ignores:
    # Comma-separated list of CVEs for Trivy to ignore. See https://aquasecurity.github.io/trivy/v0.49/docs/configuration/filtering/#trivyignore for syntax.
    #
    # Required: false
    # Default: ""

    trivy-enable-secret-scanner:
    # Enable Trivy secret scanner.
    #
    # Required: false
    # Default: true

    trivy-skip-dirs:
    # Directories/files skipped by Trivy. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.
    #
    # Required: false
    # Default: ""

    AZURE_CLIENT_ID:
    # ClientId of a service principal that can push to Container Registry.
    #
    # Required: true
    # Default: ""

    AZURE_TENANT_ID:
    # TenantId of a service principal that can push to Azure Container Registry. Default to Elvia's Tenant ID.
    #
    # Required: false
    # Default: 2186a6ec-c227-4291-9806-d95340bf439d

    ACR_SUBSCRIPTION_ID:
    # Subscription ID of the Azure Container Registry to push to. Defaults to subscription ID of Elvia's standard ACR.
    #
    # Required: false
    # Default: 9edbf217-b7c1-4f6a-ae76-d046cf932ff0

    ACR_NAME:
    # Name of the Azure Container Registry to push to. Defaults to Elvia's standard ACR.
    #
    # Required: false
    # Default: containerregistryelvia
```

<!-- action-docs-usage source="build/action.yml" project="core-github-actions-templates" version="trunk" -->

<!-- action-docs-header source="deploy/action.yml" -->

<!-- action-docs-header source="deploy/action.yml" -->
<!-- action-docs-description source="deploy/action.yml" -->

## Description

Deploys an application to Kubernetes using the Elvia Helm chart. To use the `Build` and `Deploy` actions, you must first add your Github repository to https://github.com/3lvia/github-repositories-terraform.

<!-- action-docs-description source="deploy/action.yml" -->
<!-- action-docs-inputs source="deploy/action.yml" -->

## Inputs

| name                            | description                                                                                                                                 | required | default                                |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------- |
| `name`                          | <p>Name of application. Do not include namespace.</p>                                                                                       | `true`   | `""`                                   |
| `namespace`                     | <p>Namespace or system of the application.</p>                                                                                              | `true`   | `""`                                   |
| `environment`                   | <p>Environment to deploy to.</p>                                                                                                            | `true`   | `""`                                   |
| `helmValuesPath`                | <p>Path to Helm values file, relative to the root of the repository. Defaults to .github/deploy/values.yaml.</p>                            | `false`  | `.github/deploy/values.yaml`           |
| `checkout`                      | <p>If "true", the action will check out the repository. If "false", the action will assume the repository has already been checked out.</p> | `false`  | `true`                                 |
| `runtimeCloudProvider`          | <p>Kubernetes cloud provider to deploy to: 'AKS' or 'GKE'. Defaults to AKS.</p>                                                             | `false`  | `AKS`                                  |
| `AZURE_CLIENT_ID`               | <p>Client ID of a service principal that has access to AKS. Only required for deploying to AKS.</p>                                         | `false`  | `""`                                   |
| `AZURE_TENANT_ID`               | <p>Tenant ID of a service principal that has access to AKS. Default to Elvia's Tenant ID.</p>                                               | `false`  | `2186a6ec-c227-4291-9806-d95340bf439d` |
| `AKS_SUBSCRIPTION_ID`           | <p>Subscription ID of AKS to deploy to. Defaults to Elvias normal clusters.</p>                                                             | `false`  | `""`                                   |
| `AKS_CLUSTER_NAME`              | <p>Name of the AKS cluster to deploy to. Defaults to Elvias normal clusters.</p>                                                            | `false`  | `""`                                   |
| `AKS_RESOURCE_GROUP`            | <p>Resource group of the AKS cluster to deploy to. Defaults to Elvias normal clusters.</p>                                                  | `false`  | `""`                                   |
| `GC_SERVICE_ACCOUNT`            | <p>Service account to use for deploying to GKE. Only required for deploying to GKE.</p>                                                     | `false`  | `""`                                   |
| `GC_WORKLOAD_IDENTITY_PROVIDER` | <p>Workload identity provider to use for deploying to GKE. Only required for deploying to GKE.</p>                                          | `false`  | `""`                                   |
| `GC_PROJECT_ID`                 | <p>Project ID of GKE to deploy to. Defaults to Elvias normal clusters.</p>                                                                  | `false`  | `""`                                   |
| `GC_CLUSTER_NAME`               | <p>Name of the GKE cluster to deploy to. Defaults to Elvias normal clusters.</p>                                                            | `false`  | `""`                                   |
| `GC_CLUSTER_LOCATION`           | <p>Location of the GKE cluster to deploy to. Defaults to locations of Elvias normal clusters.</p>                                           | `false`  | `europe-west1`                         |

<!-- action-docs-inputs source="deploy/action.yml" -->
<!-- action-docs-usage source="deploy/action.yml" project="core-github-actions-templates" version="trunk" -->

## Usage

```yaml
- uses: core-github-actions-templates@trunk
  with:
    name:
    # Name of application. Do not include namespace.
    #
    # Required: true
    # Default: ""

    namespace:
    # Namespace or system of the application.
    #
    # Required: true
    # Default: ""

    environment:
    # Environment to deploy to.
    #
    # Required: true
    # Default: ""

    helmValuesPath:
    # Path to Helm values file, relative to the root of the repository. Defaults to .github/deploy/values.yaml.
    #
    # Required: false
    # Default: .github/deploy/values.yaml

    checkout:
    # If "true", the action will check out the repository. If "false", the action will assume the repository has already been checked out.
    #
    # Required: false
    # Default: true

    runtimeCloudProvider:
    # Kubernetes cloud provider to deploy to: 'AKS' or 'GKE'. Defaults to AKS.
    #
    # Required: false
    # Default: AKS

    AZURE_CLIENT_ID:
    # Client ID of a service principal that has access to AKS. Only required for deploying to AKS.
    #
    # Required: false
    # Default: ""

    AZURE_TENANT_ID:
    # Tenant ID of a service principal that has access to AKS. Default to Elvia's Tenant ID.
    #
    # Required: false
    # Default: 2186a6ec-c227-4291-9806-d95340bf439d

    AKS_SUBSCRIPTION_ID:
    # Subscription ID of AKS to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: false
    # Default: ""

    AKS_CLUSTER_NAME:
    # Name of the AKS cluster to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: false
    # Default: ""

    AKS_RESOURCE_GROUP:
    # Resource group of the AKS cluster to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: false
    # Default: ""

    GC_SERVICE_ACCOUNT:
    # Service account to use for deploying to GKE. Only required for deploying to GKE.
    #
    # Required: false
    # Default: ""

    GC_WORKLOAD_IDENTITY_PROVIDER:
    # Workload identity provider to use for deploying to GKE. Only required for deploying to GKE.
    #
    # Required: false
    # Default: ""

    GC_PROJECT_ID:
    # Project ID of GKE to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: false
    # Default: ""

    GC_CLUSTER_NAME:
    # Name of the GKE cluster to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: false
    # Default: ""

    GC_CLUSTER_LOCATION:
    # Location of the GKE cluster to deploy to. Defaults to locations of Elvias normal clusters.
    #
    # Required: false
    # Default: europe-west1
```

<!-- action-docs-usage source="deploy/action.yml" project="core-github-actions-templates" version="trunk" -->

<!-- action-docs-header source="trivy-iac-scan/action.yml" -->

<!-- action-docs-header source="trivy-iac-scan/action.yml" -->
<!-- action-docs-description source="trivy-iac-scan/action.yml" -->

## Description

Uses https://github.com/aquasecurity/trivy-action to scan IaC and report security issues. The action will report any vulnerabilities to GitHub Advanced Security, which will be visible in the Security tab on GitHub.

<!-- action-docs-description source="trivy-iac-scan/action.yml" -->
<!-- action-docs-inputs source="trivy-iac-scan/action.yml" -->

## Inputs

| name            | description                                                                                                                             | required | default                            |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------- |
| `path`          | <p>Path to the directory containing the IaC files.</p>                                                                                  | `false`  | `.`                                |
| `skip-dirs`     | <p>Comma-separated list of directories to skip.</p>                                                                                     | `false`  | `""`                               |
| `severity`      | <p>Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.</p>    | `false`  | `CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN` |
| `upload-report` | <p>Upload Trivy report to GitHub Security tab. GitHub Advanced Security must be enabled for the repository to use this feature.</p>     | `false`  | `true`                             |
| `checkout`      | <p>If true, the action will check out the repository. If false, the action will assume the repository has already been checked out.</p> | `false`  | `true`                             |

<!-- action-docs-inputs source="trivy-iac-scan/action.yml" -->
<!-- action-docs-usage source="trivy-iac-scan/action.yml" project="core-github-actions-templates" version="trunk" -->

## Usage

```yaml
- uses: core-github-actions-templates@trunk
  with:
    path:
    # Path to the directory containing the IaC files.
    #
    # Required: false
    # Default: .

    skip-dirs:
    # Comma-separated list of directories to skip.
    #
    # Required: false
    # Default: ""

    severity:
    # Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.
    #
    # Required: false
    # Default: CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN

    upload-report:
    # Upload Trivy report to GitHub Security tab. GitHub Advanced Security must be enabled for the repository to use this feature.
    #
    # Required: false
    # Default: true

    checkout:
    # If true, the action will check out the repository. If false, the action will assume the repository has already been checked out.
    #
    # Required: false
    # Default: true
```

<!-- action-docs-usage source="trivy-iac-scan/action.yml" project="core-github-actions-templates" version="trunk" -->

<!-- action-docs-header source="terraform-format/action.yml" -->

<!-- action-docs-header source="terraform-format/action.yml" -->
<!-- action-docs-description source="terraform-format/action.yml" -->

## Description

Uses the built-in formatter from the Terraform CLI to check the format of Terraform code.

<!-- action-docs-description source="terraform-format/action.yml" -->
<!-- action-docs-inputs source="terraform-format/action.yml" -->

## Inputs

| name       | description                                                                                                                             | required | default |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- |
| `path`     | <p>Path to process.</p>                                                                                                                 | `false`  | `.`     |
| `checkout` | <p>If true, the action will check out the repository. If false, the action will assume the repository has already been checked out.</p> | `false`  | `true`  |

<!-- action-docs-inputs source="terraform-format/action.yml" -->
<!-- action-docs-usage source="terraform-format/action.yml" project="core-github-actions-templates" version="trunk" -->

## Usage

```yaml
- uses: core-github-actions-templates@trunk
  with:
    path:
    # Path to process.
    #
    # Required: false
    # Default: .

    checkout:
    # If true, the action will check out the repository. If false, the action will assume the repository has already been checked out.
    #
    # Required: false
    # Default: true
```

<!-- action-docs-usage source="terraform-format/action.yml" project="core-github-actions-templates" version="trunk" -->

# Development

## Setup

Install the dependencies using [yarn](https://yarnpkg.com):

```bash
yarn install
```

## Action documentation

We use [action-docs](https://github.com/npalm/action-docs) to auto-generate the documentation for the actions.
To add documentation for your new action, add these tags to the `README.md` file:

```markdown
<!-- action-docs-header source="my-new-action/action.yml" -->
<!-- action-docs-description source="my-new-action/action.yml" -->
<!-- action-docs-inputs source="my-new-action/action.yml" -->
<!-- action-docs-usage source="my-new-action/action.yml" project="core-github-actions-templates" version="trunk" -->
```

and add the action to the comma-separated list `ACTION_DIRS` in [`.github/workflows/autogenerate-docs.yml`](.github/workflows/autogenerate-docs.yml):

```yaml
name: Generate action documentation for ${{ matrix.action-file }}
runs-on: ubuntu-latest
env:
  ACTION_DIRS: 'build,deploy,trivy-iac-scan,terraform-format,my-new-action' # Add your action here
steps:
```

The documentation will then be autogenerated and commited on push to the `trunk` branch.

### Check autogenerated documentation locally

You can run [action-docs](https://github.com/npalm/action-docs) locally to check the generated documentation:

```bash
yarn gen-docs new-action/action.yaml
cat README.md
```

## Formatting

We use [prettier](https://prettier.io) to format the README and yaml files:

```bash
yarn format
# OR
yarn format --end-of-line crlf
```
