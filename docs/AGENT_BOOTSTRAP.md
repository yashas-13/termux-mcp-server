# ⚡ AI Agent Bootstrap — Termux + MCP + 9Router + Pi

This is the **zero-to-agent** path for a fresh Termux environment.

The goal is one setup flow that leaves you with **Git + Node.js + Termux:API + 9Router + Pi Coding Agent + `pi-9router-ext` + Termux MCP Server**.

## 🚀 What the one-shot setup does

The bootstrap performs the complete local setup:

1. Updates and upgrades Termux.
2. Installs **Git**, **Node.js**, **curl**, and **Termux:API**.
3. Clones `termux-mcp-server` or fast-forwards an existing checkout.
4. Installs the latest **9Router** from npm.
5. Installs the current **Pi Coding Agent**.
6. Installs **`pi-9router-ext`** into Pi.
7. Persists `NINE_ROUTER_BASE_URL` and `NINE_ROUTER_API_KEY` in `~/.profile`.
8. Installs the MCP server's npm dependencies.
9. Starts **`9router --tray`** in the background.
10. Checks the local `/v1/models` endpoint.
11. Leaves Pi ready to discover 9Router models.

Pi's current npm package is `@earendil-works/pi-coding-agent`; Pi extensions are installed with `pi install npm:<package>`, and `pi-9router-ext` is installed with `pi install npm:pi-9router-ext`. citeturn0search0turn1search0

## 📱 Prerequisites

Install these Android applications first:

1. **Termux**
2. **Termux:API**

The bootstrap installs the Termux-side `termux-api` package, but it cannot install the Android APKs for you.

## 🟢 One-shot installation

From Termux, paste this **single command**:

```bash
git clone https://github.com/yashas-13/termux-mcp-server.git "$HOME/termux-mcp-server" 2>/dev/null || git -C "$HOME/termux-mcp-server" pull --ff-only && cd "$HOME/termux-mcp-server" && bash scripts/bootstrap-ai-agent.sh
```

The bootstrap script then performs the complete setup, including **9Router installation + `9router --tray` startup, Pi installation, `pi-9router-ext`, environment configuration, and MCP `npm install`**.

### 🧠 What happens

```text
Fresh Termux
    │
    ├── Git
    ├── Node.js
    ├── curl
    ├── Termux:API
    │
    ▼
termux-mcp-server
    │
    ├── npm install
    │
    ├── 9Router latest
    │      └── 9router --tray
    │
    └── Pi Coding Agent
           └── pi-9router-ext
                    │
                    ▼
              FREE MODEL PICKER
                    │
                    ▼
              AI CODING AGENT
                    │
                    ▼
             TERMUX MCP TOOLS
                    │
                    ▼
                 ANDROID
```

## 🧠 Start enjoying it

After the one-shot setup:

```bash
source ~/.profile
cd ~/termux-mcp-server
pi
```

Inside Pi:

```text
/9router-status
/9router-config
/9router-models
```

The extension discovers available 9Router models dynamically and exposes them under the `9router/` provider namespace. citeturn1search0

### 🆓 Pick a free model

Open the local 9Router dashboard:

```text
http://localhost:20128
```

Connect a **free provider currently available in your 9Router installation**. 9Router's current npm documentation advertises free-provider options such as **Kiro AI** and **OpenCode Free**, but provider availability can change, so use the dashboard's live provider/model list rather than hard-coding a model name. citeturn0search5

Then in Pi:

```text
/9router-models
```

Choose a model, or select it directly:

```text
/model 9router/<model-id>
```

Now start building. 🚀

Try:

```text
Inspect this repository, understand the architecture, and improve it.
```

or:

```text
Build a small tool that checks my Termux environment and explain every failure.
```

Once the Termux MCP server is connected to your MCP-capable agent, you can combine **coding-agent reasoning + Android capabilities** in the same workflow.

## 🔧 Configuration

Defaults:

```bash
NINE_ROUTER_BASE_URL=http://localhost:20128
NINE_ROUTER_API_KEY=sk_9router
```

`sk_9router` is only a documented local placeholder. If your router requires another key, override it:

```bash
NINE_ROUTER_API_KEY=YOUR_LOCAL_KEY bash scripts/bootstrap-ai-agent.sh
```

Do not commit real credentials or put them into public documentation, screenshots, issues, or logs.

## 🔎 Verify the complete stack

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

Check the router:

```bash
pgrep -af 9router
cat ~/.9router.pid 2>/dev/null || true
tail -n 50 ~/.9router.log
```

## 🧩 Stack reference

| Component | Role |
|---|---|
| Git | Clone/update projects |
| Node.js | Runtime for the stack |
| Termux:API | Android capability bridge |
| 9Router | Local AI routing/proxy |
| Pi Coding Agent | Terminal coding-agent harness |
| `pi-9router-ext` | Dynamic 9Router provider/model integration for Pi |
| Termux MCP Server | Android capabilities exposed through MCP |

## 🤖 Give this to another AI agent

```text
Set up the complete Termux AI stack end-to-end: verify Termux + Termux:API are installed, clone or update https://github.com/yashas-13/termux-mcp-server, install Git/Node.js/curl/termux-api, install 9router@latest, start it with `9router --tray` on localhost:20128, install Pi Coding Agent with `npm install -g --ignore-scripts @earendil-works/pi-coding-agent`, install `pi-9router-ext` with `pi install npm:pi-9router-ext`, configure `NINE_ROUTER_BASE_URL=http://localhost:20128` and the user's local `NINE_ROUTER_API_KEY`, run `npm install` in the MCP repository, verify `/v1/models`, launch Pi, run `/9router-config` and `/9router-models`, help the user connect an available free 9Router provider and select a discovered `9router/<model-id>`, then verify the Termux MCP tools; keep credentials private, keep the router local, and test read-only capabilities before side-effecting tools.
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

- Keep 9Router bound to localhost unless you intentionally configure authenticated remote access.
- Never commit API keys.
- Never paste real credentials into README files, issues or screenshots.
- Review third-party Pi packages before installation; Pi packages can execute code and influence agent behavior. citeturn0search0
- Do not blindly allow an agent to send SMS, access contacts/location/camera/clipboard or perform other external side effects.

---

**Install once → connect a free route → choose a model → start building.** 🤖⚡
