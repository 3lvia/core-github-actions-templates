#!/usr/bin/env python3
from __future__ import annotations

import os
import re
import sys
from pathlib import Path

import yaml

# Organizations that don't require digest pinning
EXEMPT_ORGS = {
    "3lvia",
}

# Organizations that should warn if not pinned (but are allowed)
WARNING_ORGS = {
    "actions",                 # GitHub official actions
    "github",                  # CodeQL actions m.m.
    "docker",                  # Official Docker actions
    "azure",                   # Microsoft Azure actions
    "google-github-actions",   # Google Cloud official actions
    "hashicorp",               # Terraform/Vault
    "slackapi",                # Slack official
    "sigstore",                # Cosign / supply chain tooling
    "sonarsource",             # SonarQube official
    "astral-sh",               # uv (Python toolchain)
    "pnpm",                    # pnpm setup
}

SHA_RE = re.compile(r"^[0-9a-fA-F]{40}$")
DOCKER_DIGEST_RE = re.compile(r"^sha256:[0-9a-fA-F]{64}$")

# Environment variable to run in warning-only mode
WARNING_MODE = True  # os.getenv("VERIFY_ACTION_PINNING_WARNING_MODE", "").lower() in ("true", "1", "yes")

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

def check_uses(uses: str) -> tuple[str, str] | None:
    """
    Returns None if OK, or (severity, message) where severity is 'warning' or 'error'
    """
    # Local action: allowed
    if is_local_action(uses):
        return None

    # Docker image reference: must be pinned to SHA256 digest
    if is_docker_image_step(uses):
        parsed = parse_uses(uses)
        if not parsed:
            return ("error", f"Docker image must be pinned to SHA256 digest: {uses}")
        _, ref = parsed
        if DOCKER_DIGEST_RE.fullmatch(ref):
            return None
        return ("error", f"Docker image must be pinned to SHA256 digest: {uses}")

    parsed = parse_uses(uses)
    if not parsed:
        return ("error", f"Malformed uses reference: {uses}")

    target, ref = parsed
    owner = owner_of_target(target)
    if not owner:
        return ("error", f"Cannot determine owner for uses reference: {uses}")

    # Exempt orgs don't require pinning
    if owner.lower() in {org.lower() for org in EXEMPT_ORGS}:
        return None

    # External actions must be pinned to full SHA
    if SHA_RE.fullmatch(ref):
        return None

    # Warning orgs should be pinned but give warning if not
    if owner.lower() in {org.lower() for org in WARNING_ORGS}:
        return ("warning", f"Action should be pinned to full SHA: {uses}")

    # Everything else is an error if not pinned
    exempt_list = ", ".join(sorted(EXEMPT_ORGS))
    return (
        "error",
        f"External action must be pinned to full SHA: {uses} "
        f"(only exempt: {exempt_list})"
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

    warnings: list[str] = []
    errors: list[str] = []

    for file in sorted(workflow_dir.glob("*.y*ml")):
        try:
            data = yaml.safe_load(file.read_text(encoding="utf-8"))
        except Exception as exc:
            errors.append(f"{file}: Failed to parse YAML: {exc}")
            continue

        uses_values: list[str] = []
        collect_uses(data, uses_values)

        for uses in uses_values:
            result = check_uses(uses)
            if result:
                severity, message = result
                full_message = f"{file}: {message}"
                if severity == "warning":
                    warnings.append(full_message)
                else:
                    errors.append(full_message)

    if warnings:
        print("Warnings:\n")
        for warning in warnings:
            print(f"- {warning}")

    if errors:
        print("Policy violations found:\n")
        for error in errors:
            print(f"- {error}")
        return 1 if not WARNING_MODE else 0

    if not warnings:
        print("All workflows comply with action pinning policy.")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())