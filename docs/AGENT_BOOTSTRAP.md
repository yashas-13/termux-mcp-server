# ⚡ AI Agent Bootstrap — Termux + MCP + 9Router + Pi

This is the **zero-to-agent** path for a fresh Termux environment.

The goal is one interactive setup flow that leaves you with **Git + Node.js + Termux:API + 9Router + Pi Coding Agent + `pi-9router-ext` + Termux MCP Server**, then guides you to connect a free route and choose a model.

## 🚀 One-command interactive installation

Install these Android applications first:

1. **Termux**
2. **Termux:API**

Then paste this command into Termux:

```bash
curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash
```

The script is interactive. It asks before proceeding, lets you confirm the 9Router URL, securely prompts for the local API key, and asks whether to launch Pi at the end.

### What the pipeline does

```text
curl
  │
  ▼
interactive bootstrap
  │
  ├── update/upgrade Termux
  ├── install Git + Node.js + curl + Termux:API
  ├── clone OR fast-forward termux-mcp-server
  ├── install 9Router latest
  ├── install Pi Coding Agent
  ├── install pi-9router-ext
  ├── configure NINE_ROUTER_BASE_URL
  ├── configure NINE_ROUTER_API_KEY
  ├── npm install (MCP server)
  ├── start 9router --tray
  ├── verify /v1/models
  └── show live model IDs
             │
             ▼
        source ~/.profile
             │
             ▼
             pi
             │
             ├── /9router-config
             ├── /9router-reload
             └── /9router-models
                     │
                     ▼
             choose a FREE model
                     │
                     ▼
                 start coding
```

> **Why `curl | bash`?** This is intentionally a convenience installer for a repository you trust. For high-security environments, inspect the script first at [`scripts/bootstrap-ai-agent.sh`](../scripts/bootstrap-ai-agent.sh) and execute it locally instead.

## 📦 What gets installed

| Component | Role |
|---|---|
| Git | Clone/update projects |
| Node.js | Runtime for the stack |
| curl | Health checks and model discovery |
| Termux:API | Android capability bridge |
| 9Router latest | Local AI routing/proxy |
| Pi Coding Agent | Terminal coding-agent harness |
| `pi-9router-ext` | Dynamic 9Router provider/model integration for Pi |
| Termux MCP Server | Android capabilities exposed through MCP |

Pi's current npm package is `@earendil-works/pi-coding-agent`; Pi's official documentation currently lists Node.js `>=22.19.0` and the npm installation form `npm install -g --ignore-scripts @earendil-works/pi-coding-agent`. Pi extensions use `pi install npm:<package>`, and `pi-9router-ext` uses `pi install npm:pi-9router-ext`. citeturn0search0turn0search1

## 📱 Android prerequisites

The shell cannot install Android APKs, so install **Termux** and **Termux:API** before running the bootstrap. Pi's Termux guide also lists these as prerequisites. citeturn0search8

The bootstrap installs the Termux-side `termux-api` package.

## 🧠 After installation: connect a free model

When the installer finishes, it prints the exact next commands. You can also run:

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

`pi-9router-ext` dynamically discovers models from 9Router and exposes them through the `9router` provider. citeturn1search0

### 🆓 Choose any free model available to you

Open the local dashboard:

```text
http://localhost:20128
```

Connect a free provider available in **your live 9Router installation**. Provider availability changes over time, so the installer intentionally does **not hard-code a supposedly free model**.

Then in Pi:

```text
/9router-models
```

Select the model you want.

Or directly:

```text
/model 9router/<model-id>
```

The extension also supports interactive configuration and model discovery through `/9router-config` and `/9router-reload`. citeturn1search0

### 🎉 You're ready

At this point your workflow is:

```text
FREE MODEL
    ↓
Pi Coding Agent
    ↓
9Router
    ↓
Your selected provider
    ↓
AI response / coding
    ↓
Termux
    ↓
Termux MCP
    ↓
Android capabilities
```

Try:

```text
Inspect this repository, understand the architecture, find the biggest engineering issue, and propose a production-grade fix.
```

Then, once your MCP client is configured to launch `termux-mcp-server/index.js`, you can combine coding-agent reasoning with Android capabilities.

## 🔎 Verify everything

```bash
command -v git
node --version
command -v termux-battery-status
command -v 9router
command -v pi
pi --version
pi list
curl -fsS http://localhost:20128/v1/models
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

## 🔧 Configuration

Defaults:

```bash
NINE_ROUTER_BASE_URL=http://localhost:20128
NINE_ROUTER_API_KEY=sk_9router
```

`sk_9router` is only a documented local placeholder. If your 9Router instance requires another key, enter it during the installer prompt or run:

```bash
NINE_ROUTER_API_KEY=YOUR_LOCAL_KEY bash scripts/bootstrap-ai-agent.sh
```

Never commit real credentials or put them into public documentation, screenshots, issues, shell history, or logs.

## 🤖 Give this to another AI agent

```text
Set up the complete Termux AI stack end-to-end: verify Termux + Termux:API are installed, run the interactive bootstrap from https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh, install Git/Node.js/curl/termux-api, clone or update termux-mcp-server, install 9router@latest and start `9router --tray`, install Pi Coding Agent and `pi-9router-ext`, configure NINE_ROUTER_BASE_URL and the user's local NINE_ROUTER_API_KEY, install the MCP dependencies, verify `/v1/models`, show the user the live model list, launch Pi, run `/9router-config` and `/9router-models`, guide the user to connect any currently available free provider and select a discovered `9router/<model-id>`, then verify the Termux MCP tools; keep credentials private, keep 9Router local, and test read-only capabilities before side-effecting tools.
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

Remove global packages if you want a full uninstall:

```bash
npm uninstall -g 9router @earendil-works/pi-coding-agent
```

Remove the Pi extension:

```bash
pi uninstall npm:pi-9router-ext
```

## 🔐 Security

This stack combines a coding agent, a model router and Android device capabilities. Treat it as a privileged local development environment.

- Keep 9Router local unless you intentionally configure authenticated remote access.
- Never commit API keys.
- Never paste real credentials into README files, issues or screenshots.
- Review third-party Pi packages before installation; Pi packages can execute code and influence agent behavior. citeturn0search0
- Do not blindly allow an agent to send SMS, access contacts/location/camera/clipboard or perform other external side effects.

---

**One command → guided setup → connect a free route → choose a model → start building.** 🤖⚡
