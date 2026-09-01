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
    - [Outputs](#outputs)
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
  - [Verify Edna Deploy](#verify-edna-deploy)
    - [Inputs](#inputs-9)
    - [Permissions](#permissions-9)
    - [Usage](#usage-9)
  - [Slack Message](#slack-message)
    - [Inputs](#inputs-10)
    - [Permissions](#permissions-10)
    - [Usage](#usage-10)
  - [ISS Tag & Push Image](#iss-tag--push-image)
    - [Inputs](#inputs-11)
    - [Permissions](#permissions-11)
    - [Usage](#usage-11)
  - [Vault](#vault)
    - [Inputs](#inputs-12)
    - [Permissions](#permissions-12)
    - [Usage](#usage-12)
  - [NuGet Publish](#nuget-publish)
    - [Inputs](#inputs-13)
    - [Permissions](#permissions-13)
    - [Usage](#usage-13)
  - [Elvia-specific Actions](#elvia-specific-actions)
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

<!-- gh-actions-docs-start path=build/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=actions:read,contents:read,id-token:write,pull-requests:write,security-events:write -->

## Build

Builds a Docker image, signs it using Cosign, scans it for vulnerabilities using Trivy and pushes to either Azure Container Registry or GitHub Container Registry.
This action is a wrapper around the [3lv CLI](https://github.com/3lvia/cli) build command (`3lv build`).
To use the `Build` and `Deploy` actions with Elvias container registry and runtime services,
you must first add your GitHub repository to [github-repositories-terraform](https://github.com/3lvia/github-repositories-terraform).
If you are running on ISS, you should add the repository to [iss-terraform](https://github.com/3lvia/iss-terraform) instead.

### Inputs

| Name                        | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Required | Default                                                                                                            |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------ |
| `ACR_NAME`                  | Name of the Azure Container Registry to push to. Only required if using your own ACR.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | no       |                                                                                                                    |
| `AZURE_CLIENT_ID`           | Client ID of a service principal that can push to Azure Container Registry.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | no       |                                                                                                                    |
| `AZURE_TENANT_ID`           | Tenant ID of the Azure Container Registry to push to. Only required if using your own ACR.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | no       |                                                                                                                    |
| `checkout`                  | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | no       | `true`                                                                                                             |
| `docker-additional-tags`    | Comma-separated list of additional tags to add to the image, e.g. `latest,v1.0.0`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | no       |                                                                                                                    |
| `docker-build-args`         | Comma-separated list of build arguments to pass to Docker when building, e.g. `ARG1=value1,ARG2=value2`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | no       |                                                                                                                    |
| `docker-build-context`      | Docker build context, which is the working directory needed to build the Docker image. This is relative to the root of the repository. Defaults to the directory of `project-file`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | no       |                                                                                                                    |
| `docker-cache-tag`          | Tag used for getting build cache from registry. This tag is also pushed on every build, together with `github.sha-github.run_number`. This action will not push a `latest` tag; if you want a `latest` tag, you can use this input or `docker-additional-tags`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | no       | `latest-cache`                                                                                                     |
| `docker-disable-cache`      | Disable Docker layer caching. When `true`, the build will not use cached layers from the registry. Defaults to `true` on re-runs and manual workflow dispatches, ensuring fresh builds pick up security patches.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | no       | `${{ github.run_attempt > 1 \|\| github.event_name == 'workflow_dispatch' \|\| github.event_name == 'schedule' }}` |
| `go-main-package-directory` | Where the main package directory for Go projects is located, e.g. `./cmd/my-app`. Defaults to `./`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | no       |                                                                                                                    |
| `name`                      | Name of application. This will be used as the image name. For Elvia applications, do not include the namespace.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | yes      |                                                                                                                    |
| `namespace`                 | Namespace or system of the application. Required for Elvia applications.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | no       |                                                                                                                    |
| `project-file`              | Path to a `.csproj`-file for .NET, a `go.mod` file for Go, a `pyproject.toml` file for Python or a Dockerfile for any other project. E.g. `applications/my-app/my-app.csproj`, `pkg/my-app/go.mod`, `pyproject.toml` or `src/Dockerfile`. If you require files outside the directory of the `project-file` to build your application, you will need to set `docker-build-context`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | no       |                                                                                                                    |
| `push`                      | If `true`, the action will push the Docker image to the registry.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | no       | `true`                                                                                                             |
| `registry`                  | What container registry to use, we support Azure Container Registry (ACR) and GitHub Container Registry (GHCR). You should set this to the URL of the registry you want to use, e.g. `ghcr.io/3lvia` or `myregistry.azurecr.io`. The action will authenticate with the registry depending on the value of the URL, i.e. if the URL contains `azurecr.io` or `ghcr.io`. If set to an ACR registry, Elvia's private Azure Container Registry will be used by default. You can also set these explictly to point to your own ACR. Using ACR requires the permissions `id-token: write` to access the registry using OIDC. If set to a GHCR registry, the action will push to the GitHub Container Registry of the repository. Using GHCR requires the `packages: write` permission to push to the registry. **This input does not affect where `Deploy` looks for the image.** `Deploy` only sets `image.tag`; the repository comes from the Helm chart, which defaults to `containerregistryelvia.azurecr.io/$namespace-$name`. So if you push somewhere other than Elvia's ACR and then deploy with the `Deploy` action, you must also set `image.repository` (or the per-environment `image.<env>.repository`) in your Helm values file — otherwise the pod ends up in `ImagePullBackOff` and the deploy fails on a rollout timeout several minutes later, with no mention of the image in the error. | no       |                                                                                                                    |
| `severity`                  | Severity levels to scan for. See [Trivy documentation](https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs) for more information.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | no       | `CRITICAL`                                                                                                         |
| `sign-image`                | If `true`, the action will sign the Docker image with Cosign.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | no       | `true`                                                                                                             |
| `trivy-cve-ignores`         | Comma-separated list of CVEs for Trivy to ignore. See [Trivy documentation](https://trivy.dev/docs/latest/configuration/filtering/#trivyignore) for syntax.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | no       |                                                                                                                    |
| `trivy-post-comment`        | If `true`, the action will post a comment to the PR with the Trivy scan results. The comment will only be posted if the action is ran on a pull request. This action requires the permission `pull-requests: write` to be set for the job.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | no       | `true`                                                                                                             |
| `trivy-upload-report`       | If `true`, the action will upload Trivy scan results to GitHub Advanced Security. This actions requires GitHub Advanced Security to be enabled for the repository, and the permissions `actions: read` and `security-events: write` to be set for the job.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | no       | `true`                                                                                                             |

### Outputs

| Name                     | Description                                                    |
| ------------------------ | -------------------------------------------------------------- |
| `image`                  | Same as `image-name-with-digest`.                              |
| `image-digest`           | Digest of the Docker image that was built.                     |
| `image-name-with-digest` | Name of the Docker image that was built, including the digest. |
| `image-name-with-tag`    | Name of the Docker image that was built, including the tag.    |
| `image-repository`       | Repository name of the Docker image that was built.            |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `actions: read`
- `contents: read`
- `id-token: write`
- `pull-requests: write`
- `security-events: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

### Usage

```yaml
- name: Build
  uses: 3lvia/core-github-actions-templates/build@trunk
  with:
    ACR_NAME:
    # Name of the Azure Container Registry to push to. Only required if using your own ACR.
    #
    # Required: no

    AZURE_CLIENT_ID:
    # Client ID of a service principal that can push to Azure Container Registry.
    #
    # Required: no

    AZURE_TENANT_ID:
    # Tenant ID of the Azure Container Registry to push to. Only required if using your own ACR.
    #
    # Required: no

    checkout:
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    docker-additional-tags:
    # Comma-separated list of additional tags to add to the image, e.g. `latest,v1.0.0`.
    #
    # Required: no

    docker-build-args:
    # Comma-separated list of build arguments to pass to Docker when building, e.g. `ARG1=value1,ARG2=value2`.
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

    docker-disable-cache:
    # Disable Docker layer caching. When `true`, the build will not use cached layers from the registry. Defaults to `true` on re-runs and manual workflow dispatches, ensuring fresh builds pick up security patches.
    #
    # Required: no
    # Default: '${{ github.run_attempt > 1 || github.event_name == 'workflow_dispatch' || github.event_name == 'schedule' }}'

    go-main-package-directory:
    # Where the main package directory for Go projects is located, e.g. `./cmd/my-app`. Defaults to `./`
    #
    # Required: no

    name:
    # Name of application. This will be used as the image name. For Elvia applications, do not include the namespace.
    #
    # Required: yes

    namespace:
    # Namespace or system of the application. Required for Elvia applications.
    #
    # Required: no

    project-file:
    # Path to a `.csproj`-file for .NET, a `go.mod` file for Go, a `pyproject.toml` file for Python or a Dockerfile for any other project. E.g. `applications/my-app/my-app.csproj`, `pkg/my-app/go.mod`, `pyproject.toml` or `src/Dockerfile`. If you require files outside the directory of the `project-file` to build your application, you will need to set `docker-build-context`.
    #
    # Required: no

    push:
    # If `true`, the action will push the Docker image to the registry.
    #
    # Required: no
    # Default: 'true'

    registry:
    # What container registry to use, we support Azure Container Registry (ACR) and GitHub Container Registry (GHCR). You should set this to the URL of the registry you want to use, e.g. `ghcr.io/3lvia` or `myregistry.azurecr.io`. The action will authenticate with the registry depending on the value of the URL, i.e. if the URL contains `azurecr.io` or `ghcr.io`.  If set to an ACR registry, Elvia's private Azure Container Registry will be used by default. You can also set these explictly to point to your own ACR. Using ACR requires the permissions `id-token: write` to access the registry using OIDC.  If set to a GHCR registry, the action will push to the GitHub Container Registry of the repository. Using GHCR requires the `packages: write` permission to push to the registry.  **This input does not affect where `Deploy` looks for the image.** `Deploy` only sets `image.tag`; the repository comes from the Helm chart, which defaults to `containerregistryelvia.azurecr.io/$namespace-$name`. So if you push somewhere other than Elvia's ACR and then deploy with the `Deploy` action, you must also set `image.repository` (or the per-environment `image.<env>.repository`) in your Helm values file — otherwise the pod ends up in `ImagePullBackOff` and the deploy fails on a rollout timeout several minutes later, with no mention of the image in the error.
    #
    # Required: no

    severity:
    # Severity levels to scan for. See [Trivy documentation](https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs) for more information.
    #
    # Required: no
    # Default: 'CRITICAL'

    sign-image:
    # If `true`, the action will sign the Docker image with Cosign.
    #
    # Required: no
    # Default: 'true'

    trivy-cve-ignores:
    # Comma-separated list of CVEs for Trivy to ignore. See [Trivy documentation](https://trivy.dev/docs/latest/configuration/filtering/#trivyignore) for syntax.
    #
    # Required: no

    trivy-post-comment:
    # If `true`, the action will post a comment to the PR with the Trivy scan results. The comment will only be posted if the action is ran on a pull request. This action requires the permission `pull-requests: write` to be set for the job.
    #
    # Required: no
    # Default: 'true'

    trivy-upload-report:
    # If `true`, the action will upload Trivy scan results to GitHub Advanced Security. This actions requires GitHub Advanced Security to be enabled for the repository, and the permissions `actions: read` and `security-events: write` to be set for the job.
    #
    # Required: no
    # Default: 'true'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=deploy/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=contents:read,id-token:write -->

## Deploy

Deploys an application to Kubernetes using the Elvia Helm chart.
This action is a wrapper around the [3lv CLI](https://github.com/3lvia/cli) deploy command (`3lv deploy`).

To use the `Build` and `Deploy` actions with Elvias container registry and runtime services,
you must first add your GitHub repository to [github-repositories-terraform](https://github.com/3lvia/github-repositories-terraform).
If you are running on ISS, you should add the repository to [iss-terraform](https://github.com/3lvia/iss-terraform) instead.

This action sets only the image _tag_. The image repository comes from the Helm chart and
defaults to `containerregistryelvia.azurecr.io/$namespace-$name`, so there is no `registry`
input here. If `Build` pushed somewhere else (e.g. GHCR), override `image.repository` in your
Helm values file to match — otherwise this action deploys a reference to an image that does
not exist, and fails on a rollout timeout rather than a missing-image error.

### Inputs

| Name                            | Description                                                                                                                                                                                                                             | Required | Default                     |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------------- |
| `AKS_CLUSTER_NAME`              | Name of the AKS cluster to deploy to. Defaults to Elvias normal clusters.                                                                                                                                                               | no       |                             |
| `AKS_RESOURCE_GROUP`            | Resource group of the AKS cluster to deploy to. Defaults to Elvias normal clusters.                                                                                                                                                     | no       |                             |
| `AKS_SUBSCRIPTION_ID`           | Subscription ID of AKS to deploy to. Defaults to Elvias normal clusters.                                                                                                                                                                | no       |                             |
| `AZURE_CLIENT_ID`               | Client ID of a service principal that has access to AKS. Only required for deploying to AKS.                                                                                                                                            | no       |                             |
| `AZURE_TENANT_ID`               | Tenant ID of AKS to deploy to. Defaults to Elvias normal clusters.                                                                                                                                                                      | no       |                             |
| `GC_SERVICE_ACCOUNT`            | Service account to use for deploying to GKE. Only required for deploying to GKE.                                                                                                                                                        | no       |                             |
| `GC_WORKLOAD_IDENTITY_PROVIDER` | Workload identity provider to use for deploying to GKE. Only required for deploying to GKE.                                                                                                                                             | no       |                             |
| `GKE_CLUSTER_LOCATION`          | Location of the GKE cluster to deploy to.                                                                                                                                                                                               | no       | `europe-west1`              |
| `GKE_CLUSTER_NAME`              | Name of the GKE cluster to deploy to. Defaults to Elvias normal clusters.                                                                                                                                                               | no       |                             |
| `GKE_PROJECT_ID`                | Project ID of GKE to deploy to. Defaults to Elvias normal clusters.                                                                                                                                                                     | no       |                             |
| `checkout`                      | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.                                                                                                    | no       | `true`                      |
| `dry-run`                       | Simulate the deployment without actually deploying.                                                                                                                                                                                     | no       | `false`                     |
| `environment`                   | Environment to deploy to.                                                                                                                                                                                                               | yes      |                             |
| `helm-chart-repository-url`     | Location of Elvia's Helm chart repository; should only be changed if testing a new version of the chart.                                                                                                                                | no       |                             |
| `helm-values-file`              | Path to Helm values file, relative to the root of the repository.                                                                                                                                                                       | no       | `.github/deploy/values.yml` |
| `helm-values-path`              | :warning: **DEPRECATED**: _Please use `helm-values-file` instead, which is a drop-in replacement. `helm-values-path` will be removed in the future._ :warning:<br><br>Path to Helm values file, relative to the root of the repository. | no       |                             |
| `name`                          | Name of application. Do not include namespace.                                                                                                                                                                                          | yes      |                             |
| `namespace`                     | Namespace or system of the application.                                                                                                                                                                                                 | yes      |                             |
| `override-image-tag`            | Overrides the default image tag of 'github.sha-github.run_number'. **This should not normally be set; only change this if you know what you are doing.**                                                                                | no       | ``                          |
| `runtime-cloud-provider`        | Kubernetes cloud provider to deploy to: `AKS`, `GKE` or ISS (Elvia only).                                                                                                                                                               | no       | `AKS`                       |
| `slack-channel`                 | Slack channel to notify on failure. Leave empty to disable notifications.                                                                                                                                                               | no       | ``                          |
| `workload-type`                 | The type of workload to deploy to Kubernetes. Must be `deployment`, `statefulset` or `job`.                                                                                                                                             | no       | `deployment`                |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `contents: read`
- `id-token: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

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
    # Tenant ID of AKS to deploy to. Defaults to Elvias normal clusters.
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

    GKE_CLUSTER_LOCATION:
    # Location of the GKE cluster to deploy to.
    #
    # Required: no
    # Default: 'europe-west1'

    GKE_CLUSTER_NAME:
    # Name of the GKE cluster to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: no

    GKE_PROJECT_ID:
    # Project ID of GKE to deploy to. Defaults to Elvias normal clusters.
    #
    # Required: no

    checkout:
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    dry-run:
    # Simulate the deployment without actually deploying.
    #
    # Required: no
    # Default: 'false'

    environment:
    # Environment to deploy to.
    #
    # Required: yes

    helm-chart-repository-url:
    # Location of Elvia's Helm chart repository; should only be changed if testing a new version of the chart.
    #
    # Required: no

    helm-values-file:
    # Path to Helm values file, relative to the root of the repository.
    #
    # Required: no
    # Default: '.github/deploy/values.yml'

    name:
    # Name of application. Do not include namespace.
    #
    # Required: yes

    namespace:
    # Namespace or system of the application.
    #
    # Required: yes

    override-image-tag:
    # Overrides the default image tag of 'github.sha-github.run_number'. **This should not normally be set; only change this if you know what you are doing.**
    #
    # Required: no
    # Default: ''

    runtime-cloud-provider:
    # Kubernetes cloud provider to deploy to: `AKS`, `GKE` or ISS (Elvia only).
    #
    # Required: no
    # Default: 'AKS'

    slack-channel:
    # Slack channel to notify on failure. Leave empty to disable notifications.
    #
    # Required: no
    # Default: ''

    workload-type:
    # The type of workload to deploy to Kubernetes. Must be `deployment`, `statefulset` or `job`.
    #
    # Required: no
    # Default: 'deployment'
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=unittest/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=checks:write,contents:read,issues:read,pull-requests:write -->

## Unit Test

Run .NET unit tests.

### Inputs

| Name                          | Description                                                                                                                                                                                                       | Required | Default                                                    |
| ----------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------- |
| `checkout`                    | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.                                                                              | no       | `true`                                                     |
| `coverlet-runsettings-file`   | Path to a coverlet runsettings file, relative to the root of the repository. If not specified, no runsettings file will be used for coverlet.                                                                     | no       | ``                                                         |
| `dotnet-tool-manifest`        | Path to the .NET tool manifest file, relative to the root of the repository. Only needed if you require .NET tools that are outside of `working-directory` for the build.                                         | no       | `./.config/dotnet-tools.json`                              |
| `test-coverage`               | If test coverage should be computed. Requires a NuGet coverage package in each test project: `coverlet.collector` (VSTest mode) or `Microsoft.Testing.Extensions.CodeCoverage` (Microsoft.Testing.Platform mode). | no       | `false`                                                    |
| `test-projects`               | Pattern to use to find test projects.                                                                                                                                                                             | no       | `unit*test*csproj`                                         |
| `test-results-artifact-name`  | Name of the workflow artifact that the raw .trx test result files are uploaded to. Must be unique within the workflow run.                                                                                        | no       | `unit-test-results-${{ github.job }}-${{ github.action }}` |
| `test-results-retention-days` | How many days to keep the uploaded test result artifact.                                                                                                                                                          | no       | `14`                                                       |
| `working-directory`           | Will run unit tests on projects under this working directory.                                                                                                                                                     | no       | `./`                                                       |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `checks: write`
- `contents: read`
- `issues: read`
- `pull-requests: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

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

    coverlet-runsettings-file:
    # Path to a coverlet runsettings file, relative to the root of the repository. If not specified, no runsettings file will be used for coverlet.
    #
    # Required: no
    # Default: ''

    dotnet-tool-manifest:
    # Path to the .NET tool manifest file, relative to the root of the repository. Only needed if you require .NET tools that are outside of `working-directory` for the build.
    #
    # Required: no
    # Default: './.config/dotnet-tools.json'

    test-coverage:
    # If test coverage should be computed. Requires a NuGet coverage package in each test project: `coverlet.collector` (VSTest mode) or `Microsoft.Testing.Extensions.CodeCoverage` (Microsoft.Testing.Platform mode).
    #
    # Required: no
    # Default: 'false'

    test-projects:
    # Pattern to use to find test projects.
    #
    # Required: no
    # Default: 'unit*test*csproj'

    test-results-artifact-name:
    # Name of the workflow artifact that the raw .trx test result files are uploaded to. Must be unique within the workflow run.
    #
    # Required: no
    # Default: 'unit-test-results-${{ github.job }}-${{ github.action }}'

    test-results-retention-days:
    # How many days to keep the uploaded test result artifact.
    #
    # Required: no
    # Default: '14'

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

| Name                          | Description                                                                                                                                                               | Required | Default                                                           |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------------------------------------------- |
| `checkout`                    | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.                                      | no       | `true`                                                            |
| `dotnet-tool-manifest`        | Path to the .NET tool manifest file, relative to the root of the repository. Only needed if you require .NET tools that are outside of `working-directory` for the build. | no       | `./.config/dotnet-tools.json`                                     |
| `environment`                 | Environment is used to find correct Vault instance.                                                                                                                       | yes      | `dev`                                                             |
| `slack-channel`               | Slack channel to notify on failure. Leave empty to disable notifications                                                                                                  | no       | ``                                                                |
| `system`                      | System is used to log in to Vault using correct role.                                                                                                                     | yes      |                                                                   |
| `test-projects`               | Pattern to use to find test projects.                                                                                                                                     | no       | `integration*test*csproj`                                         |
| `test-results-artifact-name`  | Name of the workflow artifact that the raw .trx test result files are uploaded to. Must be unique within the workflow run.                                                | no       | `integration-test-results-${{ github.job }}-${{ github.action }}` |
| `test-results-retention-days` | How many days to keep the uploaded test result artifact.                                                                                                                  | no       | `14`                                                              |
| `working-directory`           | Will run integration tests on projects under this working directory.                                                                                                      | no       | `./`                                                              |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `checks: write`
- `contents: read`
- `id-token: write`
- `issues: read`
- `pull-requests: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

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

    dotnet-tool-manifest:
    # Path to the .NET tool manifest file, relative to the root of the repository. Only needed if you require .NET tools that are outside of `working-directory` for the build.
    #
    # Required: no
    # Default: './.config/dotnet-tools.json'

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

    test-results-artifact-name:
    # Name of the workflow artifact that the raw .trx test result files are uploaded to. Must be unique within the workflow run.
    #
    # Required: no
    # Default: 'integration-test-results-${{ github.job }}-${{ github.action }}'

    test-results-retention-days:
    # How many days to keep the uploaded test result artifact.
    #
    # Required: no
    # Default: '14'

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

| Name                   | Description                                                                                                                                                               | Required | Default                       |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------- |
| `checkout`             | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.                                      | no       | `true`                        |
| `dotnet-tool-manifest` | Path to the .NET tool manifest file, relative to the root of the repository. Only needed if you require .NET tools that are outside of `working-directory` for the build. | no       | `./.config/dotnet-tools.json` |
| `go-version`           | Version of Go to use. Only used if `language` is set to `go`.                                                                                                             | no       | `stable`                      |
| `language`             | Language to run CodeQL analyze on. Use a matrix strategy to run for multiple languages.                                                                                   | no       | `csharp`                      |
| `upload-results`       | If `true` the action will upload CodeQL results to GitHub Security Code Scanning. If `false`, the action will not upload results.                                         | no       | `true`                        |
| `working-directory`    | Will run CodeQL Analysis on projects under this working directory.                                                                                                        | no       | `./`                          |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `actions: read`
- `contents: read`
- `security-events: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

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

    dotnet-tool-manifest:
    # Path to the .NET tool manifest file, relative to the root of the repository. Only needed if you require .NET tools that are outside of `working-directory` for the build.
    #
    # Required: no
    # Default: './.config/dotnet-tools.json'

    go-version:
    # Version of Go to use. Only used if `language` is set to `go`.
    #
    # Required: no
    # Default: 'stable'

    language:
    # Language to run CodeQL analyze on. Use a matrix strategy to run for multiple languages.
    #
    # Required: no
    # Default: 'csharp'

    upload-results:
    # If `true` the action will upload CodeQL results to GitHub Security Code Scanning. If `false`, the action will not upload results.
    #
    # Required: no
    # Default: 'true'

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

| Name                               | Description                                                                                                                                                 | Required | Default             |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------- |
| `checkout`                         | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.                        | no       | `true`              |
| `dotnet-coverage-runsettings-file` | Path to a dotnet-coverage runsettings file, relative to the root of the repository. If not specified, no runsettings file will be used for dotnet-coverage. | no       | ``                  |
| `github-token`                     | Should normally be `secrets.GITHUB_TOKEN`.                                                                                                                  | yes      |                     |
| `sonarcloud-project-key`           | The SonarCloud project key or id. Normally on the form `3lvia_repo-name`. The project must be manually created on sonarcloud.io.                            | yes      |                     |
| `sonarcloud-token`                 | Should normally be `secrets.SONAR_TOKEN`.                                                                                                                   | yes      |                     |
| `test-projects`                    | Pattern to use to find test projects.                                                                                                                       | no       | `*unit*test*csproj` |
| `working-directory`                | Will run SonarCloud on projects under this working directory.                                                                                               | no       | `./`                |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `checks: write`
- `contents: read`
- `id-token: write`
- `issues: read`
- `pull-requests: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

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

    dotnet-coverage-runsettings-file:
    # Path to a dotnet-coverage runsettings file, relative to the root of the repository. If not specified, no runsettings file will be used for dotnet-coverage.
    #
    # Required: no
    # Default: ''

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

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `actions: read`
- `contents: read`
- `security-events: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

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

| Name                          | Description                                                                                                                          | Required | Default                                                    |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | ---------------------------------------------------------- |
| `checkout`                    | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out. | no       | `true`                                                     |
| `configuration`               | Value to set for the `--configuration` flag when running `dotnet test`.                                                              | no       | `Debug`                                                    |
| `environment`                 | Environment is used to find correct Vault instance.                                                                                  | yes      |                                                            |
| `system`                      | System is used to log in to Vault using correct role.                                                                                | yes      |                                                            |
| `test-project`                | Name of test project file to run.                                                                                                    | yes      |                                                            |
| `test-results-artifact-name`  | Name of the workflow artifact that the raw .trx test result files are uploaded to. Must be unique within the workflow run.           | no       | `smoketest-results-${{ github.job }}-${{ github.action }}` |
| `test-results-retention-days` | How many days to keep the uploaded test result artifact.                                                                             | no       | `14`                                                       |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `checks: write`
- `contents: read`
- `id-token: write`
- `issues: read`
- `pull-requests: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

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

    configuration:
    # Value to set for the `--configuration` flag when running `dotnet test`.
    #
    # Required: no
    # Default: 'Debug'

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

    test-results-artifact-name:
    # Name of the workflow artifact that the raw .trx test result files are uploaded to. Must be unique within the workflow run.
    #
    # Required: no
    # Default: 'smoketest-results-${{ github.job }}-${{ github.action }}'

    test-results-retention-days:
    # How many days to keep the uploaded test result artifact.
    #
    # Required: no
    # Default: '14'
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

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `id-token: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

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

<!-- gh-actions-docs-start path=verify-edna-deploy/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=contents:read,id-token:write -->

## Verify Edna Deploy

Checking if a certain metric has been updated after the deployment happened
Returns success (return code 0) if the query has a result.
Returns failure if the result is empty (return code 1).

### Inputs

| Name          | Description                                                                                                                          | Required | Default |
| ------------- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------- |
| `application` | Application name is used in the derived PromQL query.                                                                                | yes      |         |
| `checkout`    | If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out. | no       | `true`  |
| `environment` | Environment is used to find correct vault instance.                                                                                  | yes      |         |
| `system`      | System name is used in the derived PromQL query.                                                                                     | yes      |         |
| `topic`       | Topic name is used in the derived PromQL query.                                                                                      | yes      |         |
| `type`        | publisher or consumer.                                                                                                               | yes      |         |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `contents: read`
- `id-token: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

### Usage

```yaml
- name: Verify Edna Deploy
  uses: 3lvia/core-github-actions-templates/verify-edna-deploy@trunk
  with:
    application:
    # Application name is used in the derived PromQL query.
    #
    # Required: yes

    checkout:
    # If `true`, the action will check out the repository. If `false`, the action will assume the repository has already been checked out.
    #
    # Required: no
    # Default: 'true'

    environment:
    # Environment is used to find correct vault instance.
    #
    # Required: yes

    system:
    # System name is used in the derived PromQL query.
    #
    # Required: yes

    topic:
    # Topic name is used in the derived PromQL query.
    #
    # Required: yes

    type:
    # publisher or consumer.
    #
    # Required: yes
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=slack-message/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=contents:read,id-token:write -->

## Slack Message

Sends a message to a Slack channel.

### Inputs

| Name            | Description                                                                                                                                                                                            | Required | Default |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------- |
| `environment`   | Environment is used to find the correct Vault instance.                                                                                                                                                | no       | `dev`   |
| `message`       | Message to send to the Slack channel.                                                                                                                                                                  | yes      |         |
| `namespace`     | :warning: **DEPRECATED**: _Please use `system` instead, which is a drop-in replacement. `namespace` will be removed in the future._ :warning:<br><br>Namespace is used to find the correct Vault role. | no       |         |
| `slack-channel` | Slack channel to send message to. The app "Github Workflow Notifications" must be added to the channel.                                                                                                | yes      |         |
| `system`        | System is used to find the correct Vault role.                                                                                                                                                         | no       |         |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `contents: read`
- `id-token: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

### Usage

```yaml
- name: Slack Message
  uses: 3lvia/core-github-actions-templates/slack-message@trunk
  with:
    environment:
    # Environment is used to find the correct Vault instance.
    #
    # Required: no
    # Default: 'dev'

    message:
    # Message to send to the Slack channel.
    #
    # Required: yes

    slack-channel:
    # Slack channel to send message to. The app "Github Workflow Notifications" must be added to the channel.
    #
    # Required: yes

    system:
    # System is used to find the correct Vault role.
    #
    # Required: no
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=iss-tag-push-image/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=contents:read,packages:read -->

## ISS Tag & Push Image

Pulls image from GHCR, re-tags it and pushes it to GCR.

_Only useful for ISS deployments._

### Inputs

| Name                      | Description                                                    | Required | Default |
| ------------------------- | -------------------------------------------------------------- | -------- | ------- |
| `new-image-name`          | Name of the Docker image to push to GCR, without the tag.      | yes      |         |
| `old-image-name-with-tag` | Name of the Docker image to pull from GHCR, including the tag. | yes      |         |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `contents: read`
- `packages: read`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

### Usage

```yaml
- name: ISS Tag & Push Image
  uses: 3lvia/core-github-actions-templates/iss-tag-push-image@trunk
  with:
    new-image-name:
    # Name of the Docker image to push to GCR, without the tag.
    #
    # Required: yes

    old-image-name-with-tag:
    # Name of the Docker image to pull from GHCR, including the tag.
    #
    # Required: yes
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=vault/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=contents:read,id-token:write -->

## Vault

Get secrets from Elvia's Vault for use in GitHub Actions.

### Inputs

| Name          | Description                                                                                                                                  | Required | Default |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------- |
| `environment` | Environment is used to find correct Vault instance.                                                                                          | no       | `dev`   |
| `exportToken` | Whether to export the Vault token as an environment variable. Set this to true if you need to be authenticated to Vault in subsequent steps. | no       | `false` |
| `secrets`     | Secrets to fetch from Vault; see [here](https://github.com/hashicorp/vault-action?tab=readme-ov-file#multiple-secrets) for syntax.           | no       |         |
| `system`      | System name is used to log in to Vault using the correct role.                                                                               | yes      |         |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `contents: read`
- `id-token: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

### Usage

```yaml
- name: Vault
  uses: 3lvia/core-github-actions-templates/vault@trunk
  with:
    environment:
    # Environment is used to find correct Vault instance.
    #
    # Default: 'dev'

    exportToken:
    # Whether to export the Vault token as an environment variable. Set this to true if you need to be authenticated to Vault in subsequent steps.
    #
    # Default: 'false'

    secrets:
    # Secrets to fetch from Vault; see [here](https://github.com/hashicorp/vault-action?tab=readme-ov-file#multiple-secrets) for syntax.
    #

    system:
    # System name is used to log in to Vault using the correct role.
    #
    # Required: yes
```

<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=nuget-publish/action.yml owner=3lvia project=core-github-actions-templates version=trunk permissions=contents:read,id-token:write -->

## NuGet Publish

Publish NuGet packages to nuget.org through the central nuget-publisher (Trusted Publishing, no API key). One publish may carry several packages.

### Inputs

| Name            | Description                                                                                     | Required | Default       |
| --------------- | ----------------------------------------------------------------------------------------------- | -------- | ------------- |
| `packages-path` | Directory containing the packed .nupkg files (and optional .snupkg). All of them are delivered. | no       | `./artifacts` |
| `system`        | System name, used to log in to Vault (same as for the vault action).                            | yes      |               |
| `wait`          | Wait for the publisher run and fail this job if it fails.                                       | no       | `true`        |

### Permissions

This action requires the following base [permissions](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs):

- `contents: read`
- `id-token: write`

More permissions might be required depending on the inputs set, see the actions documentation for more information.

### Usage

```yaml
- name: NuGet Publish
  uses: 3lvia/core-github-actions-templates/nuget-publish@trunk
  with:
    packages-path:
    # Directory containing the packed .nupkg files (and optional .snupkg). All of them are delivered.
    #
    # Required: no
    # Default: './artifacts'

    system:
    # System name, used to log in to Vault (same as for the vault action).
    #
    # Required: yes

    wait:
    # Wait for the publisher run and fail this job if it fails.
    #
    # Required: no
    # Default: 'true'
```

<!-- gh-actions-docs-end -->

## Elvia-specific Actions

The below list of actions are specific to Elvia's infrastructure and will not work outside our organization:

- [Deploy](#deploy)
- [SonarCloud](#sonarcloud)
- [PlayWright Test](#playwright-test)
- [Validate Metrics](#validate-metrics)
- [ISS Tag & Push Image](#iss-tag-push-image)
- [Vault](#vault)

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
