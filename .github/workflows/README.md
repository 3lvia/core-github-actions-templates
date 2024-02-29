# core-github-actions-templates

## Creating a new release

When referencing a GitHub Actions workflow, using a tag such as `v1` does not automatically reference the newest minor or patch release of the `v1` major release.
E.g., `v1` does not point to `v1.2.3` and `v1.2` does not point to `v.1.2.3`.
We would like the developers to automatically get patches when referencing a major tag.
Therfore, we update the latest major release to always point to the latest minor or patch release tag.

### Follow these steps when creating a new release

**1.** Create a new release with the full semver tag at the [GitHub Release page](https://github.com/3lvia/core-github-actions-templates/releases/new),
and auto-generate release notes.

**2.** Go to the repo locally and pull latest tags:

```bash
git fetch --tags
```

**3.** Override (or create) the corresponding major tag from the latest patch tag you just created, i.e. for tag `v1.2.3` use just `v1`:

```bash
git tag v1 v1.2.3 --force
```

**4.** Push the new major tag:

```bash
git push --tags --force
```

**5.** Redo the auto-generated release notes for the new major tag (so it matches the corresponding patch tag) on the [GitHub releases page](https://github.com/3lvia/core-github-actions-templates/releases).
