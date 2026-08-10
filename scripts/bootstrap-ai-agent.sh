#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

# Interactive one-shot bootstrap for Termux MCP Server + 9Router + Pi.
# Safe invocation from a terminal:
#   curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash
# Verbose invocation:
#   curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash -s -- --verbose

REPO_URL="https://github.com/yashas-13/termux-mcp-server.git"
REPO_DIR="${REPO_DIR:-$HOME/termux-mcp-server}"
PI_PACKAGE="@earendil-works/pi-coding-agent"
NINE_ROUTER_BASE_URL="${NINE_ROUTER_BASE_URL:-http://localhost:20128}"
NINE_ROUTER_API_KEY="${NINE_ROUTER_API_KEY:-sk_9router}"
PROFILE="$HOME/.profile"
VERBOSE=0

for arg in "$@"; do
  case "$arg" in
    --verbose|-v) VERBOSE=1 ;;
    --help|-h)
      cat <<'EOF'
Usage: bootstrap-ai-agent.sh [--verbose]

Installs/configures:
  Git + Node.js + curl + procps + Termux:API
  termux-mcp-server + dependencies
  9Router latest + 9router --tray
  Pi Coding Agent + pi-9router-ext

Options:
  -v, --verbose  Print each shell command before execution.
EOF
      exit 0
      ;;
    *) printf '❌ Unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

# curl | bash leaves stdin attached to curl. Move interactive input to the
# controlling terminal so prompts cannot consume downloaded script bytes.
if [ ! -t 0 ]; then
  if [ -r /dev/tty ]; then
    exec </dev/tty
  else
    printf '❌ Interactive terminal required. Run this script from a TTY.\n' >&2
    exit 2
  fi
fi

if [ "$VERBOSE" -eq 1 ]; then
  export PS4='+ [$(date +%H:%M:%S)] ${BASH_SOURCE##*/}:${LINENO}: '
  set -x
fi

START_EPOCH="$(date +%s)"
CURRENT_STEP='initialization'

cleanup() {
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    printf '\n❌ Bootstrap failed (exit %s).\n' "$rc" >&2
    printf '   Failed step: %s\n' "$CURRENT_STEP" >&2
    printf '   Repository: %s\n' "$REPO_DIR" >&2
    printf '   9Router log: %s/.9router.log\n' "$HOME" >&2
    printf '   Run: bash %s/scripts/doctor.sh\n' "$REPO_DIR" >&2
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

say() { printf '\n\033[1;36m━━━ %s ━━━\033[0m\n' "$*"; }
ok() { printf '  \033[1;32m✅ %s\033[0m\n' "$*"; }
warn() { printf '  \033[1;33m⚠️  %s\033[0m\n' "$*" >&2; }
fail() { printf '  \033[1;31m❌ %s\033[0m\n' "$*" >&2; exit 1; }

prompt() {
  local message="$1" __resultvar="$2" value
  if ! read -r -p "$message" value </dev/tty; then fail 'Unable to read from the terminal.'; fi
  printf -v "$__resultvar" '%s' "$value"
}

prompt_secret() {
  local message="$1" __resultvar="$2" value
  if ! read -r -s -p "$message" value </dev/tty; then fail 'Unable to read the secret from the terminal.'; fi
  printf '\n'
  printf -v "$__resultvar" '%s' "$value"
}

command_exists() { command -v "$1" >/dev/null 2>&1; }

step() {
  CURRENT_STEP="$1"
  say "$CURRENT_STEP"
}

printf '\n╔══════════════════════════════════════════════════════╗\n'
printf '║       🤖 TERMUX AI AGENT — ONE-SHOT SETUP           ║\n'
printf '║  MCP + Termux:API + 9Router + Pi + Free Models     ║\n'
printf '╚══════════════════════════════════════════════════════╝\n\n'
printf 'Mode: %s\n' "$([ "$VERBOSE" -eq 1 ] && printf 'VERBOSE' || printf 'NORMAL')"
printf 'Repository: %s\n' "$REPO_DIR"
printf 'Router: %s\n\n' "$NINE_ROUTER_BASE_URL"
printf 'This installer configures Git, Node.js, Termux:API, the MCP server,\n9Router, Pi, pi-9router-ext and a local model-routing workflow.\n\n'
printf 'Prerequisite: install the Termux and Termux:API Android apps first.\n\n'

ANSWER=''
prompt 'Continue with the full installation? [Y/n] ' ANSWER
ANSWER="${ANSWER:-Y}"
case "$ANSWER" in
  Y|y|YES|yes|Yes) ;;
  *) printf 'Cancelled.\n'; exit 0 ;;
esac

step '1/10 — Updating Termux and installing prerequisites'
pkg update -y
pkg upgrade -y
pkg install -y git nodejs curl termux-api procps
command_exists git || fail 'Git is not available after installation.'
command_exists node || fail 'Node.js is not available after installation.'
command_exists npm || fail 'npm is not available after Node.js installation.'
command_exists curl || fail 'curl is not available after installation.'
command_exists pgrep || fail 'pgrep is not available; procps installation failed.'
command_exists termux-battery-status || fail 'Termux:API commands are unavailable. Install/open the Termux:API Android app, then rerun.'
ok 'Git, Node.js, npm, curl, procps and Termux:API package installed'

NODE_VERSION="$(node --version)"
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 22 ] || fail "Pi requires Node.js >=22; detected $NODE_VERSION. Update Termux packages and rerun."
ok "Node $NODE_VERSION"

step '2/10 — Cloning or updating termux-mcp-server'
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

step '3/10 — Installing 9Router latest'
npm config set allow-scripts=9router --location=user
npm install -g 9router@latest
command_exists 9router || fail '9Router was installed but the executable is not in PATH.'
ok "9Router $(9router --version 2>/dev/null || printf 'installed')"

step '4/10 — Installing Pi Coding Agent'
npm install -g --ignore-scripts "$PI_PACKAGE"
command_exists pi || fail 'Pi was installed but the executable is not in PATH.'
ok "Pi $(pi --version 2>/dev/null || printf 'installed')"

step '5/10 — Installing pi-9router-ext'
pi install npm:pi-9router-ext
ok 'pi-9router-ext installed'

step '6/10 — Configuring 9Router'
printf 'Default router URL: %s\n' "$NINE_ROUTER_BASE_URL"
CUSTOM_URL=''
prompt 'Press Enter to keep it, or enter another URL: ' CUSTOM_URL
if [ -n "$CUSTOM_URL" ]; then NINE_ROUTER_BASE_URL="$CUSTOM_URL"; fi

printf '\nThe API key is stored in ~/.profile for the local Pi/9Router session.\n'
CUSTOM_KEY=''
prompt_secret 'Enter your local 9Router API key (Enter to keep placeholder sk_9router): ' CUSTOM_KEY
if [ -n "$CUSTOM_KEY" ]; then NINE_ROUTER_API_KEY="$CUSTOM_KEY"; fi

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

step '7/10 — Installing MCP server dependencies'
npm install
ok 'MCP dependencies installed'

step '8/10 — Starting 9Router --tray'
if pgrep -af '(^|/)9router( |$)' >/dev/null 2>&1; then
  warn 'An existing 9Router process is already running; leaving it untouched.'
else
  : > "$HOME/.9router.log"
  nohup 9router --tray >> "$HOME/.9router.log" 2>&1 &
  ROUTER_PID=$!
  printf '%s\n' "$ROUTER_PID" > "$HOME/.9router.pid"
  sleep 3
  if ! kill -0 "$ROUTER_PID" 2>/dev/null; then
    printf '\n--- ~/.9router.log (last 80 lines) ---\n' >&2
    tail -n 80 "$HOME/.9router.log" >&2 || true
    fail '9Router exited during startup. See ~/.9router.log.'
  fi
  ok "9Router is running in --tray mode (PID $ROUTER_PID)"
fi

step '9/10 — Health-checking 9Router'
MODEL_FILE="$HOME/.9router-models.json"
if curl -fsS --max-time 10 "$NINE_ROUTER_BASE_URL/v1/models" -o "$MODEL_FILE"; then
  ok '9Router /v1/models is reachable'
  printf '\n🆓 AVAILABLE MODELS\n'
  node -e 'const fs=require("fs");try{const x=JSON.parse(fs.readFileSync(process.env.HOME+"/.9router-models.json","utf8"));const a=x.data||x.models||[];if(!a.length)console.log("  • No models returned yet — configure a provider in 9Router.");for(const m of a.slice(0,80)) console.log("  • "+(m.id||m.name||m.model||"unknown"));}catch(e){console.log("  • Model response was not JSON; inspect ~/.9router-models.json")}' || true
else
  warn '9Router started, but /v1/models is not reachable yet.'
  printf '   Router log: %s/.9router.log\n' "$HOME"
fi

step '10/10 — Running full stack diagnostics'
if [ -x "$REPO_DIR/scripts/doctor.sh" ]; then
  if [ "$VERBOSE" -eq 1 ]; then
    bash "$REPO_DIR/scripts/doctor.sh"
  else
    bash "$REPO_DIR/scripts/doctor.sh"
  fi
else
  warn 'doctor.sh was not found; skipping post-install diagnostics.'
fi

END_EPOCH="$(date +%s)"
DURATION=$((END_EPOCH - START_EPOCH))

printf '\n╭──────────────────────────────────────────────────────╮\n'
printf '│                 🚀 STACK INSTALLED                  │\n'
printf '├──────────────────────────────────────────────────────┤\n'
printf '│ 📱 MCP Server : %s\n' "$REPO_DIR"
printf '│ 🌐 9Router    : %s\n' "$NINE_ROUTER_BASE_URL"
printf '│ 🤖 Pi         : %s\n' "$(pi --version 2>/dev/null || printf 'installed')"
printf '│ 🔌 Extension  : pi-9router-ext\n'
printf '│ 📋 Router log : %s/.9router.log\n' "$HOME"
printf '│ ⏱️  Duration   : %ss\n' "$DURATION"
printf '╰──────────────────────────────────────────────────────╯\n\n'

printf '🎮 NEXT — START USING FREE MODELS\n\n'
printf '1. Start Pi:\n   source ~/.profile && pi\n\n'
printf '2. Configure the router:\n   /9router-config\n\n'
printf '3. Refresh/discover models:\n   /9router-reload\n\n'
printf '4. Browse models:\n   /9router-models\n\n'
printf '5. Select one:\n   /model 9router/<model-id>\n\n'
printf '💡 Connect any currently available free provider in your local 9Router\n'
printf '   dashboard, select a discovered model, and start coding.\n\n'
printf '📱 MCP entry point:\n   %s/index.js\n\n' "$REPO_DIR"
printf '🩺 Re-run diagnostics anytime:\n   bash %s/scripts/doctor.sh\n\n' "$REPO_DIR"
printf '📚 Docs: https://github.com/yashas-13/termux-mcp-server/tree/main/docs\n'
printf '🔐 Security: keep 9Router local and never publish real API keys.\n\n'

LAUNCH=''
prompt 'Launch Pi now? [Y/n] ' LAUNCH
LAUNCH="${LAUNCH:-Y}"
case "$LAUNCH" in
  Y|y|YES|yes|Yes)
    # Reload profile values without changing interactive stdin.
    # shellcheck disable=SC1090
    source "$PROFILE"
    cd "$REPO_DIR"
    exec pi
    ;;
  *)
    printf '\nSetup complete. Run `source ~/.profile && pi` whenever you are ready.\n'
    ;;
esac
