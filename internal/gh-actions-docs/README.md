# gh-actions-docs

Automatically generate documentation for your GitHub Actions composite actions.

## Setup

### Docker

```bash
docker build . -t gh-actions-docs:latest
docker run -v $(pwd):/opt gh-actions-docs:latest
```

### Local

Install [GHCUp](https://www.haskell.org/ghcup), which should include Cabal.

```bash
cabal update
cabal install
gh-actions-docs
```

## Usage

The documentation will be added to the file `README.md` in the current directory.
The specify where the documentation should be added, add the following two comments to the file:

```markdown
<!--gh-actions-docs path=your/cool/action.yml owner=3lvia project=cool-action version=v3 -->
<!--gh-actions-docs-end -->
```

The `path` parameter is required, and the `owner`, `project`, and `version` parameters are optional.
The latter three are only used to generate the "Usage" section of the documentation.
If any of these are omitted, the "Usage" section will not be generated.

### GitHub Actions

```yaml
name: Generate documentation

on:
  push:
    branches: [trunk]

jobs:
  generate_docs:
    name: Generate documentation
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Generate documentation
        uses: 3lvia/core-github-actions-templates/gh-actions-docs@trunk
```
