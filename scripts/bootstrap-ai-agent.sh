#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

# Interactive one-shot bootstrap for Termux MCP Server + 9Router + Pi.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash
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
      printf 'Usage: bootstrap-ai-agent.sh [--verbose]\n'
      printf '  --verbose  enable verbose npm/package diagnostics; secrets are never shell-traced\n'
      exit 0
      ;;
    *) printf '❌ Unknown option: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

# curl | bash feeds the script through stdin. Always read interactive answers
# from the controlling terminal so `read` cannot consume script bytes.
if [ ! -t 0 ]; then
  [ -r /dev/tty ] || { printf '❌ Interactive terminal required.\n' >&2; exit 2; }
  exec </dev/tty
fi

CURRENT_STEP='initialization'
START_EPOCH="$(date +%s)"

cleanup() {
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    printf '\n❌ Bootstrap failed (exit %s)\n' "$rc" >&2
    printf '   Step: %s\n' "$CURRENT_STEP" >&2
    printf '   Repo: %s\n' "$REPO_DIR" >&2
    printf '   Router log: %s/.9router.log\n' "$HOME" >&2
    [ -d "$REPO_DIR" ] && printf '   Doctor: bash %s/scripts/doctor.sh\n' "$REPO_DIR" >&2
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
step() { CURRENT_STEP="$1"; say "$CURRENT_STEP"; }
cmd() { if [ "$VERBOSE" -eq 1 ]; then printf '  $ %s\n' "$*"; fi; "$@"; }
prompt() { local m="$1" v; read -r -p "$m" v </dev/tty || fail 'Unable to read from terminal'; printf -v "$2" '%s' "$v"; }
prompt_secret() { local m="$1" v; read -r -s -p "$m" v </dev/tty || fail 'Unable to read secret'; printf '\n'; printf -v "$2" '%s' "$v"; }
exists() { command -v "$1" >/dev/null 2>&1; }

printf '\n╔══════════════════════════════════════════════════════╗\n'
printf '║       🤖 TERMUX AI AGENT — ONE-SHOT SETUP           ║\n'
printf '║  MCP + Termux:API + 9Router + Pi + Free Models     ║\n'
printf '╚══════════════════════════════════════════════════════╝\n\n'
printf 'Mode: %s\nRepository: %s\nRouter: %s\n\n' "$([ "$VERBOSE" -eq 1 ] && echo VERBOSE || echo NORMAL)" "$REPO_DIR" "$NINE_ROUTER_BASE_URL"
printf 'Prerequisite: install the Termux and Termux:API Android apps first.\n\n'

ANSWER=''
prompt 'Continue with the full installation? [Y/n] ' ANSWER
case "${ANSWER:-Y}" in Y|y|YES|yes|Yes) ;; *) printf 'Cancelled.\n'; exit 0 ;; esac

step '1/10 — Updating Termux and installing prerequisites'
cmd pkg update -y
cmd pkg upgrade -y
cmd pkg install -y git nodejs curl termux-api procps
for c in git node npm curl pgrep termux-battery-status; do exists "$c" || fail "$c is unavailable after installation"; done
NODE_VERSION="$(node --version)"
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 22 ] || fail "Pi requires Node.js >=22; detected $NODE_VERSION"
ok "Prerequisites ready — Node $NODE_VERSION"

step '2/10 — Cloning or updating termux-mcp-server'
if [ -d "$REPO_DIR/.git" ]; then
  cmd git -C "$REPO_DIR" fetch --prune origin
  cmd git -C "$REPO_DIR" pull --ff-only
  ok "Updated $REPO_DIR"
elif [ -e "$REPO_DIR" ]; then
  fail "$REPO_DIR exists but is not a Git repository"
else
  cmd git clone "$REPO_URL" "$REPO_DIR"
  ok "Cloned $REPO_DIR"
fi
cd "$REPO_DIR"

step '3/10 — Installing 9Router latest'
cmd npm config set allow-scripts=9router --location=user
if [ "$VERBOSE" -eq 1 ]; then cmd env NPM_CONFIG_LOGLEVEL=verbose npm install -g 9router@latest; else cmd npm install -g 9router@latest; fi
exists 9router || fail '9router is not in PATH after installation'
ok "9Router $(9router --version 2>/dev/null || echo installed)"

step '4/10 — Installing Pi Coding Agent'
if [ "$VERBOSE" -eq 1 ]; then cmd env NPM_CONFIG_LOGLEVEL=verbose npm install -g --ignore-scripts "$PI_PACKAGE"; else cmd npm install -g --ignore-scripts "$PI_PACKAGE"; fi
exists pi || fail 'Pi is not in PATH after installation'
ok "Pi $(pi --version 2>/dev/null || echo installed)"

step '5/10 — Installing pi-9router-ext'
cmd pi install npm:pi-9router-ext
ok 'pi-9router-ext installed'

# Do not shell-trace this section: the API key is a secret.
step '6/10 — Configuring 9Router'
printf 'Default router URL: %s\n' "$NINE_ROUTER_BASE_URL"
CUSTOM_URL=''
prompt 'Press Enter to keep it, or enter another URL: ' CUSTOM_URL
[ -z "$CUSTOM_URL" ] || NINE_ROUTER_BASE_URL="$CUSTOM_URL"
CUSTOM_KEY=''
prompt_secret 'Enter local 9Router API key (Enter = sk_9router): ' CUSTOM_KEY
[ -z "$CUSTOM_KEY" ] || NINE_ROUTER_API_KEY="$CUSTOM_KEY"
[ -f "$PROFILE" ] || touch "$PROFILE"
sed -i '/^export NINE_ROUTER_BASE_URL=/d;/^export NINE_ROUTER_API_KEY=/d' "$PROFILE"
{
  printf '\n# Termux MCP / 9Router / Pi\n'
  printf 'export NINE_ROUTER_BASE_URL=%q\n' "$NINE_ROUTER_BASE_URL"
  printf 'export NINE_ROUTER_API_KEY=%q\n' "$NINE_ROUTER_API_KEY"
} >> "$PROFILE"
export NINE_ROUTER_BASE_URL NINE_ROUTER_API_KEY
ok "Router URL configured: $NINE_ROUTER_BASE_URL"
ok 'Router API key configured (value hidden)'

step '7/10 — Installing MCP server dependencies'
if [ "$VERBOSE" -eq 1 ]; then cmd env NPM_CONFIG_LOGLEVEL=verbose npm install; else cmd npm install; fi
ok 'MCP dependencies installed'

step '8/10 — Starting 9Router --tray'
if pgrep -af '(^|/)9router( |$)' >/dev/null 2>&1; then
  warn 'An existing 9Router process is already running; leaving it untouched'
else
  : > "$HOME/.9router.log"
  nohup 9router --tray >> "$HOME/.9router.log" 2>&1 &
  ROUTER_PID=$!
  printf '%s\n' "$ROUTER_PID" > "$HOME/.9router.pid"
  sleep 3
  if ! kill -0 "$ROUTER_PID" 2>/dev/null; then
    printf '\n--- ~/.9router.log (last 80 lines) ---\n' >&2
    tail -n 80 "$HOME/.9router.log" >&2 || true
    fail '9Router exited during startup'
  fi
  ok "9Router --tray running (PID $ROUTER_PID)"
fi

step '9/10 — Health-checking 9Router'
MODEL_FILE="$HOME/.9router-models.json"
if curl -fsS --max-time 10 "$NINE_ROUTER_BASE_URL/v1/models" -o "$MODEL_FILE"; then
  ok '9Router /v1/models is reachable'
  node -e 'const fs=require("fs");try{const x=JSON.parse(fs.readFileSync(process.env.HOME+"/.9router-models.json","utf8"));const a=x.data||x.models||[];console.log(`  discovered models: ${a.length}`);a.slice(0,80).forEach(m=>console.log("  • "+(m.id||m.name||m.model||"unknown")));}catch(e){console.log("  model response is not standard JSON; inspect ~/.9router-models.json")}' || true
else
  warn '9Router started but /v1/models is not reachable yet; configure/check the router before using models'
  printf '   Log: tail -n 80 ~/.9router.log\n'
fi

step '10/10 — Running full stack diagnostics'
if [ -x "$REPO_DIR/scripts/doctor.sh" ]; then
  bash "$REPO_DIR/scripts/doctor.sh" || fail 'Doctor reported a failed component'
else
  fail 'scripts/doctor.sh is missing from the repository'
fi

DURATION=$(( $(date +%s) - START_EPOCH ))
printf '\n╭──────────────────────────────────────────────────────╮\n'
printf '│                 🚀 STACK INSTALLED                  │\n'
printf '├──────────────────────────────────────────────────────┤\n'
printf '│ 📱 MCP Server : %s\n' "$REPO_DIR"
printf '│ 🌐 9Router    : %s\n' "$NINE_ROUTER_BASE_URL"
printf '│ 🤖 Pi         : %s\n' "$(pi --version 2>/dev/null || echo installed)"
printf '│ 🔌 Extension  : pi-9router-ext\n'
printf '│ 📋 Router log : %s/.9router.log\n' "$HOME"
printf '│ ⏱️  Duration   : %ss\n' "$DURATION"
printf '╰──────────────────────────────────────────────────────╯\n\n'
printf '🎮 NEXT — FREE MODEL SETUP\n\n'
printf 'source ~/.profile && pi\n'
printf '/9router-config\n/9router-reload\n/9router-models\n/model 9router/<model-id>\n\n'
printf '🩺 Re-run diagnostics: bash %s/scripts/doctor.sh\n' "$REPO_DIR"
printf '📚 Docs: https://github.com/yashas-13/termux-mcp-server/tree/main/docs\n'
printf '🔐 Credentials remain hidden; keep 9Router local.\n\n'

LAUNCH=''
prompt 'Launch Pi now? [Y/n] ' LAUNCH
case "${LAUNCH:-Y}" in
  Y|y|YES|yes|Yes)
    # Intentionally no shell tracing here; ~/.profile contains the API key.
    source "$PROFILE"
    cd "$REPO_DIR"
    exec pi
    ;;
  *) printf 'Setup complete. Run `source ~/.profile && pi` when ready.\n' ;;
esac
