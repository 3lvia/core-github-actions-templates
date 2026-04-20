#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

import yaml

# Organizations that don't require digest pinning
APPROVED_ORGS = {
    "3lvia",
    "actions",  # GitHub's official actions
}
SHA_RE = re.compile(r"^[0-9a-fA-F]{40}$")
DOCKER_DIGEST_RE = re.compile(r"^sha256:[0-9a-fA-F]{64}$")

def is_local_action(uses: str) -> bool:
    return uses.startswith("./")

def is_docker_image_step(uses: str) -> bool:
    return uses.startswith("docker://")

def parse_uses(uses: str) -> tuple[str, str] | None:
    """
    Returns (target, ref) for strings like:
      owner/repo@ref
      owner/repo/path/file.yml@ref
    Returns None for malformed values.
    """
    if "@" not in uses:
        return None
    target, ref = uses.rsplit("@", 1)
    return target, ref

def owner_of_target(target: str) -> str | None:
    """
    owner/repo -> owner
    owner/repo/path/file.yml -> owner
    """
    parts = target.split("/")
    if len(parts) < 2:
        return None
    return parts[0]

def check_uses(uses: str) -> str | None:
    # Local action: allowed
    if is_local_action(uses):
        return None

    # Docker image reference: must be pinned to SHA256 digest
    if is_docker_image_step(uses):
        parsed = parse_uses(uses)
        if not parsed:
            return f"Docker image must be pinned to SHA256 digest: {uses}"
        _, ref = parsed
        if DOCKER_DIGEST_RE.fullmatch(ref):
            return None
        return f"Docker image must be pinned to SHA256 digest: {uses}"

    parsed = parse_uses(uses)
    if not parsed:
        return f"Malformed uses reference: {uses}"

    target, ref = parsed
    owner = owner_of_target(target)
    if not owner:
        return f"Cannot determine owner for uses reference: {uses}"

    # Approved orgs are exempt from digest requirement
    if owner.lower() in {org.lower() for org in APPROVED_ORGS}:
        return None

    # External actions must be pinned to full SHA
    if SHA_RE.fullmatch(ref):
        return None

    approved_list = ", ".join(sorted(APPROVED_ORGS))
    return (
        f"External action or workflow must be pinned to full SHA: {uses} "
        f"(owner '{owner}' is not in approved orgs: {approved_list})"
    )

def collect_uses(node, found: list[str]) -> None:
    if isinstance(node, dict):
        for key, value in node.items():
            if key == "uses" and isinstance(value, str):
                found.append(value)
            else:
                collect_uses(value, found)
    elif isinstance(node, list):
        for item in node:
            collect_uses(item, found)

def main() -> int:
    workflow_dir = Path(".github/workflows")
    if not workflow_dir.exists():
        print("No .github/workflows directory found; nothing to validate.")
        return 0

    failures: list[str] = []

    for file in sorted(workflow_dir.glob("*.y*ml")):
        try:
            data = yaml.safe_load(file.read_text(encoding="utf-8"))
        except Exception as exc:
            failures.append(f"{file}: Failed to parse YAML: {exc}")
            continue

        uses_values: list[str] = []
        collect_uses(data, uses_values)

        for uses in uses_values:
            error = check_uses(uses)
            if error:
                failures.append(f"{file}: {error}")

    if failures:
        print("Policy violations found:\n")
        for failure in failures:
            print(f"- {failure}")
        return 1

    print("All workflows comply with action pinning policy.")
    return 0

if __name__ == "__main__":
    sys.exit(main())