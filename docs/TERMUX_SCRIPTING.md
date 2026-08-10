# 🧬 Advanced Termux Scripting Reference

This document records the Termux-native scripting patterns used by this project and explains why the installer/runtime is structured this way.

## 1. Process and stream discipline

Termux commands commonly use stdin/stdout as a programmatic API boundary. Keep these channels separate:

```text
stdin  → command input
stdout → machine-readable result
stderr → diagnostics
```

For interactive installers launched with `curl | bash`, never let `read` consume the downloaded script stream. Read user input explicitly from `/dev/tty`.

Preferred pattern:

```bash
read -r -p 'Continue? [Y/n] ' answer </dev/tty
```

For maximum separation, download first and execute second:

```bash
tmp="$(mktemp)"
curl -fsSL "$URL" -o "$tmp"
bash "$tmp"
rm -f "$tmp"
```

## 2. Termux:API capability adapters

Treat every Android API as a bounded capability:

```text
MCP tool
  ↓
argument/schema validation
  ↓
Termux capability adapter
  ↓
termux-* command
  ↓
Android / Termux:API
```

Do not turn the MCP layer into an unrestricted shell interface.

Examples:

```bash
termux-battery-status
termux-location
termux-camera-photo
termux-sms-send
termux-wifi-connectioninfo
```

## 3. Capability health checks

Checking that a binary exists is not enough.

```bash
command -v termux-battery-status
```

only proves installation. A real diagnostic should execute the API and validate its response:

```bash
termux-battery-status
```

The repository's `scripts/doctor.sh` performs this style of end-to-end check for core Termux, Termux:API, MCP, 9Router and Pi components.

## 4. Background processes

A raw `command &` is acceptable for a short-lived experiment but is not a robust service supervisor.

For persistent Termux workloads, consider **Termux:Boot**, **termux-services/runit**, or Android-aware scheduling rather than building a custom polling loop.

The current bootstrap intentionally uses `9router --tray` plus a PID/log file for simple installation portability. A future service integration should move this into a supervised Termux service.

## 5. Scheduled agent work

Termux provides `termux-job-scheduler` for Android-aware periodic or constrained jobs.

Typical constraints can include network availability and charging/battery state. Use it for scheduled tasks rather than keeping an agent process awake solely to poll.

Example shape:

```bash
termux-job-scheduler \
  --script "$HOME/bin/agent-check.sh" \
  --period-ms 900000 \
  --persisted true
```

Always check the command's help on the target Termux:API version because flags and Android behavior can evolve.

## 6. External app execution

Termux integrations such as Tasker can invoke Termux commands through explicit Android permissions. Treat this as a security boundary.

For this project the equivalent boundary is MCP:

```text
AI request
   ↓
MCP tool
   ↓
policy / permission
   ↓
validated arguments
   ↓
Termux command
```

Never skip policy and argument validation by passing arbitrary AI-generated shell strings to a shell.

## 7. Safe process execution

Prefer argument arrays over shell interpolation.

Conceptually:

```js
execFile('termux-sms-send', ['-n', number, message])
```

rather than:

```js
exec(`termux-sms-send -n ${number} ${message}`)
```

This repository tracks migration toward argument-safe process execution as a security hardening task.

## 8. Android-aware paths

Use Termux environment variables where possible:

```bash
$HOME
$PREFIX
$TMPDIR
```

Termux scripts that are invoked externally should use the Termux interpreter path when appropriate:

```bash
#!/data/data/com.termux/files/usr/bin/bash
```

## 9. Rerunnable installers

Installers should converge toward a desired state rather than assume a pristine machine:

```text
missing → install
present → verify
partial → repair
working → leave intact
```

The bootstrap follows this model for Git, the repository, 9Router, Pi and the MCP dependencies.

## 10. Verbose diagnostics

The installer prints phase boundaries and successful checks by default. For shell-level tracing:

```bash
curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash -s -- --verbose
```

**Never use shell tracing while entering or exporting real credentials.** If debugging a credential-related failure, disable tracing first and inspect only redacted configuration.

## 11. Doctor workflow

Run:

```bash
bash scripts/doctor.sh
```

or directly:

```bash
curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/doctor.sh | bash
```

The doctor checks:

- Termux environment
- architecture
- Git / Node / npm / curl
- Node major version
- Termux:API installation
- battery API
- Wi-Fi API
- clipboard API
- repository state
- MCP dependencies
- 9Router executable/process/API
- live `/v1/models`
- Pi executable/version
- `pi-9router-ext`
- router environment variables

## 12. Recommended production evolution

```text
Current
  bootstrap
      ↓
  9router --tray
      ↓
  doctor

Future
  bootstrap
      ↓
  supervised Termux service
      ↓
  capability registry
      ↓
  policy engine
      ↓
  MCP
      ↓
  Android APIs
```

The goal is an Android-native agent runtime with explicit capability boundaries, health checks, scheduling, service supervision, auditability and safe process execution.
