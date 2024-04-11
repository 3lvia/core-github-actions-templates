# core-github-actions-templates

GitHub Actions templates for the Elvia organization.

## Table of Contents

<!-- gh-actions-docs-toc-start -->

- [Actions](#actions)
  - [Build](#build)
    - [Description](#description)
    - [Inputs](#inputs)
    - [Usage](#usage)
    - [Example usage in a full workflow](#example-usage-in-a-full-workflow)
  - [Deploy](#deploy)
    - [Description](#description-1)
    - [Inputs](#inputs-1)
    - [Usage](#usage-1)
  - [Unit Test](#unit-test)
    - [Description](#description-2)
    - [Inputs](#inputs-2)
    - [Usage](#usage-2)
  - [Analyze](#analyze)
    - [Description](#description-3)
    - [Inputs](#inputs-3)
    - [Usage](#usage-3)
  - [Trivy IaC scan](#trivy-iac-scan)
    - [Description](#description-4)
    - [Inputs](#inputs-4)
    - [Usage](#usage-4)
  - [Playwright Test](#playwright-test)
    - [Description](#description-5)
    - [Inputs](#inputs-5)
    - [Usage](#usage-5)
  - [Terraform format check](#terraform-format-check)
    - [Description](#description-6)
    - [Inputs](#inputs-6)
    - [Usage](#usage-6)
- [Development](#development)
  - [Setup](#setup)
  - [Action documentation & table of contents](#action-documentation--table-of-contents)
  - [Formatting](#formatting)
  <!-- gh-actions-docs-toc-end -->

# Actions

<!-- gh-actions-docs-start path=build/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=contents:read,id-token:write -->

## Build

### Description

Builds Docker image, scans for vulnerabilities using Trivy and pushes to Azure Container Registry. To use the `Build` and `Deploy` actions, you must first add your Github repository to https://github.com/3lvia/github-repositories-terraform.

### Inputs

| Name                          | Description                                                                                                                                            | Required | Default                                |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | -------------------------------------- |
| `ACR_NAME`                    | Name of the Azure Container Registry to push to.                                                                                                       | no       | `containerregistryelvia`               |
| `ACR_SUBSCRIPTION_ID`         | Subscription ID of the Azure Container Registry to push to.                                                                                            | no       | `9edbf217-b7c1-4f6a-ae76-d046cf932ff0` |
| `AZURE_CLIENT_ID`             | ClientId of a service principal that can push to Container Registry.                                                                                   | yes      |                                        |
| `AZURE_TENANT_ID`             | TenantId of a service principal that can push to Azure Container Registry.                                                                             | no       | `2186a6ec-c227-4291-9806-d95340bf439d` |
| `checkout`                    | If "true", the action will check out the repository. If "false", the action will assume the repository has already been checked out.                   | no       | `true`                                 |
| `dockerBuildContext`          | Docker build context, which is the working directory needed to build the dockerfile. Defaults to the directory of the Dockerfile.                      | no       |                                        |
| `dockerfile`                  | Path to Dockerfile.                                                                                                                                    | yes      |                                        |
| `name`                        | Name of application. Do not include namespace.                                                                                                         | yes      |                                        |
| `namespace`                   | Namespace or system of the application.                                                                                                                | yes      |                                        |
| `severity`                    | Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.                          | no       | `CRITICAL,HIGH`                        |
| `trivy-cve-ignores`           | Comma-separated list of CVEs for Trivy to ignore. See https://aquasecurity.github.io/trivy/v0.49/docs/configuration/filtering/#trivyignore for syntax. | no       |                                        |
| `trivy-enable-secret-scanner` | Enable Trivy secret scanner.                                                                                                                           | no       | `true`                                 |
| `trivy-skip-dirs`             | Directories/files skipped by Trivy. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.                   | no       |                                        |

### Usage

```yaml
- name: Build
  uses: 3lvia/core-github-actions-templates/build@trunk
  with:
    ACR_NAME:
    # Name of the Azure Container Registry to push to.
    #
    # Required: no
    # Default: 'containerregistryelvia'

    ACR_SUBSCRIPTION_ID:
    # Subscription ID of the Azure Container Registry to push to.
    #
    # Required: no
    # Default: '9edbf217-b7c1-4f6a-ae76-d046cf932ff0'

    AZURE_CLIENT_ID:
    # ClientId of a service principal that can push to Container Registry.
    #
    # Required: yes

    AZURE_TENANT_ID:
    # TenantId of a service principal that can push to Azure Container Registry.
    #
    # Required: no
    # Default: '2186a6ec-c227-4291-9806-d95340bf439d'

    checkout:
    # If "true", the action will check out the repository. If "false", the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    dockerBuildContext:
    # Docker build context, which is the working directory needed to build the dockerfile. Defaults to the directory of the Dockerfile.
    #
    # Required: no

    dockerfile:
    # Path to Dockerfile.
    #
    # Required: yes

    name:
    # Name of application. Do not include namespace.
    #
    # Required: yes

    namespace:
    # Namespace or system of the application.
    #
    # Required: yes

    severity:
    # Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.
    #
    # Required: no
    # Default: 'CRITICAL,HIGH'

    trivy-cve-ignores:
    # Comma-separated list of CVEs for Trivy to ignore. See https://aquasecurity.github.io/trivy/v0.49/docs/configuration/filtering/#trivyignore for syntax.
    #
    # Required: no

    trivy-enable-secret-scanner:
    # Enable Trivy secret scanner.
    #
    # Required: no
    # Default: 'true'

    trivy-skip-dirs:
    # Directories/files skipped by Trivy. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.
    #
    # Required: no
```

<!-- gh-actions-docs-end -->

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

<!-- gh-actions-docs-start path=deploy/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=contents:read,id-token:write -->

## Deploy

### Description

Deploys an application to Kubernetes using the Elvia Helm chart. To use the `Build` and `Deploy` actions, you must first add your Github repository to https://github.com/3lvia/github-repositories-terraform.

### Inputs

| Name                            | Description                                                                                                                          | Required | Default                                |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | -------------------------------------- |
| `AKS_CLUSTER_NAME`              | Name of the AKS cluster to deploy to. Defaults to Elvias normal clusters.                                                            | no       |                                        |
| `AKS_RESOURCE_GROUP`            | Resource group of the AKS cluster to deploy to. Defaults to Elvias normal clusters.                                                  | no       |                                        |
| `AKS_SUBSCRIPTION_ID`           | Subscription ID of AKS to deploy to. Defaults to Elvias normal clusters.                                                             | no       |                                        |
| `AZURE_CLIENT_ID`               | Client ID of a service principal that has access to AKS. Only required for deploying to AKS.                                         | no       |                                        |
| `AZURE_TENANT_ID`               | Tenant ID of a service principal that has access to AKS.                                                                             | no       | `2186a6ec-c227-4291-9806-d95340bf439d` |
| `GC_CLUSTER_LOCATION`           | Location of the GKE cluster to deploy to.                                                                                            | no       | `europe-west1`                         |
| `GC_CLUSTER_NAME`               | Name of the GKE cluster to deploy to. Defaults to Elvias normal clusters.                                                            | no       |                                        |
| `GC_PROJECT_ID`                 | Project ID of GKE to deploy to. Defaults to Elvias normal clusters.                                                                  | no       |                                        |
| `GC_SERVICE_ACCOUNT`            | Service account to use for deploying to GKE. Only required for deploying to GKE.                                                     | no       |                                        |
| `GC_WORKLOAD_IDENTITY_PROVIDER` | Workload identity provider to use for deploying to GKE. Only required for deploying to GKE.                                          | no       |                                        |
| `checkout`                      | If "true", the action will check out the repository. If "false", the action will assume the repository has already been checked out. | no       | `true`                                 |
| `environment`                   | Environment to deploy to.                                                                                                            | yes      |                                        |
| `helmValuesPath`                | Path to Helm values file, relative to the root of the repository. Defaults to .github/deploy/values.yaml.                            | no       | `.github/deploy/values.yaml`           |
| `name`                          | Name of application. Do not include namespace.                                                                                       | yes      |                                        |
| `namespace`                     | Namespace or system of the application.                                                                                              | yes      |                                        |
| `runtimeCloudProvider`          | Kubernetes cloud provider to deploy to: 'AKS' or 'GKE'.                                                                              | no       | `AKS`                                  |

### Usage

```yaml
- name: Deploy
  uses: 3lvia/core-github-actions-templates/deploy@trunk
  with:
    AKS_CLUSTER_NAME:
    # Name of the AKS cluster to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: no

    AKS_RESOURCE_GROUP:
    # Resource group of the AKS cluster to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: no

    AKS_SUBSCRIPTION_ID:
    # Subscription ID of AKS to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: no

    AZURE_CLIENT_ID:
    # Client ID of a service principal that has access to AKS. Only required for deploying to AKS.
    #
    # Required: no

    AZURE_TENANT_ID:
    # Tenant ID of a service principal that has access to AKS.
    #
    # Required: no
    # Default: '2186a6ec-c227-4291-9806-d95340bf439d'

    GC_CLUSTER_LOCATION:
    # Location of the GKE cluster to deploy to.
    #
    # Required: no
    # Default: 'europe-west1'

    GC_CLUSTER_NAME:
    # Name of the GKE cluster to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: no

    GC_PROJECT_ID:
    # Project ID of GKE to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: no

    GC_SERVICE_ACCOUNT:
    # Service account to use for deploying to GKE. Only required for deploying to GKE.
    #
    # Required: no

    GC_WORKLOAD_IDENTITY_PROVIDER:
    # Workload identity provider to use for deploying to GKE. Only required for deploying to GKE.
    #
    # Required: no

    checkout:
    # If "true", the action will check out the repository. If "false", the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    environment:
    # Environment to deploy to.
    #
    # Required: yes

    helmValuesPath:
    # Path to Helm values file, relative to the root of the repository. Defaults to .github/deploy/values.yaml.
    #
    # Required: no
    # Default: '.github/deploy/values.yaml'

    name:
    # Name of application. Do not include namespace.
    #
    # Required: yes

    namespace:
    # Namespace or system of the application.
    #
    # Required: yes

    runtimeCloudProvider:
    # Kubernetes cloud provider to deploy to: 'AKS' or 'GKE'.
    #
    # Required: no
    # Default: 'AKS'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=unittest/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=checks:write,contents:read,issues:read,pull-requests:write -->

## Unit Test

### Description

Run dotnet unit tests. Required permissions: `checks: write`, `contents: read`, `issues: read`, and `pull-requests: write`.

### Inputs

| Name       | Description                                                                                                                          | Required | Default |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------- |
| `checkout` | If "true", the action will check out the repository. If "false", the action will assume the repository has already been checked out. | no       | `true`  |

### Usage

```yaml
- name: Unit Test
  uses: 3lvia/core-github-actions-templates/unittest@trunk
  with:
    checkout:
    # If "true", the action will check out the repository. If "false", the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=analyze/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=actions:read,contents:read,security-events:write -->

## Analyze

### Description

Run CodeQL analysis.

### Inputs

| Name                | Description                                                                                                                          | Required | Default |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------- |
| `checkout`          | If "true", the action will check out the repository. If "false", the action will assume the repository has already been checked out. | no       | `true`  |
| `working-directory` | Will run CodeQL Analysis on projects under this working directory                                                                    | no       | `./`    |

### Usage

```yaml
- name: Analyze
  uses: 3lvia/core-github-actions-templates/analyze@trunk
  with:
    checkout:
    # If "true", the action will check out the repository. If "false", the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    working-directory:
    # Will run CodeQL Analysis on projects under this working directory
    #
    # Required: no
    # Default: './'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=trivy-iac-scan/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=actions:read,contents:read,security-events:write -->

## Trivy IaC scan

### Description

Uses https://github.com/aquasecurity/trivy-action to scan IaC and report security issues. The action will report any vulnerabilities to GitHub Advanced Security, which will be visible in the Security tab on GitHub.

### Inputs

| Name            | Description                                                                                                                      | Required | Default                            |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------- |
| `checkout`      | If true, the action will check out the repository. If false, the action will assume the repository has already been checked out. | no       | `true`                             |
| `path`          | Path to the directory containing the IaC files.                                                                                  | no       | `.`                                |
| `severity`      | Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.    | no       | `CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN` |
| `skip-dirs`     | Comma-separated list of directories to skip.                                                                                     | no       |                                    |
| `upload-report` | Upload Trivy report to GitHub Security tab. GitHub Advanced Security must be enabled for the repository to use this feature.     | no       | `true`                             |

### Usage

```yaml
- name: Trivy IaC scan
  uses: 3lvia/core-github-actions-templates/trivy-iac-scan@trunk
  with:
    checkout:
    # If true, the action will check out the repository. If false, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    path:
    # Path to the directory containing the IaC files.
    #
    # Required: no
    # Default: '.'

    severity:
    # Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information.
    #
    # Required: no
    # Default: 'CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN'

    skip-dirs:
    # Comma-separated list of directories to skip.
    #
    # Required: no

    upload-report:
    # Upload Trivy report to GitHub Security tab. GitHub Advanced Security must be enabled for the repository to use this feature.
    #
    # Required: no
    # Default: 'true'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=playwright/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=checks:write,contents:read,id-token:write,issues:read,pull-requests:write -->

## Playwright Test

### Description

Run Playwright tests written in dotnet. Required permissions: `checks: write`, `contents: read`, `id-token: write`, `issues: read`, and `pull-requests: write`.

### Inputs

| Name          | Description                                           | Required | Default |
| ------------- | ----------------------------------------------------- | -------- | ------- |
| `environment` | Environment is used to find correct vault instance.   | yes      |         |
| `system`      | System is used to log in to Vault using correct role. | yes      |         |
| `testproject` | Name of test project file to run                      | yes      |         |

### Usage

```yaml
- name: Playwright Test
  uses: 3lvia/core-github-actions-templates/playwright@trunk
  with:
    environment:
    # Environment is used to find correct vault instance.
    #
    # Required: yes

    system:
    # System is used to log in to Vault using correct role.
    #
    # Required: yes

    testproject:
    # Name of test project file to run
    #
    # Required: yes
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=terraform-format/action.yml owner=3lvia project=core-github-actions-templates version=trunk -->

## Terraform format check

### Description

Uses the built-in formatter from the Terraform CLI to check the format of Terraform code.

### Inputs

| Name       | Description                                                                                                                      | Required | Default |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- |
| `checkout` | If true, the action will check out the repository. If false, the action will assume the repository has already been checked out. | no       | `true`  |
| `path`     | Path to process.                                                                                                                 | no       | `.`     |

### Usage

```yaml
- name: Terraform format check
  uses: 3lvia/core-github-actions-templates/terraform-format@trunk
  with:
    checkout:
    # If true, the action will check out the repository. If false, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    path:
    # Path to process.
    #
    # Required: no
    # Default: '.'
```

<!-- gh-actions-docs-end -->

# Development

## Setup

Install the dependencies using [yarn](https://yarnpkg.com):

```bash
yarn install
```

## Action documentation & table of contents

Documentation is auto-generated for any actions in the repository.
The table of contents is also auto-generated, using the headers in this README.
To add documentation for a new action, add these two tags to the `README.md` file:

```markdown
<!-- gh-actions-docs-start path=my-new-action/action.yml owner=3lvia project=core-github-actions-templates version=trunk -->
<!-- gh-actions-docs-end -->
```

Replace `path` with the path to the action yaml file from the root of the repository.
The fields `owner`, `project` and `version` are optional, but should be set to `3lvia`, `core-github-actions-templates` and `trunk` respectively.

The documentation will then be auto-generated, added to the table of contents and commited on push to the `trunk` branch.

## Formatting

We use [prettier](https://prettier.io) to format the README and yaml files:

```bash
yarn format
#OR
yarn format --end-of-line crlf
```
