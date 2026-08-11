# Hermes Agent Termux Integration Design

## Goal
Extend the one-shot Termux AI stack installer to optionally install Hermes Agent using its official Termux-aware installer, while keeping Hermes' Python environment isolated from the Node/MCP/9Router/Pi stack.

## Architecture

The repository remains the orchestrator for the local stack:

```text
Termux
├── Termux:API
├── termux-mcp-server (Node/MCP)
├── 9Router (Node)
├── Pi Coding Agent (Node)
│   └── pi-9router-ext
└── Hermes Agent (Python, isolated by Hermes installer)
```

The bootstrap script installs prerequisites, syncs the repository, installs Node components, invokes the official Hermes installer, verifies Hermes, then runs the existing doctor. It must not duplicate Hermes' dependency/venv logic because Hermes maintains its own Termux-specific installation path.

## Requirements

- Detect that execution is inside Termux before changing the system.
- Keep the existing `curl | bash` interactive stdin fix.
- Use native `pkg -y` rather than piping `yes` into package managers.
- Keep Node.js/MCP dependencies separate from Hermes' Python environment.
- Use Hermes' official installer URL rather than cloning or reimplementing its installer.
- Treat Hermes installation failure as a clear bootstrap failure when Hermes is enabled.
- Verify `hermes` is in PATH after installation.
- Run `hermes doctor` when available; do not fabricate success if the command fails.
- Do not expose credentials in verbose output.
- Preserve rerunnable Git sync and final doctor diagnostics.
- Document that Android/Termux capabilities requiring Termux:API remain separate from Hermes' own runtime.

## Installation Flow

```text
preflight
  ↓
Termux packages
  ↓
Git sync
  ↓
9Router
  ↓
Pi + extension
  ↓
MCP npm install
  ↓
official Hermes installer
  ↓
Hermes verification/doctor
  ↓
9Router health check
  ↓
full stack doctor
```

## Error Handling

Every major phase sets a named step. `set -Eeuo pipefail` remains enabled. The ERR trap reports the line, command, and current step. Hermes logs/output remain visible so a user can diagnose Python/build failures. The bootstrap must not swallow Hermes errors with `|| true`.

## Testing

The implementation should support:

1. Fresh Termux installation with Termux:API already installed and permissions granted.
2. Rerun on an already-configured system.
3. Existing Git checkout that can fast-forward cleanly.
4. Hermes already installed.
5. Hermes installation failure with a useful error.
6. Final `scripts/doctor.sh` verification.

A real Android/Termux run is required before claiming full end-to-end validation; a Linux container cannot prove Termux:API or Android permission behavior.
