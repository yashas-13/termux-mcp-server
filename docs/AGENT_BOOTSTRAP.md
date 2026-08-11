# ⚡ AI Agent Bootstrap — Termux + MCP + 9Router + Pi + Hermes

This is the **zero-to-agent** path for a fresh Termux environment.

The goal is one interactive setup flow that leaves you with **Git + Node.js + Termux:API + 9Router + Pi Coding Agent + `pi-9router-ext` + Hermes Agent + Termux MCP Server**, then guides you to connect a free route/model and start building.

## 🚀 One-command interactive installation

Install these Android applications first:

1. **Termux**
2. **Termux:API**

Then paste this command into Termux:

```bash
curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash
```

Verbose/raw diagnostics:

```bash
curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash -s -- --verbose
```

The script is interactive. It asks before proceeding, lets you confirm the 9Router URL, securely prompts for the local API key, installs the official Hermes Termux stack, runs `hermes doctor`, verifies 9Router, runs the full repository doctor, and asks whether to launch Pi.

## 🧬 What the pipeline does

```text
curl
  │
  ▼
interactive bootstrap
  │
  ├── update/upgrade Termux
  ├── install Git + Node.js + curl + Termux:API
  ├── install Hermes Termux prerequisites
  ├── clone OR fast-forward termux-mcp-server
  ├── install 9Router latest
  ├── install Pi Coding Agent
  ├── install pi-9router-ext
  ├── npm install (MCP server)
  ├── run official Hermes installer
  ├── verify Hermes + `hermes doctor`
  ├── configure NINE_ROUTER_BASE_URL
  ├── configure NINE_ROUTER_API_KEY
  ├── start `9router --tray`
  ├── verify `/v1/models`
  ├── run full stack doctor
  └── optionally launch Pi
             │
             ▼
        source ~/.profile
             │
             ├── pi
             │    ├── /9router-config
             │    ├── /9router-reload
             │    └── /9router-models
             │
             └── hermes setup
                    │
                    ▼
             choose a model/provider
                    │
                    ▼
                 start building
```

> **Why `curl | bash`?** This is a convenience installer for a repository you trust. For high-security environments, inspect [`scripts/bootstrap-ai-agent.sh`](../scripts/bootstrap-ai-agent.sh) first and run it locally instead.

## 📦 What gets installed

| Component | Role |
|---|---|
| Git | Clone/update projects |
| Node.js 22+ | Runtime for MCP, 9Router and Pi |
| Python | Hermes/Termux tooling |
| Clang/Rust/build tools | Native Python dependencies used by the Hermes Termux path |
| curl | Health checks, downloads and model discovery |
| Termux:API | Android capability bridge |
| 9Router latest | Local AI routing/proxy |
| Pi Coding Agent | Terminal coding-agent harness |
| `pi-9router-ext` | Dynamic 9Router provider/model integration for Pi |
| Hermes Agent | General-purpose autonomous agent runtime |
| Termux MCP Server | Android capabilities exposed through MCP |

### 🧠 Hermes installation boundary

The bootstrap intentionally **does not reimplement Hermes' Python virtual environment or dependency resolver**. It downloads and executes the official Hermes installer:

```text
https://hermes-agent.nousresearch.com/install.sh
```

Hermes' own Termux installation path is responsible for its Python environment and Termux-specific dependencies. This keeps the Node/MCP/9Router/Pi stack separate from Hermes' Python runtime and reduces the chance that one package manager corrupts another environment.

The installer also pre-installs the Termux build dependencies documented by Hermes so the official installer has the native toolchain it expects.

## 📱 Android prerequisites

The shell cannot install Android APKs, so install **Termux** and **Termux:API** before running the bootstrap. The bootstrap installs the Termux-side `termux-api` package.

Grant the Android permissions requested by Termux:API before testing camera, location, contacts, SMS or other protected capabilities.

## 🧠 After installation

### Pi

```bash
source ~/.profile
pi
```

Inside Pi:

```text
/9router-status
/9router-config
/9router-reload
/9router-models
```

### Hermes

```bash
hermes setup
hermes doctor
hermes
```

Use Pi when you want a focused terminal coding-agent workflow. Use Hermes when you want its broader autonomous-agent/runtime features. Both can coexist on the same Termux installation.

## 🆓 Choose a free model

Open the local 9Router dashboard if available:

```text
http://127.0.0.1:20128
```

Connect a free provider available in **your live 9Router installation**. Provider/model availability changes, so this project intentionally does **not hard-code a supposedly free model**.

Then in Pi:

```text
/9router-models
```

Select the model you want, or use:

```text
/model 9router/<model-id>
```

For Hermes, configure the provider/model through its own setup flow:

```bash
hermes setup
```

## 🎉 The combined stack

```text
                    🧠 AI MODELS
                         │
               ┌─────────┴─────────┐
               ▼                   ▼
          🌐 9Router          Direct providers
               │
        ┌──────┴──────┐
        ▼             ▼
   🤖 Pi Agent    🧠 Hermes
        │             │
        └──────┬──────┘
               ▼
        📱 Termux / Android
               │
        ┌──────┴──────┐
        ▼             ▼
   Termux MCP     Termux tools
        │
        ▼
     Android APIs
```

The important separation is:

- **9Router** routes model traffic.
- **Pi** provides a terminal coding-agent workflow.
- **Hermes** provides its own autonomous-agent workflow.
- **Termux MCP** exposes Android capabilities through MCP.
- **Termux:API** bridges commands to Android.

## 🔎 Verify everything

```bash
command -v git
node --version
python --version
command -v termux-battery-status
command -v 9router
command -v pi
command -v hermes
pi --version
hermes doctor
curl -fsS http://127.0.0.1:20128/v1/models
```

Verify Termux:API directly:

```bash
termux-battery-status
termux-clipboard-get
termux-wifi-connectioninfo
```

Check the router process and logs:

```bash
pgrep -af 9router
cat ~/.9router.pid 2>/dev/null || true
tail -n 50 ~/.9router.log
```

Run the full repository diagnostic:

```bash
bash ~/termux-mcp-server/scripts/doctor.sh
```

The doctor now checks **Termux, Termux:API, MCP, 9Router, Pi, `pi-9router-ext`, Hermes and the environment**.

## 🔧 Configuration

Defaults:

```bash
NINE_ROUTER_BASE_URL=http://127.0.0.1:20128
NINE_ROUTER_API_KEY=sk_9router
```

`sk_9router` is only a documented local placeholder. If your local 9Router instance requires another key, enter it during the installer prompt.

Never commit real credentials or put them into public documentation, screenshots, issues, shell history or logs.

## 🤖 Give this to another AI agent

```text
Set up the complete Android AI stack end-to-end: verify Termux + Termux:API are installed, run https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh, install Git/Node.js/curl/termux-api plus the Hermes Termux build prerequisites, clone or update termux-mcp-server, install 9router@latest and start `9router --tray` on localhost:20128, install Pi Coding Agent and `pi-9router-ext`, install the MCP dependencies, invoke the official Hermes installer at https://hermes-agent.nousresearch.com/install.sh without duplicating its Python environment logic, verify `hermes` and run `hermes doctor`, configure NINE_ROUTER_BASE_URL and the user's local NINE_ROUTER_API_KEY, verify `/v1/models`, run the repository doctor, launch Pi, run `/9router-config`, `/9router-reload` and `/9router-models`, guide the user to connect any currently available free provider and select a discovered `9router/<model-id>`, and explain `hermes setup` for Hermes; keep credentials private, keep 9Router local, and test read-only Android capabilities before side-effecting tools.
```

## 🧹 Stop / reset

Stop the bootstrap-managed router:

```bash
[ -f ~/.9router.pid ] && kill "$(cat ~/.9router.pid)" 2>/dev/null || true
```

Remove managed variables:

```bash
sed -i '/^export NINE_ROUTER_BASE_URL=/d;/^export NINE_ROUTER_API_KEY=/d' ~/.profile
```

Remove Node global packages if you want to reset the Node side:

```bash
npm uninstall -g 9router @earendil-works/pi-coding-agent
```

Remove the Pi extension:

```bash
pi uninstall npm:pi-9router-ext
```

For Hermes removal/reset, use the installation and environment guidance provided by Hermes rather than deleting arbitrary Python files from its managed environment.

## 🔐 Security

This stack combines coding agents, a model router and Android device capabilities. Treat it as a privileged local development environment.

- Keep 9Router local unless you intentionally configure authenticated remote access.
- Never commit API keys.
- Never paste real credentials into README files, issues or screenshots.
- Review third-party Pi/Hermes packages before installation; agent packages can execute code and influence agent behavior.
- Do not blindly allow an agent to send SMS, access contacts/location/camera/clipboard or perform other external side effects.
- Test read-only capabilities before enabling external side effects.
- Do not expose the MCP server or local router directly to the public internet.

## ⚠️ Platform boundary

Hermes' Termux path is a best-effort Android environment. Desktop/server-only features may not be available on Android, and Termux:API permissions are independent of Hermes. A successful Hermes installation does not prove that every Android capability exposed by this repository is available.

A real Android/Termux run is required before claiming complete end-to-end validation.

---

**One command → guided setup → Pi + Hermes → connect a model → give AI access to Android capabilities.** 🤖📱⚡
