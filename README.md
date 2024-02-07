# core-github-actions-templates

## Trivy scanning

Uses https://github.com/aquasecurity/trivy-action to scan IaC and report security issues.
The action will report any vulnerabilities to GitHub Advanced Security, which will be visible
in the Security tab on GitHub.

### Inputs

| Name             | Type    | Default                | Description                                                                                                                   |
| ---------------- | ------- | ---------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `path`           | String  | `.`                    | Path to IaC to scan.                                                                                                          |
| `skip-dirs`      | String  |                        | Comma-separated list of directories to skip                                                                                   |
| `severity`       | String  | `CRITICAL,HIGH,MEDIUM` | Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information. |
| `upload-report`  | Boolean | `true`                 | Upload Trivy report to GitHub Security tab.                                                                                   |
| `ignore-unfixed` | Boolean | `false`                | Ignore unpatched/unfixed vulnerabilities.                                                                                     |

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
