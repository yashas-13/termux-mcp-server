# ⚡ AI Agent Bootstrap — Termux + 9Router + Pi

This guide turns a fresh Termux environment into a local AI-agent workspace with **Git + Node.js + Termux:API + 9Router + Pi Coding Agent + Pi's 9Router extension**.

## 🚀 True one-shot installation

Install the required Android apps first:

1. Termux
2. Termux:API

Then paste this **single command** into Termux:

```bash
pkg update -y && pkg upgrade -y && pkg install -y git nodejs termux-api && npm config set allow-scripts=9router --location=user && npm install -g 9router@latest && npm install -g --ignore-scripts @earendil-works/pi-coding-agent && pi install npm:pi-9router-ext && mkdir -p ~/.config/termux-mcp && printf 'export NINE_ROUTER_BASE_URL=http://localhost:20128\nexport NINE_ROUTER_API_KEY=sk_9router\n' >> ~/.profile && export NINE_ROUTER_BASE_URL=http://localhost:20128 NINE_ROUTER_API_KEY=sk_9router && nohup 9router > ~/.9router.log 2>&1 &
```

### What that one line does

```text
Termux
  │
  ├── update / upgrade packages
  ├── install Git
  ├── install Node.js
  ├── install Termux:API CLI
  │
  ├── install 9Router
  │
  ├── install Pi Coding Agent
  │
  ├── install pi-9router-ext
  │
  ├── configure NINE_ROUTER_BASE_URL
  ├── configure NINE_ROUTER_API_KEY
  │
  └── start 9Router in background
          │
          ▼
      localhost:20128
```

Pi's documented npm package is `@earendil-works/pi-coding-agent`, and Pi extensions are installed with `pi install npm:<package>`. The `pi-9router-ext` package is installed with `pi install npm:pi-9router-ext`. citeturn0search1turn0search0

## 🧠 Recommended rerunnable installer

For a repeatable/idempotent setup, clone this repository and run:

```bash
git clone https://github.com/yashas-13/termux-mcp-server.git && cd termux-mcp-server && bash scripts/bootstrap-ai-agent.sh
```

The repository script installs **Pi itself**, not merely the extension, then installs 9Router and `pi-9router-ext`, writes managed router variables to `~/.profile`, and starts 9Router in the background. fileciteturn29file0

## 🔧 Defaults

```bash
NINE_ROUTER_BASE_URL=http://localhost:20128
NINE_ROUTER_API_KEY=sk_9router
```

The API key shown above is a **placeholder/default for this documented local setup**. If your 9Router dashboard generates a different key, use that value instead.

Override before running the installer:

```bash
NINE_ROUTER_BASE_URL=http://localhost:20128 NINE_ROUTER_API_KEY=YOUR_LOCAL_KEY bash scripts/bootstrap-ai-agent.sh
```

## 🔌 Configure Pi

After installation:

```bash
source ~/.profile
pi
```

Inside Pi, configure the extension with:

```text
/9router-config
```

The extension package itself documents this configuration flow. citeturn0search0

## 🔍 Verify the complete stack

```bash
command -v git
node --version
command -v termux-battery-status
command -v 9router
9router --help
command -v pi
pi --version
```

Verify Termux:API:

```bash
termux-battery-status
termux-clipboard-get
```

Verify the router process:

```bash
pgrep -af 9router
cat ~/.9router.pid 2>/dev/null || true
tail -n 50 ~/.9router.log
```

Then launch:

```bash
pi
```

## 🧩 What is installed?

| Component | Purpose |
|---|---|
| Git | Clone/update projects |
| Node.js | Runtime for MCP, Pi and 9Router |
| Termux:API | Android device capability bridge |
| 9Router | Local AI routing/proxy layer |
| Pi Coding Agent | Terminal coding-agent runtime |
| `pi-9router-ext` | Connects Pi to 9Router |
| Termux MCP Server | Exposes Android capabilities through MCP |

9Router's npm package supports local startup with `9router` and defaults to port `20128`; its dashboard is exposed locally at the router endpoint. citeturn0search2

## 🤖 AI-agent one-liner

Give this to another coding agent:

```text
Set up the Termux AI stack end-to-end: verify Termux + Termux:API, install Git/Node.js/termux-api, install 9router@latest, install Pi Coding Agent with `npm install -g --ignore-scripts @earendil-works/pi-coding-agent`, install `pi-9router-ext` with `pi install npm:pi-9router-ext`, configure `NINE_ROUTER_BASE_URL=http://localhost:20128` and the user's local `NINE_ROUTER_API_KEY`, start 9Router, launch Pi, run `/9router-config`, verify the router and Pi, then integrate `yashas-13/termux-mcp-server` as the local MCP server; do not expose credentials or the router publicly and test read-only Android capabilities before enabling side-effecting tools.
```

## 🧹 Stop / reset

Stop the instance created by the bootstrap script:

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

Pi can remove its installed extension using its package-management commands; inspect installed packages with `pi list` before removing anything. citeturn0search1turn0search7

## ⚠️ Security

This stack combines a coding agent, a model router and Android device capabilities. Treat it as a privileged local development environment.

- Keep 9Router bound to localhost unless you intentionally configure authenticated remote access.
- Never commit API keys.
- Never paste real credentials into README files, issues or screenshots.
- Review third-party Pi extensions before installation; Pi packages can execute code and influence agent behavior. citeturn0search0
- Do not blindly allow an agent to send SMS, access contacts/location/camera/clipboard or perform other external side effects.
