# ⚡ AI Agent Bootstrap — Termux + 9Router + Pi + MCP

This guide turns a fresh Termux environment into a local AI-agent workspace with **Git + Node.js + Termux:API + 9Router + Pi Coding Agent + Pi's 9Router extension + Termux MCP Server**.

## 🚀 True one-shot installation

Install the required Android apps first:

1. Termux
2. Termux:API

Then paste this **single command** into Termux:

```bash
git clone https://github.com/yashas-13/termux-mcp-server.git "$HOME/termux-mcp-server" 2>/dev/null || git -C "$HOME/termux-mcp-server" pull --ff-only && cd "$HOME/termux-mcp-server" && bash scripts/bootstrap-ai-agent.sh && npm install
```

That single command clones/updates this repository and runs the complete bootstrap: Termux prerequisites, 9Router, Pi Coding Agent, `pi-9router-ext`, router environment, background 9Router, and the MCP server's Node dependencies.

### What happens

```text
Termux
  │
  ├── Git / Node.js / Termux:API
  │
  ├── clone or update termux-mcp-server
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
  ├── start 9Router
  │
  └── npm install (MCP server)
          │
          ▼
      READY FOR AI
```

Pi's documented npm package is `@earendil-works/pi-coding-agent`, and Pi extensions are installed with `pi install npm:<package>`. The `pi-9router-ext` package is installed with `pi install npm:pi-9router-ext`. citeturn0search1turn0search0

## 🧠 Start the complete stack

After the one-shot setup:

```bash
source ~/.profile
cd ~/termux-mcp-server
npm start
```

The MCP server uses stdio, so your MCP client should launch `index.js` locally. Start Pi separately when you want the coding agent:

```bash
pi
```

Inside Pi:

```text
/9router-config
```

## 🔧 Defaults

```bash
NINE_ROUTER_BASE_URL=http://localhost:20128
NINE_ROUTER_API_KEY=sk_9router
```

The API key shown above is a **placeholder/default for this documented local setup**. If your 9Router dashboard generates a different key, use that value instead.

Override before running the bootstrap:

```bash
NINE_ROUTER_BASE_URL=http://localhost:20128 NINE_ROUTER_API_KEY=YOUR_LOCAL_KEY bash scripts/bootstrap-ai-agent.sh
```

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

Verify the router process and logs:

```bash
pgrep -af 9router
cat ~/.9router.pid 2>/dev/null || true
tail -n 50 ~/.9router.log
```

Then launch Pi:

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

## 🤖 Give this to another AI agent

```text
Set up the complete Termux AI stack end-to-end: verify Termux + Termux:API, clone/update https://github.com/yashas-13/termux-mcp-server, install Git/Node.js/termux-api, install 9router@latest, install Pi Coding Agent with `npm install -g --ignore-scripts @earendil-works/pi-coding-agent`, install `pi-9router-ext` with `pi install npm:pi-9router-ext`, configure `NINE_ROUTER_BASE_URL=http://localhost:20128` and the user's local `NINE_ROUTER_API_KEY`, start 9Router, install the MCP server dependencies, launch Pi, run `/9router-config`, configure the MCP client to launch the repository's `index.js`, discover the available Android tools, and verify the complete stack; do not expose credentials or the router publicly and test read-only Android capabilities before enabling side-effecting tools.
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
