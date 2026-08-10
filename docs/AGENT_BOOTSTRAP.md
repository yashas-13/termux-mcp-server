# ⚡ AI Agent Bootstrap — Termux + 9Router + Pi

This guide turns a fresh Termux environment into a local AI-agent workspace with:

- Git
- Node.js
- Termux:API
- 9Router
- Pi's `pi-9router-ext`
- persistent `NINE_ROUTER_BASE_URL` / `NINE_ROUTER_API_KEY` environment variables
- background 9Router startup

## 🟢 One-line installation

Run this from Termux:

```bash
pkg update -y && pkg upgrade -y && pkg install -y git nodejs termux-api && npm config set allow-scripts=9router --location=user && npm install -g 9router@latest && command -v pi >/dev/null 2>&1 && pi install npm:pi-9router-ext || true && printf '\nexport NINE_ROUTER_BASE_URL=http://localhost:20128\nexport NINE_ROUTER_API_KEY=sk_9router\n' >> ~/.profile && export NINE_ROUTER_BASE_URL=http://localhost:20128 NINE_ROUTER_API_KEY=sk_9router && nohup 9router > ~/.9router.log 2>&1 &
```

> **Note:** the `pi` extension portion runs only when `pi` is already installed. If `pi` is not installed, install your preferred Pi coding-agent package first and then run `pi install npm:pi-9router-ext`.

## 🧠 Recommended idempotent installer

For repeated setup, use the repository script instead of appending exports manually:

```bash
bash scripts/bootstrap-ai-agent.sh
```

Or from the repository root after cloning:

```bash
git clone https://github.com/yashas-13/termux-mcp-server.git && cd termux-mcp-server && bash scripts/bootstrap-ai-agent.sh
```

The script is designed to be rerunnable and writes the managed environment values to `~/.profile`.

## 🔧 Environment

Default local values:

```bash
export NINE_ROUTER_BASE_URL=http://localhost:20128
export NINE_ROUTER_API_KEY=sk_9router
```

If your 9Router instance uses different values, override them before running the script:

```bash
NINE_ROUTER_BASE_URL=http://localhost:20128 NINE_ROUTER_API_KEY=YOUR_LOCAL_KEY bash scripts/bootstrap-ai-agent.sh
```

Do **not** commit real API keys to Git. `sk_9router` should be treated as a local placeholder unless your local 9Router installation explicitly uses it.

## 🔍 Verify

```bash
source ~/.profile
printf '%s\n' "$NINE_ROUTER_BASE_URL"
command -v 9router
9router --help
command -v pi
```

Inspect the router log:

```bash
tail -f ~/.9router.log
```

Then start Pi:

```bash
pi
```

Inside Pi, configure/use the 9Router extension as appropriate for your local installation.

## 🧹 Clean up / reset

Stop the background instance recorded by the bootstrap script:

```bash
[ -f ~/.9router.pid ] && kill "$(cat ~/.9router.pid)" 2>/dev/null || true
```

Remove the managed environment entries from `~/.profile` if required:

```bash
sed -i '/^export NINE_ROUTER_BASE_URL=/d;/^export NINE_ROUTER_API_KEY=/d' ~/.profile
```

## ⚠️ Security

Keep 9Router bound to localhost unless you intentionally configure authenticated remote access. Never publish a real API key in README files, shell history, Git commits, screenshots, issues, or public logs.
