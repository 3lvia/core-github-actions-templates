# core-github-actions-templates

GitHub Actions composite actions for the Elvia organization.

These actions are mainly intended for internal use at Elvia, but are open-source and can be used by anyone!
They encapsulate common tasks that we perform using GitHub Actions, such as building and deploying applications, running tests, and scanning for vulnerabilities.

Note that some actions are specifically tailored to our infrastructure and will not work outside our organization,
see [here](#elvia-specific-actions) for more information.

## Table of Contents

<!-- gh-actions-docs-toc-start -->

- [Examples](#examples)
- [Elvia runners](#elvia-runners)
- [Actions Documentation](#actions-documentation)
  - [Build](#build)
    - [Inputs](#inputs)
    - [Permissions](#permissions)
    - [Usage](#usage)
  - [Deploy](#deploy)
    - [Inputs](#inputs-1)
    - [Permissions](#permissions-1)
    - [Usage](#usage-1)
  - [Unit Test](#unit-test)
    - [Inputs](#inputs-2)
    - [Permissions](#permissions-2)
    - [Usage](#usage-2)
  - [Integration Test](#integration-test)
    - [Inputs](#inputs-3)
    - [Permissions](#permissions-3)
    - [Usage](#usage-3)
  - [Analyze](#analyze)
    - [Inputs](#inputs-4)
    - [Permissions](#permissions-4)
    - [Usage](#usage-4)
  - [SonarCloud](#sonarcloud)
    - [Inputs](#inputs-5)
    - [Permissions](#permissions-5)
    - [Usage](#usage-5)
  - [Trivy IaC scan](#trivy-iac-scan)
    - [Inputs](#inputs-6)
    - [Permissions](#permissions-6)
    - [Usage](#usage-6)
  - [Playwright Test](#playwright-test)
    - [Inputs](#inputs-7)
    - [Permissions](#permissions-7)
    - [Usage](#usage-7)
  - [Validate Metrics](#validate-metrics)
    - [Inputs](#inputs-8)
    - [Permissions](#permissions-8)
    - [Usage](#usage-8)
  - [Slack Message](#slack-message)
    - [Inputs](#inputs-9)
    - [Permissions](#permissions-9)
    - [Usage](#usage-9)
  - [Elvia-specific actions](#elvia-specific-actions)
- [Development](#development)
  - [Formatting](#formatting)
  - [Action documentation & table of contents](#action-documentation--table-of-contents)
  <!-- gh-actions-docs-toc-end -->

## Examples

The files beginning with `example-` in the folder [.github/workflows](.github/workflows) are working examples of how to use these actions.
Both of these examples require you to have added your system/application to the list in the [github-repositories-terraform](http://github.com/3lvia/github-repositories-terraform) repository.
This is needed for the `Build` and `Deploy` actions to work correctly.

You can also click on the **'Actions'** tab on your repository and click **'New workflow'** to get a selection of Elvia templates.
Some values in these templates are placeholders and need to be replaced with your own values; anything resembling `<your xxx here>` should be replaced.
See the [GitHub docs](https://docs.github.com/en/actions/learn-github-actions/using-starter-workflows#choosing-and-using-a-starter-workflow) for more detailed information.

## Elvia runners

We **strongly recommend** using Elvia's self-hosted GitHub Actions runners for all actions.
Several of our actions use optimizations only available on Elvia runners, and will run slower on GitHub-hosted runners.
To use the Elvia runners, simply replace `runs-on: ubuntu-latest` with `runs-on: elvia-runner` in your workflow file.

See [core-github-actions-runner](https://github.com/3lvia/core-github-actions-runner) for more information about the Elvia runners.

# Actions Documentation

<!-- gh-actions-docs-start path=build/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=contents:read,id-token:write -->

## Build

Builds a Docker image, scans for vulnerabilities using Trivy and pushes to either Azure Container Registry or GitHub Container Registry.
To use the `Build` and `Deploy` actions with Elvias container registry and runtime services,
you must first add your GitHub repository to [github-repositories-terraform](https://github.com/3lvia/github-repositories-terraform).

### Inputs

| Name                          | Description                                                                                                                                                                                                                                                                                                                                                    | Required | Default                                |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------- |
| `ACR_NAME`                    | Name of the Azure Container Registry to push to.                                                                                                                                                                                                                                                                                                               | no       | `containerregistryelvia`               |
| `ACR_SUBSCRIPTION_ID`         | Subscription ID of the Azure Container Registry to push to.                                                                                                                                                                                                                                                                                                    | no       | `9edbf217-b7c1-4f6a-ae76-d046cf932ff0` |
| `AZURE_CLIENT_ID`             | ClientId of a service principal that can push to Azure Container Registry.                                                                                                                                                                                                                                                                                     | no       |                                        |
| `AZURE_TENANT_ID`             | TenantId of a service principal that can push to Azure Container Registry.                                                                                                                                                                                                                                                                                     | no       | `2186a6ec-c227-4291-9806-d95340bf439d` |
| `checkout`                    | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.                                                                                                                                                                                                                           | no       | `true`                                 |
| `csproj-file`                 | :warning: **DEPRECATED**: _Please use `project-file` instead, which is a drop-in replacement. `csproj-file` will be removed in the future._ :warning:<br><br>Path to a csproj-file, e.g. `src/my-app/my-app.csproj`.                                                                                                                                           | no       |                                        |
| `disable-trivy`               | :warning: **DEPRECATED**: _This input is deprecated and will be removed in the future._ :warning:<br><br>If `true`, the action will not run Trivy. **THIS IS NOT RECOMMENDED.**                                                                                                                                                                                | no       | `false`                                |
| `docker-additional-tags`      | Comma-separated list of additional tags to add to the image.                                                                                                                                                                                                                                                                                                   | no       |                                        |
| `docker-build-context`        | Docker build context, which is the working directory needed to build the Docker image. This is relative to the root of the repository. Defaults to the directory of `project-file`.                                                                                                                                                                            | no       |                                        |
| `docker-cache-tag`            | Tag used for getting build cache from registry. This tag is also pushed on every build, together with `github.sha-github.run_number`. This action will not push a `latest` tag; if you want a `latest` tag, you can use this input or `docker-additional-tags`.                                                                                                | no       | `latest-cache`                         |
| `docker-include-dirs`         | Comma-separated list of directories to copy into the Docker image.                                                                                                                                                                                                                                                                                             | no       |                                        |
| `docker-include-files`        | Comma-separated list of files to copy into the Docker image.                                                                                                                                                                                                                                                                                                   | no       |                                        |
| `dockerfile`                  | :warning: **DEPRECATED**: _Please use `project-file` instead, which is a drop-in replacement. `dockerfile` will be removed in the future._ :warning:<br><br>Path to a Dockerfile, e.g. `src/Dockerfile`.                                                                                                                                                       | no       |                                        |
| `ghcr-omit-repository-name`   | If `true`, the action will not include the repository name in the image name. **This is only supported when using `ghcr` as `registry`.**                                                                                                                                                                                                                      | no       | `false`                                |
| `github-token`                | GitHub token for GitHub Container Registry. **Required if `registry` is set to `ghcr`**. Should normally be `secrets.GITHUB_TOKEN`.                                                                                                                                                                                                                            | no       |                                        |
| `name`                        | Name of application. This will be used as the image name. For Elvia applications, do not include the namespace.                                                                                                                                                                                                                                                | yes      |                                        |
| `namespace`                   | Namespace or system of the application. This is only relevant for Elvia applications.                                                                                                                                                                                                                                                                          | no       |                                        |
| `project-file`                | Path to a `.csproj`-file for .NET, a `go.mod` file for Go or a Dockerfile for any other project. E.g. `applications/my-app/my-app.csproj`, `pkg/my-app/go.mod` or `src/Dockerfile`. If you require files outside the directory of the `project-file` to build your application, you will need to set `docker-build-context`.                                   | no       |                                        |
| `registry`                    | What container registry to use, either `acr` or `ghcr`. If set to `acr`, credentials for Azure Container Registry will default to Elvia values. You can also set these explictly to point to your own ACR. If set to `ghcr`, the action will use the GitHub Container Registry. This requires `github-token` to be set, and the `packages: write` permission.' | no       | `acr`                                  |
| `severity`                    | Severity levels to scan for. See [Trivy documentation](https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs) for more information.                                                                                                                                                                                                           | no       | `CRITICAL`                             |
| `trivy-cve-ignores`           | Comma-separated list of CVEs for Trivy to ignore. See [Trivy documentation](https://aquasecurity.github.io/trivy/v0.49/docs/configuration/filtering/#trivyignore) for syntax.                                                                                                                                                                                  | no       |                                        |
| `trivy-enable-secret-scanner` | Enable Trivy secret scanner.                                                                                                                                                                                                                                                                                                                                   | no       | `true`                                 |
| `trivy-skip-dirs`             | Directories/files skipped by Trivy.                                                                                                                                                                                                                                                                                                                            | no       |                                        |

### Permissions

This action requires the following [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `contents: read`
- `id-token: write`

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
    # ClientId of a service principal that can push to Azure Container Registry.
    #
    # Required: no

    AZURE_TENANT_ID:
    # TenantId of a service principal that can push to Azure Container Registry.
    #
    # Required: no
    # Default: '2186a6ec-c227-4291-9806-d95340bf439d'

    checkout:
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    docker-additional-tags:
    # Comma-separated list of additional tags to add to the image.
    #
    # Required: no

    docker-build-context:
    # Docker build context, which is the working directory needed to build the Docker image. This is relative to the root of the repository. Defaults to the directory of `project-file`.
    #
    # Required: no

    docker-cache-tag:
    # Tag used for getting build cache from registry. This tag is also pushed on every build, together with `github.sha-github.run_number`. This action will not push a `latest` tag; if you want a `latest` tag, you can use this input or `docker-additional-tags`.
    #
    # Default: 'latest-cache'

    docker-include-dirs:
    # Comma-separated list of directories to copy into the Docker image.
    #
    # Required: no

    docker-include-files:
    # Comma-separated list of files to copy into the Docker image.
    #
    # Required: no

    ghcr-omit-repository-name:
    # If `true`, the action will not include the repository name in the image name. **This is only supported when using `ghcr` as `registry`.**
    #
    # Required: no
    # Default: 'false'

    github-token:
    # GitHub token for GitHub Container Registry. **Required if `registry` is set to `ghcr`**. Should normally be `secrets.GITHUB_TOKEN`.
    #
    # Required: no

    name:
    # Name of application. This will be used as the image name. For Elvia applications, do not include the namespace.
    #
    # Required: yes

    namespace:
    # Namespace or system of the application. This is only relevant for Elvia applications.
    #
    # Required: no

    project-file:
    # Path to a `.csproj`-file for .NET, a `go.mod` file for Go or a Dockerfile for any other project. E.g. `applications/my-app/my-app.csproj`, `pkg/my-app/go.mod` or `src/Dockerfile`. If you require files outside the directory of the `project-file` to build your application, you will need to set `docker-build-context`.
    #
    # Required: no

    registry:
    # What container registry to use, either `acr` or `ghcr`. If set to `acr`, credentials for Azure Container Registry will default to Elvia values. You can also set these explictly to point to your own ACR. If set to `ghcr`, the action will use the GitHub Container Registry. This requires `github-token` to be set, and the `packages: write` permission.'
    #
    # Required: no
    # Default: 'acr'

    severity:
    # Severity levels to scan for. See [Trivy documentation](https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs) for more information.
    #
    # Required: no
    # Default: 'CRITICAL'

    trivy-cve-ignores:
    # Comma-separated list of CVEs for Trivy to ignore. See [Trivy documentation](https://aquasecurity.github.io/trivy/v0.49/docs/configuration/filtering/#trivyignore) for syntax.
    #
    # Required: no

    trivy-enable-secret-scanner:
    # Enable Trivy secret scanner.
    #
    # Required: no
    # Default: 'true'

    trivy-skip-dirs:
    # Directories/files skipped by Trivy.
    #
    # Required: no
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=deploy/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=contents:read,id-token:write -->

## Deploy

Deploys an application to Kubernetes using the Elvia Helm chart.
To use the `Build` and `Deploy` actions with Elvias container registry and runtime services,
you must first add your Github repository to [github-repositories-terraform](https://github.com/3lvia/github-repositories-terraform).

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
| `checkout`                      | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out. | no       | `true`                                 |
| `environment`                   | Environment to deploy to.                                                                                                            | yes      |                                        |
| `helm-values-path`              | Path to Helm values file, relative to the root of the repository.                                                                    | no       | `.github/deploy/values.yaml`           |
| `name`                          | Name of application. Do not include namespace.                                                                                       | yes      |                                        |
| `namespace`                     | Namespace or system of the application.                                                                                              | yes      |                                        |
| `runtime-cloud-provider`        | Kubernetes cloud provider to deploy to: `AKS` or `GKE`.                                                                              | no       | `AKS`                                  |
| `slack-channel`                 | Slack channel to notify on failure. Leave empty to disable notifications.                                                            | no       | ``                                     |
| `workload-type`                 | The type of workload to deploy to kubernetes. Must be `deployment` or `statefulset`.                                                 | no       | `deployment`                           |

### Permissions

This action requires the following [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `contents: read`
- `id-token: write`

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
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    environment:
    # Environment to deploy to.
    #
    # Required: yes

    helm-values-path:
    # Path to Helm values file, relative to the root of the repository.
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

    runtime-cloud-provider:
    # Kubernetes cloud provider to deploy to: `AKS` or `GKE`.
    #
    # Required: no
    # Default: 'AKS'

    slack-channel:
    # Slack channel to notify on failure. Leave empty to disable notifications.
    #
    # Required: no
    # Default: ''

    workload-type:
    # The type of workload to deploy to kubernetes. Must be `deployment` or `statefulset`.
    #
    # Required: no
    # Default: 'deployment'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=unittest/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=checks:write,contents:read,issues:read,pull-requests:write -->

## Unit Test

Run .NET unit tests.

### Inputs

| Name                | Description                                                                                                                          | Required | Default            |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------------------ |
| `checkout`          | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out. | no       | `true`             |
| `test-coverage`     | If test coverage should be computed. Requires that all test projects include the Nuget package coverlet.collector.                   | no       | `false`            |
| `test-projects`     | Pattern to use to find test projects.                                                                                                | no       | `unit*test*csproj` |
| `working-directory` | Will run unit tests on projects under this working directory.                                                                        | no       | `./`               |

### Permissions

This action requires the following [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `checks: write`
- `contents: read`
- `issues: read`
- `pull-requests: write`

### Usage

```yaml
- name: Unit Test
  uses: 3lvia/core-github-actions-templates/unittest@trunk
  with:
    checkout:
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    test-coverage:
    # If test coverage should be computed. Requires that all test projects include the Nuget package coverlet.collector.
    #
    # Required: no
    # Default: 'false'

    test-projects:
    # Pattern to use to find test projects.
    #
    # Required: no
    # Default: 'unit*test*csproj'

    working-directory:
    # Will run unit tests on projects under this working directory.
    #
    # Required: no
    # Default: './'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=integrationtest/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=checks:write,contents:read,id-token:write,issues:read,pull-requests:write -->

## Integration Test

Run .NET integration tests.

### Inputs

| Name                | Description                                                                                                                          | Required | Default                   |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------------------------- |
| `checkout`          | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out. | no       | `true`                    |
| `environment`       | Environment is used to find correct Vault instance.                                                                                  | yes      | `dev`                     |
| `slack-channel`     | Slack channel to notify on failure. Leave empty to disable notifications                                                             | no       | ``                        |
| `system`            | System is used to log in to Vault using correct role.                                                                                | yes      |                           |
| `test-projects`     | Pattern to use to find test projects.                                                                                                | no       | `integration*test*csproj` |
| `working-directory` | Will run integration tests on projects under this working directory.                                                                 | no       | `./`                      |

### Permissions

This action requires the following [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `checks: write`
- `contents: read`
- `id-token: write`
- `issues: read`
- `pull-requests: write`

### Usage

```yaml
- name: Integration Test
  uses: 3lvia/core-github-actions-templates/integrationtest@trunk
  with:
    checkout:
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    environment:
    # Environment is used to find correct Vault instance.
    #
    # Required: yes
    # Default: 'dev'

    slack-channel:
    # Slack channel to notify on failure. Leave empty to disable notifications
    #
    # Required: no
    # Default: ''

    system:
    # System is used to log in to Vault using correct role.
    #
    # Required: yes

    test-projects:
    # Pattern to use to find test projects.
    #
    # Required: no
    # Default: 'integration*test*csproj'

    working-directory:
    # Will run integration tests on projects under this working directory.
    #
    # Required: no
    # Default: './'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=analyze/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=actions:read,contents:read,security-events:write -->

## Analyze

Run CodeQL analysis.

### Inputs

| Name                | Description                                                                                                                          | Required | Default  |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | -------- |
| `checkout`          | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out. | no       | `true`   |
| `language`          | Languages to run CodeQL analyze on.                                                                                                  | no       | `csharp` |
| `working-directory` | Will run CodeQL Analysis on projects under this working directory.                                                                   | no       | `./`     |

### Permissions

This action requires the following [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `actions: read`
- `contents: read`
- `security-events: write`

### Usage

```yaml
- name: Analyze
  uses: 3lvia/core-github-actions-templates/analyze@trunk
  with:
    checkout:
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    language:
    # Languages to run CodeQL analyze on.
    #
    # Required: no
    # Default: 'csharp'

    working-directory:
    # Will run CodeQL Analysis on projects under this working directory.
    #
    # Required: no
    # Default: './'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=sonarcloud/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=checks:write,contents:read,id-token:write,issues:read,pull-requests:write -->

## SonarCloud

Run SonarCloud scanning on .NET code.

### Inputs

| Name                     | Description                                                                                                                          | Required | Default             |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------------------- |
| `checkout`               | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out. | no       | `true`              |
| `github-token`           | Should normally be `secrets.GITHUB_TOKEN`.                                                                                           | yes      |                     |
| `sonarcloud-project-key` | The SonarCloud project key or id. Normally on the form `3lvia_repo-name`. The project must be manually created on sonarcloud.io.     | yes      |                     |
| `sonarcloud-token`       | Should normally be `secrets.SONAR_TOKEN`.                                                                                            | yes      |                     |
| `test-projects`          | Pattern to use to find test projects.                                                                                                | no       | `*unit*test*csproj` |
| `working-directory`      | Will run SonarCloud on projects under this working directory.                                                                        | no       | `./`                |

### Permissions

This action requires the following [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `checks: write`
- `contents: read`
- `id-token: write`
- `issues: read`
- `pull-requests: write`

### Usage

```yaml
- name: SonarCloud
  uses: 3lvia/core-github-actions-templates/sonarcloud@trunk
  with:
    checkout:
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    github-token:
    # Should normally be `secrets.GITHUB_TOKEN`.
    #
    # Required: yes

    sonarcloud-project-key:
    # The SonarCloud project key or id. Normally on the form `3lvia_repo-name`. The project must be manually created on sonarcloud.io.
    #
    # Required: yes

    sonarcloud-token:
    # Should normally be `secrets.SONAR_TOKEN`.
    #
    # Required: yes

    test-projects:
    # Pattern to use to find test projects.
    #
    # Required: no
    # Default: '*unit*test*csproj'

    working-directory:
    # Will run SonarCloud on projects under this working directory.
    #
    # Required: no
    # Default: './'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=trivy-iac-scan/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=actions:read,contents:read,security-events:write -->

## Trivy IaC scan

Uses [Trivy](https://github.com/aquasecurity/trivy) to scan IaC and report security issues.
The action will report any vulnerabilities to GitHub Advanced Security, which will be visible in the Security tab on GitHub.
If this action is ran on a pull request, GitHub Advanced Security will give a detailed report of any vulnerabilities introduced by new changes in the pull request.

### Inputs

| Name            | Description                                                                                                                                                                                                                                                                                                                                                                                                 | Required | Default                            |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------- |
| `checkout`      | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.                                                                                                                                                                                                                                                                        | no       | `true`                             |
| `path`          | Path to the directory containing the IaC files.                                                                                                                                                                                                                                                                                                                                                             | no       | `.`                                |
| `severity`      | Severity levels to scan for. Can any combination of `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`, and `UNKNOWN`. Multiple values must be comma-separated.                                                                                                                                                                                                                                                            | no       | `CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN` |
| `skip-dirs`     | Comma-separated list of directories to skip.                                                                                                                                                                                                                                                                                                                                                                | no       |                                    |
| `trivyignore`   | Path to the Trivy ignore file (`.trivyignore`) in the repository. This action will add a default set of CVE's that are ignored for all scans. If you wish to add more CVE's to ignore, add them to `.trivyignore`, or create a new file and specify the path here. See [Trivy documentation](https://aquasecurity.github.io/trivy/v0.50/docs/configuration/filtering/#by-finding-ids) for more information. | no       | `.trivyignore`                     |
| `upload-report` | Whether or not to upload the report generated by Trivy to the GitHub _Security_ tab. GitHub Advanced Security must be enabled for the repository to use this feature.                                                                                                                                                                                                                                       | no       | `true`                             |

### Permissions

This action requires the following [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `actions: read`
- `contents: read`
- `security-events: write`

### Usage

```yaml
- name: Trivy IaC scan
  uses: 3lvia/core-github-actions-templates/trivy-iac-scan@trunk
  with:
    checkout:
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    path:
    # Path to the directory containing the IaC files.
    #
    # Required: no
    # Default: '.'

    severity:
    # Severity levels to scan for. Can any combination of `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`, and `UNKNOWN`. Multiple values must be comma-separated.
    #
    # Required: no
    # Default: 'CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN'

    skip-dirs:
    # Comma-separated list of directories to skip.
    #
    # Required: no

    trivyignore:
    # Path to the Trivy ignore file (`.trivyignore`) in the repository. This action will add a default set of CVE's that are ignored for all scans. If you wish to add more CVE's to ignore, add them to `.trivyignore`, or create a new file and specify the path here. See [Trivy documentation](https://aquasecurity.github.io/trivy/v0.50/docs/configuration/filtering/#by-finding-ids) for more information.
    #
    # Required: no
    # Default: '.trivyignore'

    upload-report:
    # Whether or not to upload the report generated by Trivy to the GitHub *Security* tab. GitHub Advanced Security must be enabled for the repository to use this feature.
    #
    # Required: no
    # Default: 'true'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=playwright/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=checks:write,contents:read,id-token:write,issues:read,pull-requests:write -->

## Playwright Test

Run Playwright tests written in .NET.

### Inputs

| Name           | Description                                                                                                                          | Required | Default |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------- |
| `checkout`     | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out. | no       | `true`  |
| `environment`  | Environment is used to find correct Vault instance.                                                                                  | yes      |         |
| `system`       | System is used to log in to Vault using correct role.                                                                                | yes      |         |
| `test-project` | Name of test project file to run.                                                                                                    | yes      |         |

### Permissions

This action requires the following [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `checks: write`
- `contents: read`
- `id-token: write`
- `issues: read`
- `pull-requests: write`

### Usage

```yaml
- name: Playwright Test
  uses: 3lvia/core-github-actions-templates/playwright@trunk
  with:
    checkout:
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    environment:
    # Environment is used to find correct Vault instance.
    #
    # Required: yes

    system:
    # System is used to log in to Vault using correct role.
    #
    # Required: yes

    test-project:
    # Name of test project file to run.
    #
    # Required: yes
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=validate-metrics/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=id-token:write -->

## Validate Metrics

Runs a PromQL query on Grafana Cloud.
Returns success (return code 0) if the query has a result.
Returns failure if the result is empty (return code 1).

### Inputs

| Name          | Description                                                                                                                          | Required | Default |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------- |
| `checkout`    | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out. | no       | `true`  |
| `environment` | Environment is used to find correct vault instance.                                                                                  | yes      |         |
| `query`       | PromQL query string.                                                                                                                 | yes      |         |
| `system`      | System is used to log in to Vault using correct role.                                                                                | yes      |         |

### Permissions

This action requires the following [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `id-token: write`

### Usage

```yaml
- name: Validate Metrics
  uses: 3lvia/core-github-actions-templates/validate-metrics@trunk
  with:
    checkout:
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    environment:
    # Environment is used to find correct vault instance.
    #
    # Required: yes

    query:
    # PromQL query string.
    #
    # Required: yes

    system:
    # System is used to log in to Vault using correct role.
    #
    # Required: yes
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=slack-message/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=contens:read,id-token:write -->

## Slack Message

Sends a message to a Slack channel.
Permission `id-token:write` is only required if you're not defining the `slack-api-token` input.

### Inputs

| Name              | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Required | Default |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- |
| `environment`     | Environment is used to find the correct Vault instance. Not required if you use `slack-api-token`.                                                                                                                                                                                                                                                                                                                                                                                                        | no       |         |
| `message`         | Message to send to the Slack channel.                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | yes      |         |
| `namespace`       | Namespace is used to find the correct Vault role. Not required if you use `slack-api-token`.                                                                                                                                                                                                                                                                                                                                                                                                              | no       |         |
| `slack-api-token` | Slack API token. Within the Elvia organization, you can use GitHub organization secret `SLACK_API_TOKEN`. If no input is provided, the action will attempt to read the token from Elvia's Vault instance. Reading the token from Vault is only possible if the repository you are running this action from has been added to [github-repositories-terraform](https://github.com/3lvia/github-repositories-terraform), and you are running inside the GitHub Actions environments `dev`, `test` or `prod`. | no       |         |
| `slack-channel`   | Slack channel to send message to.                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | yes      |         |

### Permissions

This action requires the following [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `contens: read`
- `id-token: write`

### Usage

```yaml
- name: Slack Message
  uses: 3lvia/core-github-actions-templates/slack-message@trunk
  with:
    environment:
    # Environment is used to find the correct Vault instance. Not required if you use `slack-api-token`.
    #
    # Required: no

    message:
    # Message to send to the Slack channel.
    #
    # Required: yes

    namespace:
    # Namespace is used to find the correct Vault role. Not required if you use `slack-api-token`.
    #
    # Required: no

    slack-api-token:
    # Slack API token. Within the Elvia organization, you can use GitHub organization secret `SLACK_API_TOKEN`.  If no input is provided, the action will attempt to read the token from Elvia's Vault instance. Reading the token from Vault is only possible if the repository you are running this action from has been added to [github-repositories-terraform](https://github.com/3lvia/github-repositories-terraform), and you are running inside the GitHub Actions environments `dev`, `test` or `prod`.
    #
    # Required: no

    slack-channel:
    # Slack channel to send message to.
    #
    # Required: yes
```

<!-- gh-actions-docs-end -->

## Elvia-specific actions

The below list of actions are specific to Elvia's infrastructure and will not work outside our organization:

- [Deploy](#deploy)
- [SonarCloud](#sonarcloud)
- [PlayWright Test](#playwright-test)
- [Validate Metrics](#validate-metrics)

# Development

## Formatting

We use [Prettier](https://prettier.io) to format the README and yaml files.
See the [installation guide](https://prettier.io/docs/en/install) for how to install it.

Run Prettier with this command:

```bash
prettier -w --single-quote "**/*.yml" "**/*.md"
#OR
prettier -w --single-quote --end-of-line crlf "**/*.yml" "**/*.md"
```

## Action documentation & table of contents

Documentation in the README is auto-generated for any actions in the repository using [3lvia/gh-actions-docs](https://github.com/3lvia/gh-actions-docs).
The table of contents is also auto-generated, using the headers in this README.
To add documentation for a new action, add these two tags to the `README.md` file:

```markdown
<!-- gh-actions-docs-start path=my-new-action/action.yml owner=3lvia project=core-github-actions-templates version=trunk -->
<!-- gh-actions-docs-end -->
```

Replace `path` with the path to the action yaml file from the root of the repository.
The fields `owner`, `project` and `version` are optional, but should be set to `3lvia`, `core-github-actions-templates` and `trunk` respectively.
The field `permissions` is also optional, but should be set to the permissions required for the action to run, e.g. `permissions=actions:read,contents:read`.

The documentation will then be auto-generated, added to the table of contents and commited on push to the `trunk` branch.
