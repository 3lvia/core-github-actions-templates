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


def print_summary(
    workflow_count: int,
    ok_actions: int,
    missing_digest_actions: int,
) -> None:
    print(
        "::notice::Action pinning summary - "
        f"workflows={workflow_count}, ok_actions={ok_actions}, "
        f"missing_digest={missing_digest_actions}"
    )
    print("Summary:")
    print(f"- Workflows checked: {workflow_count}")
    print(f"- OK actions: {ok_actions}")
    print(f"- Actions with missing digest: {missing_digest_actions}")

    step_summary_path = os.getenv("GITHUB_STEP_SUMMARY")
    if step_summary_path:
        summary_lines = [
            "## Action pinning summary",
            "",
            "| Metric | Value |",
            "| --- | ---: |",
            f"| Workflows checked | {workflow_count} |",
            f"| OK actions | {ok_actions} |",
            f"| Actions with missing digest | {missing_digest_actions} |",
            "",
        ]
        with open(step_summary_path, "a", encoding="utf-8") as summary_file:
            summary_file.write("\n".join(summary_lines))

def main() -> int:
    workflow_dir = Path(".github/workflows")
    if not workflow_dir.exists():
        print("No .github/workflows directory found; nothing to validate.")
        return 0

    workflow_files = sorted(workflow_dir.glob("*.y*ml"))
    warnings: list[tuple[str, str]] = []
    errors: list[tuple[str, str]] = []
    ok_actions = 0
    missing_digest_actions = 0

    for file in workflow_files:
        try:
            data = yaml.safe_load(file.read_text(encoding="utf-8"))
        except Exception as exc:
            errors.append((str(file), f"Failed to parse YAML: {exc}"))
            continue

        uses_values: list[str] = []
        collect_uses(data, uses_values)

        for uses in uses_values:
            result = check_uses(uses)
            if result:
                missing_digest_actions += 1
                severity, message = result
                if severity == "warning":
                    warnings.append((str(file), message))
                else:
                    errors.append((str(file), message))
            else:
                ok_actions += 1

    print(f"Checked {len(workflow_files)} workflow file(s).")

    if warnings:
        print("Warnings:\n")
        for file, warning in warnings:
            print(f"::warning file={file}::{warning}")
            print(f"- {file}: {warning}")

    if errors:
        if WARNING_MODE:
            print("Policy violations found (warning mode):\n")
            for file, error in errors:
                print(f"::warning file={file}::{error}")
                print(f"- {file}: {error}")
            print_summary(len(workflow_files), ok_actions, missing_digest_actions)
            return 0

        print("Policy violations found:\n")
        for file, error in errors:
            print(f"::error file={file}::{error}")
            print(f"- {file}: {error}")
        print_summary(len(workflow_files), ok_actions, missing_digest_actions)
        return 1

    if not warnings:
        print("All workflows comply with action pinning policy.")

    print_summary(len(workflow_files), ok_actions, missing_digest_actions)
    
    return 0

if __name__ == "__main__":
    sys.exit(main())