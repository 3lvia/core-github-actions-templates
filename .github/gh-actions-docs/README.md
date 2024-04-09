# gh-actions-docs

Automatically generate documentation for your GitHub Actions.

## Usage

The documentation will be added to the file `README.md` in the current directory.
To specify where the documentation should be added, add the following two comments to the file:

```markdown
<!--gh-actions-docs path=your/cool/action.yml owner=3lvia project=cool-action version=v3 -->
<!--gh-actions-docs-end -->
```

The `path` parameter is required, and the `owner`, `project`, and `version` parameters are optional.
The latter three are only used to generate the "Usage" section of the documentation.
If any of these are omitted, the "Usage" section will not be generated.

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
