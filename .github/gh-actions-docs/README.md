# gh-actions-docs

Automatically generate documentation for your GitHub Actions.

## Usage

The documentation will be added to the file `README.md` in the current directory.
To specify where the documentation should be added, add the following two comments to the file:

```markdown
<!--gh-actions-docs path=your/cool/action.yml owner=3lvia project=cool-action version=v3 permissions=contents:read,issues:write -->
<!--gh-actions-docs-end -->
```

Only the `path` parameter is required, and the `owner`, `project`, `version` and `permissions` parameters are optional.

The parameters `owner`, `project` and `version` are used to generate the "Usage" section.
If any of these parameters are missing, the "Usage" section will not be generated.

The `permissions` parameter is used to generate the "Permissions" section.
If this parameter is missing, the "Permissions" section will not be generated.

### Docker

```bash
docker build . -t gh-actions-docs:latest
docker run -v $(pwd):/app gh-actions-docs:latest
```

### Local

Install [GHCUp](https://www.haskell.org/ghcup), which should include Cabal.

```bash
cabal update
cabal install
gh-actions-docs
```

#### Environment variables

- `README_FILE`: The file to write the documentation to. Defaults to `README.md`.
- `DEBUG`: Set to `true` to enable debug output.
- `IGNORE_FILES`: Comma-separated list of YAML files to ignore.
- `IGNORE_HEADERS`: Comma-separated list of headers to ignore.
- `NO_ACTIONS`: Set to `true` to disable generation of actions documentation.
- `NO_TOC`: Set to `true` to disable generation of table of contents.
