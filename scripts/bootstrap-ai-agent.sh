#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

# Interactive one-shot bootstrap for Termux MCP Server + 9Router + Pi.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash

REPO_URL="https://github.com/yashas-13/termux-mcp-server.git"
REPO_DIR="${REPO_DIR:-$HOME/termux-mcp-server}"
PI_PACKAGE="@earendil-works/pi-coding-agent"
NINE_ROUTER_BASE_URL="${NINE_ROUTER_BASE_URL:-http://localhost:20128}"
NINE_ROUTER_API_KEY="${NINE_ROUTER_API_KEY:-sk_9router}"

trap 'printf "\n❌ Bootstrap failed at line %s. Check the command above and ~/.9router.log if applicable.\n" "$LINENO" >&2' ERR

say() { printf '\n%s\n' "$*"; }
ok() { printf '  ✅ %s\n' "$*"; }
warn() { printf '  ⚠️  %s\n' "$*"; }
fail() { printf '  ❌ %s\n' "$*" >&2; exit 1; }

printf '\n'
printf '╔══════════════════════════════════════════════════════╗\n'
printf '║       🤖 TERMUX AI AGENT — ONE-SHOT SETUP           ║\n'
printf '║  MCP + Termux:API + 9Router + Pi + Free Models     ║\n'
printf '╚══════════════════════════════════════════════════════╝\n\n'
printf 'This installer will configure:\n'
printf '  • Git + Node.js + curl + Termux:API\n'
printf '  • termux-mcp-server\n'
printf '  • 9Router (latest)\n'
printf '  • Pi Coding Agent\n'
printf '  • pi-9router-ext\n'
printf '  • local router environment + dependencies\n'
printf '  • 9Router in --tray mode\n\n'
printf 'Prerequisite: install the Termux and Termux:API Android apps first.\n\n'

read -r -p 'Continue with the full installation? [Y/n] ' ANSWER
ANSWER="${ANSWER:-Y}"
case "$ANSWER" in
  Y|y|YES|yes|Yes) ;;
  *) printf 'Cancelled.\n'; exit 0 ;;
esac

say '1/9 — Updating Termux and installing prerequisites'
pkg update -y
pkg upgrade -y
pkg install -y git nodejs curl termux-api
ok 'Git, Node.js, curl and Termux:API package installed'

NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 22 ] || fail "Pi currently requires Node.js >=22.19.0; detected $(node --version). Update Termux/Node.js and rerun."
ok "Node $(node --version)"

say '2/9 — Cloning or updating termux-mcp-server'
if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" pull --ff-only
  ok "Updated $REPO_DIR"
else
  git clone "$REPO_URL" "$REPO_DIR"
  ok "Cloned $REPO_DIR"
fi
cd "$REPO_DIR"

say '3/9 — Installing 9Router latest'
npm config set allow-scripts=9router --location=user
npm install -g 9router@latest
command -v 9router >/dev/null 2>&1 || fail '9router was installed but is not in PATH'
ok "9Router $(9router --version 2>/dev/null || printf 'installed')"

say '4/9 — Installing Pi Coding Agent'
npm install -g --ignore-scripts "$PI_PACKAGE"
command -v pi >/dev/null 2>&1 || fail 'Pi was installed but is not in PATH'
ok "Pi $(pi --version 2>/dev/null || printf 'installed')"

say '5/9 — Installing pi-9router-ext'
pi install npm:pi-9router-ext
ok 'pi-9router-ext installed'

say '6/9 — Configuring 9Router'
printf 'Default router URL: %s\n' "$NINE_ROUTER_BASE_URL"
read -r -p 'Press Enter to keep it, or enter another URL: ' CUSTOM_URL
if [ -n "$CUSTOM_URL" ]; then
  NINE_ROUTER_BASE_URL="$CUSTOM_URL"
fi

printf '\nThe API key is stored in ~/.profile for the local Pi/9Router session.\n'
read -r -s -p 'Enter your local 9Router API key (Enter to keep placeholder sk_9router): ' CUSTOM_KEY
printf '\n'
if [ -n "$CUSTOM_KEY" ]; then
  NINE_ROUTER_API_KEY="$CUSTOM_KEY"
fi

PROFILE="$HOME/.profile"
[ -f "$PROFILE" ] || touch "$PROFILE"
sed -i '/^export NINE_ROUTER_BASE_URL=/d;/^export NINE_ROUTER_API_KEY=/d' "$PROFILE"
{
  printf '\n# Termux MCP / 9Router / Pi\n'
  printf 'export NINE_ROUTER_BASE_URL=%q\n' "$NINE_ROUTER_BASE_URL"
  printf 'export NINE_ROUTER_API_KEY=%q\n' "$NINE_ROUTER_API_KEY"
} >> "$PROFILE"
export NINE_ROUTER_BASE_URL NINE_ROUTER_API_KEY
ok "NINE_ROUTER_BASE_URL=$NINE_ROUTER_BASE_URL"
ok 'NINE_ROUTER_API_KEY configured'

say '7/9 — Installing MCP server dependencies'
npm install
ok 'MCP dependencies installed'

say '8/9 — Starting 9Router --tray'
if pgrep -f '[9]router' >/dev/null 2>&1; then
  warn 'An existing 9Router process is already running; leaving it untouched'
else
  nohup 9router --tray > "$HOME/.9router.log" 2>&1 &
  echo $! > "$HOME/.9router.pid"
  sleep 3
  pgrep -f '[9]router' >/dev/null 2>&1 || fail '9Router exited during startup; inspect ~/.9router.log'
  ok '9Router is running in --tray mode'
fi

say '9/9 — Verifying the complete stack'
command -v git >/dev/null
command -v node >/dev/null
command -v termux-battery-status >/dev/null
command -v 9router >/dev/null
command -v pi >/dev/null
curl -fsS --max-time 8 "$NINE_ROUTER_BASE_URL/v1/models" -o "$HOME/.9router-models.json" || warn 'Router API is not reachable yet; configure providers and retry later'

if [ -s "$HOME/.9router-models.json" ]; then
  ok '9Router /v1/models is reachable'
  printf '\n🆓 AVAILABLE MODELS (from your configured providers)\n'
  node -e 'const fs=require("fs");try{const x=JSON.parse(fs.readFileSync(process.env.HOME+"/.9router-models.json","utf8"));const a=x.data||x.models||[];for(const m of a.slice(0,80)) console.log("  • "+(m.id||m.name||m.model||"unknown"));}catch(e){process.exit(0)}' || true
else
  warn 'No model list available yet'
fi

printf '\n╭──────────────────────────────────────────────────────╮\n'
printf '│                 🚀 YOU ARE READY                    │\n'
printf '├──────────────────────────────────────────────────────┤\n'
printf '│ 📱 MCP Server : %s\n' "$REPO_DIR"
printf '│ 🌐 9Router    : %s\n' "$NINE_ROUTER_BASE_URL"
printf '│ 🤖 Pi         : %s\n' "$(pi --version 2>/dev/null || printf 'installed')"
printf '│ 🔌 Extension  : pi-9router-ext\n'
printf '│ 📋 Router log : %s/.9router.log\n' "$HOME"
printf '╰──────────────────────────────────────────────────────╯\n\n'

printf '🎮 NEXT — START USING FREE MODELS\n\n'
printf '1. Start Pi:\n   source ~/.profile && pi\n\n'
printf '2. Inside Pi configure the router:\n   /9router-config\n\n'
printf '3. Refresh/discover models:\n   /9router-reload\n\n'
printf '4. Browse and select a model:\n   /9router-models\n\n'
printf '5. Or use the model selector:\n   /model 9router/<model-id>\n\n'
printf '💡 Connect any free provider available in your 9Router dashboard,\n'
printf '   select one of its available models, and start coding.\n\n'
printf '🔥 Then try:\n'
printf '   "Inspect this project, find the biggest issue, and fix it."\n\n'
printf '📱 Android capabilities are available through the Termux MCP server\n'
printf '   once your MCP client is configured to launch index.js.\n\n'
printf '📚 Docs: https://github.com/yashas-13/termux-mcp-server/tree/main/docs\n'
printf '🔐 Security: keep 9Router local and never publish real API keys.\n\n'

read -r -p 'Launch Pi now? [Y/n] ' LAUNCH
LAUNCH="${LAUNCH:-Y}"
case "$LAUNCH" in
  Y|y|YES|yes|Yes)
    source "$PROFILE"
    cd "$REPO_DIR"
    exec pi
    ;;
  *)
    printf '\nSetup complete. Run `source ~/.profile && pi` whenever you are ready.\n'
    ;;
esac
