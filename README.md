# core-github-actions-templates

## Trivy scanning

Uses https://github.com/aquasecurity/trivy-action to scan IaC and report security issues.
When run during a pull request where the pull request contains vulnerable code,
the action will comment directly on the pull request with information about the vulnerability.
If the vulnerable code is already present in the repository, it will just fail and output
a report to the GitHub step summary.

### Inputs

| Name             | Type    | Default                | Description                                                                                                                   |
| ---------------- | ------- | ---------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `path`           | String  | `.`                    | Path to IaC to scan.                                                                                               |
| `skip-dirs`      | String  |                        | Comma-separated list of directories to skip                                                                                   |
| `severity`       | String  | `CRITICAL,HIGH,MEDIUM` | Severity levels to scan for. See https://github.com/aquasecurity/trivy-action?tab=readme-ov-file#inputs for more information. |
| `upload-report`  | Boolean | `true`                 | Upload Trivy report to step summary.                                                                                          |
| `comment-report` | Boolean | `true`                 | Comment on pull request with Trivy report.                                                                                    |
| `ignore-unfixed` | Boolean |                        | Ignore unpatched/unfixed vulnerabilities.                                                                                     |

### Example

```yaml
name: Scan Terraform code with Trivy

on:
  pull_request:
    branches: [develop, master]

jobs:
  trivy_scan:
    permissions:
      contents: read
      pull-requests: write
    uses: 3lvia/core-github-actions-templates/.github/workflows/trivy-scan.yaml@v1
    with:
       skip-dirs: 'frontend'
       upload-report: false
```

## Terraform format

Uses built-in formatter for Terraform CLI to check format of Terraform code.

### Inputs

| Name             | Type    | Default                | Description                                                                                                                   |
| ---------------- | ------- | ---------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `path`           | String  | `.`                    | Path to process.
