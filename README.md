# core-github-actions-templates

GitHub Actions templates for the Elvia organization.

## Table of Contents

<!-- gh-actions-docs-toc-start -->
<!-- gh-actions-docs-toc-end -->

# Actions

<!-- gh-actions-docs-start path=build/action.yml owner=3lvia project=core-github-actions-templates version=trunk -->
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

<!-- gh-actions-docs-start path=deploy/action.yml owner=3lvia project=core-github-actions-templates version=trunk -->
<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=unittest/action.yml owner=3lvia project=core-github-actions-templates version=trunk -->
<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=analyze/action.yml owner=3lvia project=core-github-actions-templates version=trunk -->
<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=trivy-iac-scan/action.yml owner=3lvia project=core-github-actions-templates version=trunk -->
<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=playwright/action.yml owner=3lvia project=core-github-actions-templates version=trunk -->
<!-- gh-actions-docs-end -->

<!-- gh-actions-docs-start path=terraform-format/action.yml owner=3lvia project=core-github-actions-templates version=trunk -->
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
