# Hermes Agent Termux Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Hermes Agent to the existing Termux one-shot stack without duplicating Hermes' own Termux dependency management, and verify it in the final diagnostics.

**Architecture:** The bootstrap remains the orchestrator. It installs Termux prerequisites and the Node/MCP/9Router/Pi stack, then invokes Hermes' official Termux-aware installer and verifies the resulting `hermes` command. Hermes keeps its own Python/venv state. The doctor gains a Hermes section and the README/agent guide document the combined stack.

**Tech Stack:** Bash, Termux `pkg`, Git, Node.js/npm, 9Router, Pi Coding Agent, Pi extension, Hermes Agent, Termux:API.

## Global Constraints

- Use the official Hermes installer URL: `https://hermes-agent.nousresearch.com/install.sh`.
- Do not duplicate Hermes' Python virtualenv or `.[termux]` dependency logic.
- Preserve `curl | bash` interactive stdin safety via `/dev/tty`.
- Use `pkg -y` for package confirmations.
- Keep secrets out of verbose traces.
- Do not claim Android/Termux end-to-end validation without a real Android run.

---

### Task 1: Add Hermes installation to the bootstrap

**Files:**
- Modify: `scripts/bootstrap-ai-agent.sh`

**Interfaces:**
- Consumes: existing `VERBOSE`, `CURRENT_STEP`, `cmd`, `fail`, `ok`, and `exists` helpers.
- Produces: installed `hermes` executable and a clear bootstrap failure if official installation fails.

- [ ] **Step 1: Add a dedicated Hermes installation phase after the Node/MCP stack is ready.**
- [ ] **Step 2: Download/run the official Hermes installer with the same TTY-safe execution model.**
- [ ] **Step 3: Verify `command -v hermes` and print `hermes --version` or equivalent without treating version output as a required API contract.**
- [ ] **Step 4: Run `hermes doctor` when available and surface its output; fail the bootstrap if the command returns failure.**
- [ ] **Step 5: Keep the Hermes phase visible in normal and verbose output and never print API-key values.**
- [ ] **Step 6: Run shell syntax validation with `bash -n scripts/bootstrap-ai-agent.sh`.**
- [ ] **Step 7: Commit the bootstrap change.**

### Task 2: Extend the doctor

**Files:**
- Modify: `scripts/doctor.sh`

**Interfaces:**
- Consumes: installed `hermes` command and optional Hermes diagnostics.
- Produces: PASS/WARN/FAIL Hermes status.

- [ ] **Step 1: Add a `HERMES AGENT` section after the Pi section.**
- [ ] **Step 2: Check for `hermes` in PATH.**
- [ ] **Step 3: Report Hermes version when available.**
- [ ] **Step 4: Run `hermes doctor` with bounded output and classify failures as FAIL, while preserving actionable output.**
- [ ] **Step 5: Run `bash -n scripts/doctor.sh`.**
- [ ] **Step 6: Commit the doctor change.**

### Task 3: Document the combined stack

**Files:**
- Modify: `README.md`
- Modify: `docs/AGENT_BOOTSTRAP.md`
- Modify: `docs/TERMUX_SCRIPTING.md` if present and relevant

**Interfaces:**
- Documents: one-shot installation, Hermes role, model configuration, verification, and Android capability boundaries.

- [ ] **Step 1: Add Hermes to the stack diagram and installation checklist.**
- [ ] **Step 2: Explain that Hermes owns its Python environment and that the project intentionally delegates Hermes-specific dependencies to the official installer.**
- [ ] **Step 3: Add Hermes verification commands and troubleshooting guidance.**
- [ ] **Step 4: Explain that free-model availability is dynamic and must be selected from live configured providers rather than hard-coded.**
- [ ] **Step 5: Clarify that Termux:API/Android permissions are independent of Hermes.**
- [ ] **Step 6: Commit documentation changes.**

### Task 4: Final verification

**Files:**
- Test: `scripts/bootstrap-ai-agent.sh`, `scripts/doctor.sh`

- [ ] **Step 1: Run `bash -n scripts/bootstrap-ai-agent.sh scripts/doctor.sh`.**
- [ ] **Step 2: Run the doctor in the current environment if available.**
- [ ] **Step 3: On a real fresh Termux installation, run the one-shot installer and capture raw output.**
- [ ] **Step 4: Verify Git, Node, Termux:API, MCP dependencies, 9Router, Pi, `pi-9router-ext`, Hermes, and `/v1/models`.**
- [ ] **Step 5: Run the final doctor and require no FAIL results.**
- [ ] **Step 6: Record any environment-specific warnings instead of claiming unsupported capabilities are tested.**
