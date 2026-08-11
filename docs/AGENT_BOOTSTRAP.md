# ⚡ AI Agent Bootstrap — Termux + MCP + 9Router + Pi

This is the **zero-to-agent** path for a fresh Termux environment.

The bootstrap installs the focused stack:

**Termux + Termux:API + Git + Node.js + 9Router + Pi Coding Agent + `pi-9router-ext` + Termux MCP Server**.

> **Hermes is intentionally not installed by this bootstrap for now.** This keeps the installation focused and avoids the current Termux/Python compatibility issue in the Hermes dependency chain.

## 🚀 One-command installation

Install these Android applications first:

1. **Termux**
2. **Termux:API**

Then run:

```bash
curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash
```

For full shell tracing:

```bash
curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash -s -- --verbose
```

For maximum visibility and easier debugging, clone first:

```bash
git clone --progress --branch main https://github.com/yashas-13/termux-mcp-server.git ~/termux-mcp-server-install && cd ~/termux-mcp-server-install && bash scripts/bootstrap-ai-agent.sh
```

The installer uses native `pkg -y`/npm automation where safe, keeps required user prompts on `/dev/tty`, shows each installation stage, verifies the installed tools, starts 9Router, checks `/v1/models`, runs the repository doctor and prints the model-selection workflow.

## 🧬 Installation pipeline

```text
Termux + Termux:API
        │
        ▼
Git + Node.js + curl + tmux + ripgrep
        │
        ▼
termux-mcp-server
        │
        ├──────────────┐
        ▼              ▼
    9Router          Pi Agent
        │              │
        │        pi-9router-ext
        │              │
        └───────┬──────┘
                ▼
        Live model discovery
                │
                ▼
        /9router-models
                │
                ▼
        Choose available model
                │
                ▼
             Start coding
                │
                ▼
          Termux MCP tools
                │
                ▼
             Android
```

## 📦 Components

| Component | Purpose |
|---|---|
| Git | Clone/update the repository |
| Node.js 22+ | Runtime for the MCP server, 9Router and Pi |
| Termux:API | Android capability bridge |
| 9Router | Local model/provider routing |
| Pi Coding Agent | Terminal coding-agent interface |
| `pi-9router-ext` | Exposes 9Router models to Pi |
| Termux MCP Server | Exposes supported Termux/Android capabilities through MCP |
| tmux | Optional multi-terminal/session management |
| ripgrep | Fast project search |

## 🧠 Why Hermes is not installed

Hermes is intentionally **out of the default bootstrap for now**.

The current Termux package environment can provide Python 3.14 while Hermes currently requires a Python version below 3.14. Installing Hermes during the core bootstrap can therefore stop an otherwise healthy Pi + 9Router + MCP installation.

The project will keep Hermes as an optional integration rather than making it a prerequisite.

## 🚀 After installation: start Pi

```bash
source ~/.profile
pi
```

The installer also prints these commands at completion.

### 1. Configure 9Router

Inside Pi:

```text
/9router-config
```

Use this when the router/provider configuration needs to be changed.

### 2. Refresh the model catalogue

```text
/9router-reload
```

Run this after changing providers or when you want the current model list.

### 3. Open the model selector

```text
/9router-models
```

This is the important command for choosing the model that Pi will use through 9Router.

The list is **live**. Do not rely on a model name shown in an old screenshot or README because provider availability, routing and free quotas can change.

### 4. Select a free model

From `/9router-models`, look for a currently available route/model from the providers configured in your 9Router instance.

For example, if your live catalogue exposes an OpenCode route such as **Big Pickle**, select that entry.

If your live catalogue exposes a **DeepSeek** free route/model, select the DeepSeek entry.

The exact model ID is intentionally not hard-coded here because the live 9Router catalogue is authoritative.

### 5. Direct model selection

Once `/9router-models` shows the exact ID, you can select it directly with:

```text
/model 9router/<model-id>
```

For example, conceptually:

```text
/model 9router/<live-opencode-big-pickle-id>
```

or:

```text
/model 9router/<live-deepseek-id>
```

**Replace the placeholder with the exact ID displayed by `/9router-models`.**

### 6. Verify the active model

```text
/model
```

This lets you confirm which model Pi is currently using.

## 🆓 Recommended free-model workflow

Use this sequence whenever you want to find a free model:

```text
/9router-config
        ↓
/9router-reload
        ↓
/9router-models
        ↓
Find a currently available free route
        ↓
Select it
        ↓
/model
        ↓
Start coding
```

### Example: OpenCode / Big Pickle

If the current 9Router catalogue contains an OpenCode **Big Pickle** route:

```text
/9router-reload
/9router-models
```

Select the Big Pickle entry shown by the live selector.

Do **not** copy a guessed model ID from documentation; use the exact ID returned by your installed router.

### Example: DeepSeek

If your configured providers expose a free DeepSeek route:

```text
/9router-reload
/9router-models
```

Select the DeepSeek entry shown by the live selector.

Again, use the exact live model ID rather than assuming a static identifier.

## 🔎 Verify the installation

Run:

```bash
command -v git
command -v node
command -v npm
command -v 9router
command -v pi
command -v termux-battery-status
node --version
npm --version
pi --version
9router --version
```

Check the router:

```bash
curl -fsS http://127.0.0.1:20128/v1/models
```

Check Termux:API:

```bash
termux-battery-status
termux-clipboard-get
termux-wifi-connectioninfo
```

Check 9Router:

```bash
pgrep -af 9router
tail -n 50 ~/.9router.log
```

Run the project doctor:

```bash
bash ~/termux-mcp-server/scripts/doctor.sh
```

## 🔧 Configuration

Default local router settings:

```bash
NINE_ROUTER_BASE_URL=http://127.0.0.1:20128
NINE_ROUTER_API_KEY=sk_9router
```

The API key is a local placeholder and should be replaced when your 9Router configuration requires another key.

Never commit real credentials.

## 🤖 Give this to another AI coding agent

```text
Use this repository's Termux bootstrap to install and configure Git, Node.js, Termux:API, 9Router, Pi Coding Agent, pi-9router-ext and the Termux MCP server. Do not install Hermes. After installation, start Pi, run /9router-config if needed, run /9router-reload, open /9router-models, inspect the live catalogue, select a currently available free model such as an OpenCode/Big Pickle route or a DeepSeek free route if present, then verify it with /model. Never guess a model ID: use the exact ID returned by /9router-models. Keep 9Router local and never expose API keys.
```

## 🧹 Reset

Stop 9Router:

```bash
[ -f ~/.9router.pid ] && kill "$(cat ~/.9router.pid)" 2>/dev/null || true
```

Remove router variables:

```bash
sed -i '/^export NINE_ROUTER_BASE_URL=/d;/^export NINE_ROUTER_API_KEY=/d' ~/.profile
```

Remove global Node packages:

```bash
npm uninstall -g 9router @earendil-works/pi-coding-agent
```

Remove the Pi extension:

```bash
pi uninstall npm:pi-9router-ext
```

## 🔐 Security

This stack combines an AI coding agent, model routing and Android capabilities.

- Keep 9Router bound to localhost unless remote access is deliberately configured.
- Never commit API keys.
- Review third-party Pi extensions before installing them.
- Treat SMS, contacts, location, camera, clipboard and other side-effecting capabilities as privileged operations.
- Prefer read-only capabilities while validating an agent integration.
- Do not expose the MCP server or local router directly to the public internet.

---

**One setup → live model discovery → choose a free route → Pi starts coding → MCP gives the agent Android capabilities.** 🤖📱⚡
