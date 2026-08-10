#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

# Interactive one-shot bootstrap for Termux MCP Server + 9Router + Pi.
# Safe invocation from a terminal:
#   curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash
#
# IMPORTANT: curl | bash uses stdin for the script itself. We explicitly move
# interactive input to /dev/tty so prompts cannot consume the remaining script.

REPO_URL="https://github.com/yashas-13/termux-mcp-server.git"
REPO_DIR="${REPO_DIR:-$HOME/termux-mcp-server}"
PI_PACKAGE="@earendil-works/pi-coding-agent"
NINE_ROUTER_BASE_URL="${NINE_ROUTER_BASE_URL:-http://localhost:20128}"
NINE_ROUTER_API_KEY="${NINE_ROUTER_API_KEY:-sk_9router}"
PROFILE="$HOME/.profile"

# curl | bash leaves stdin attached to curl. Redirect future interactive
# reads to the controlling terminal so `read` never consumes script bytes.
if [ ! -t 0 ]; then
  if [ -r /dev/tty ]; then
    exec </dev/tty
  else
    printf '❌ Interactive terminal required. Run this script from a TTY.\n' >&2
    exit 2
  fi
fi

cleanup() {
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    printf '\n❌ Bootstrap failed (exit %s).\n' "$rc" >&2
    printf '   Repository: %s\n' "$REPO_DIR" >&2
    printf '   9Router log: %s/.9router.log\n' "$HOME" >&2
    printf '   Retry after fixing the reported problem; the installer is rerunnable.\n' >&2
  fi
}
trap cleanup EXIT

on_error() {
  local rc=$?
  printf '\n❌ Command failed at line %s (exit %s): %s\n' "$1" "$rc" "$2" >&2
  exit "$rc"
}
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

say() { printf '\n%s\n' "$*"; }
ok() { printf '  ✅ %s\n' "$*"; }
warn() { printf '  ⚠️  %s\n' "$*" >&2; }
fail() { printf '  ❌ %s\n' "$*" >&2; exit 1; }

prompt() {
  local message="$1"
  local __resultvar="$2"
  local value
  if ! read -r -p "$message" value </dev/tty; then
    fail 'Unable to read from the terminal.'
  fi
  printf -v "$__resultvar" '%s' "$value"
}

prompt_secret() {
  local message="$1"
  local __resultvar="$2"
  local value
  if ! read -r -s -p "$message" value </dev/tty; then
    fail 'Unable to read the secret from the terminal.'
  fi
  printf '\n'
  printf -v "$__resultvar" '%s' "$value"
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

printf '\n'
printf '╔══════════════════════════════════════════════════════╗\n'
printf '║       🤖 TERMUX AI AGENT — ONE-SHOT SETUP           ║\n'
printf '║  MCP + Termux:API + 9Router + Pi + Free Models     ║\n'
printf '╚══════════════════════════════════════════════════════╝\n\n'
printf 'This installer configures:\n'
printf '  • Git + Node.js + curl + Termux:API\n'
printf '  • termux-mcp-server\n'
printf '  • 9Router (latest)\n'
printf '  • Pi Coding Agent\n'
printf '  • pi-9router-ext\n'
printf '  • local router environment + dependencies\n'
printf '  • 9Router in --tray mode\n\n'
printf 'Prerequisite: install the Termux and Termux:API Android apps first.\n\n'

ANSWER=''
prompt 'Continue with the full installation? [Y/n] ' ANSWER
ANSWER="${ANSWER:-Y}"
case "$ANSWER" in
  Y|y|YES|yes|Yes) ;;
  *) printf 'Cancelled.\n'; exit 0 ;;
esac

say '1/9 — Updating Termux and installing prerequisites'
pkg update -y
pkg upgrade -y
pkg install -y git nodejs curl termux-api procps
command_exists git || fail 'Git is not available after installation.'
command_exists node || fail 'Node.js is not available after installation.'
command_exists curl || fail 'curl is not available after installation.'
command_exists termux-battery-status || fail 'Termux:API commands are unavailable. Install/open the Termux:API Android app, then rerun.'
ok 'Git, Node.js, curl, procps and Termux:API package installed'

NODE_VERSION="$(node --version)"
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 22 ] || fail "Pi requires Node.js >=22; detected $NODE_VERSION. Update Termux packages and rerun."
ok "Node $NODE_VERSION"

say '2/9 — Cloning or updating termux-mcp-server'
if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" fetch --prune origin
  git -C "$REPO_DIR" pull --ff-only
  ok "Updated $REPO_DIR"
elif [ -e "$REPO_DIR" ]; then
  fail "$REPO_DIR exists but is not a Git repository. Move it aside or set REPO_DIR to another directory."
else
  git clone "$REPO_URL" "$REPO_DIR"
  ok "Cloned $REPO_DIR"
fi
cd "$REPO_DIR"

say '3/9 — Installing 9Router latest'
npm config set allow-scripts=9router --location=user
npm install -g 9router@latest
command_exists 9router || fail '9Router was installed but the executable is not in PATH.'
ok "9Router $(9router --version 2>/dev/null || printf 'installed')"

say '4/9 — Installing Pi Coding Agent'
npm install -g --ignore-scripts "$PI_PACKAGE"
command_exists pi || fail 'Pi was installed but the executable is not in PATH.'
ok "Pi $(pi --version 2>/dev/null || printf 'installed')"

say '5/9 — Installing pi-9router-ext'
pi install npm:pi-9router-ext
ok 'pi-9router-ext installed'

say '6/9 — Configuring 9Router'
printf 'Default router URL: %s\n' "$NINE_ROUTER_BASE_URL"
CUSTOM_URL=''
prompt 'Press Enter to keep it, or enter another URL: ' CUSTOM_URL
if [ -n "$CUSTOM_URL" ]; then
  NINE_ROUTER_BASE_URL="$CUSTOM_URL"
fi

printf '\nThe API key is stored in ~/.profile for the local Pi/9Router session.\n'
CUSTOM_KEY=''
prompt_secret 'Enter your local 9Router API key (Enter to keep placeholder sk_9router): ' CUSTOM_KEY
if [ -n "$CUSTOM_KEY" ]; then
  NINE_ROUTER_API_KEY="$CUSTOM_KEY"
fi

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
if pgrep -af '(^|/)9router( |$)' >/dev/null 2>&1; then
  warn 'An existing 9Router process is already running; leaving it untouched.'
else
  : > "$HOME/.9router.log"
  nohup 9router --tray >> "$HOME/.9router.log" 2>&1 &
  ROUTER_PID=$!
  printf '%s\n' "$ROUTER_PID" > "$HOME/.9router.pid"
  sleep 3
  if ! kill -0 "$ROUTER_PID" 2>/dev/null; then
    printf '--- ~/.9router.log ---\n' >&2
    tail -n 80 "$HOME/.9router.log" >&2 || true
    fail '9Router exited during startup. See ~/.9router.log.'
  fi
  ok "9Router is running in --tray mode (PID $ROUTER_PID)"
fi

say '9/9 — Verifying the complete stack'
command_exists git || fail 'Verification failed: git'
command_exists node || fail 'Verification failed: node'
command_exists termux-battery-status || fail 'Verification failed: Termux:API'
command_exists 9router || fail 'Verification failed: 9router'
command_exists pi || fail 'Verification failed: pi'

MODEL_FILE="$HOME/.9router-models.json"
if curl -fsS --max-time 10 "$NINE_ROUTER_BASE_URL/v1/models" -o "$MODEL_FILE"; then
  ok '9Router /v1/models is reachable'
  printf '\n🆓 AVAILABLE MODELS (from your configured providers)\n'
  node -e 'const fs=require("fs");try{const x=JSON.parse(fs.readFileSync(process.env.HOME+"/.9router-models.json","utf8"));const a=x.data||x.models||[];if(!a.length)console.log("  • No models returned yet — configure a provider in 9Router.");for(const m of a.slice(0,80)) console.log("  • "+(m.id||m.name||m.model||"unknown"));}catch(e){console.log("  • Model response was not JSON; inspect ~/.9router-models.json")}' || true
else
  warn '9Router process started, but /v1/models is not reachable yet. The setup is incomplete until the router is configured/ready.'
  printf '   Inspect: tail -n 80 ~/.9router.log\n'
fi

printf '\n╭──────────────────────────────────────────────────────╮\n'
printf '│                 🚀 STACK INSTALLED                  │\n'
printf '├──────────────────────────────────────────────────────┤\n'
printf '│ 📱 MCP Server : %s\n' "$REPO_DIR"
printf '│ 🌐 9Router    : %s\n' "$NINE_ROUTER_BASE_URL"
printf '│ 🤖 Pi         : %s\n' "$(pi --version 2>/dev/null || printf 'installed')"
printf '│ 🔌 Extension  : pi-9router-ext\n'
printf '│ 📋 Router log : %s/.9router.log\n' "$HOME"
printf '╰──────────────────────────────────────────────────────╯\n\n'

printf '🎮 NEXT — START USING FREE MODELS\n\n'
printf '1. Start Pi:\n   source ~/.profile && pi\n\n'
printf '2. Configure the router:\n   /9router-config\n\n'
printf '3. Refresh/discover models:\n   /9router-reload\n\n'
printf '4. Browse models:\n   /9router-models\n\n'
printf '5. Select one:\n   /model 9router/<model-id>\n\n'
printf '💡 Connect any currently available free provider in your local 9Router\n'
printf '   dashboard, select a discovered model, and start coding.\n\n'
printf '📱 Then configure your MCP client to launch:\n   %s/index.js\n\n' "$REPO_DIR"
printf '📚 Docs: https://github.com/yashas-13/termux-mcp-server/tree/main/docs\n'
printf '🔐 Security: keep 9Router local and never publish real API keys.\n\n'

LAUNCH=''
prompt 'Launch Pi now? [Y/n] ' LAUNCH
LAUNCH="${LAUNCH:-Y}"
case "$LAUNCH" in
  Y|y|YES|yes|Yes)
    # Reload profile values without changing the terminal's interactive stdin.
    # shellcheck disable=SC1090
    source "$PROFILE"
    cd "$REPO_DIR"
    exec pi
    ;;
  *)
    printf '\nSetup complete. Run `source ~/.profile && pi` whenever you are ready.\n'
    ;;
esac
