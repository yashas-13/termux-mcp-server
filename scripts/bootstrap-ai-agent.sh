#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Termux MCP Server + 9Router + Pi one-shot bootstrap.
NINE_ROUTER_BASE_URL="${NINE_ROUTER_BASE_URL:-http://localhost:20128}"
NINE_ROUTER_API_KEY="${NINE_ROUTER_API_KEY:-sk_9router}"
REPO_DIR="${REPO_DIR:-$HOME/termux-mcp-server}"
PI_PACKAGE="@earendil-works/pi-coding-agent"

printf '\n🚀 Termux MCP AI Stack Bootstrap\n'
printf '   MCP + Termux:API + 9Router + Pi + pi-9router-ext\n\n'

pkg update -y
pkg upgrade -y
pkg install -y git nodejs curl termux-api

if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" pull --ff-only
else
  git clone https://github.com/yashas-13/termux-mcp-server.git "$REPO_DIR"
fi

cd "$REPO_DIR"

printf '\n==> Installing 9Router latest...\n'
npm config set allow-scripts=9router --location=user
npm install -g 9router@latest

printf '\n==> Installing Pi Coding Agent...\n'
npm install -g --ignore-scripts "$PI_PACKAGE"

printf '\n==> Installing Pi 9Router extension...\n'
pi install npm:pi-9router-ext

PROFILE="$HOME/.profile"
if [ -f "$PROFILE" ]; then
  sed -i '/^export NINE_ROUTER_BASE_URL=/d;/^export NINE_ROUTER_API_KEY=/d' "$PROFILE"
fi
{
  printf '\n# Termux MCP / 9Router / Pi\n'
  printf 'export NINE_ROUTER_BASE_URL=%q\n' "$NINE_ROUTER_BASE_URL"
  printf 'export NINE_ROUTER_API_KEY=%q\n' "$NINE_ROUTER_API_KEY"
} >> "$PROFILE"
export NINE_ROUTER_BASE_URL NINE_ROUTER_API_KEY

printf '\n==> Installing MCP server dependencies...\n'
npm install

printf '\n==> Starting 9Router --tray...\n'
if ! pgrep -f '[9]router' >/dev/null 2>&1; then
  nohup 9router --tray > "$HOME/.9router.log" 2>&1 &
  echo $! > "$HOME/.9router.pid"
  sleep 2
fi

ROUTER_OK=0
if curl -fsS --max-time 5 "$NINE_ROUTER_BASE_URL/v1/models" >/dev/null 2>&1; then
  ROUTER_OK=1
fi

printf '\n╭──────────────────────────────────────────────╮\n'
printf '│        ✅ AI AGENT STACK READY               │\n'
printf '├──────────────────────────────────────────────┤\n'
printf '│ MCP Server : %s\n' "$REPO_DIR"
printf '│ 9Router    : %s\n' "$NINE_ROUTER_BASE_URL"
printf '│ Pi         : %s\n' "$(pi --version 2>/dev/null || printf 'installed')"
printf '│ Router API : %s\n' "$([ "$ROUTER_OK" -eq 1 ] && printf 'reachable' || printf 'starting / configure providers')"
printf '╰──────────────────────────────────────────────╯\n\n'

printf 'Next:\n'
printf '  source ~/.profile\n'
printf '  cd %s\n' "$REPO_DIR"
printf '  pi\n\n'
printf 'Inside Pi:\n'
printf '  /9router-status\n'
printf '  /9router-config\n'
printf '  /9router-models\n'
printf '  /model 9router/<free-model-id>\n\n'
printf '9Router dashboard: http://localhost:20128\n'
printf 'Logs: tail -f ~/.9router.log\n\n'
printf '💡 Connect a free provider in the 9Router dashboard, select a model in Pi, and start building.\n'
printf '🔐 Never publish a real API key or expose the local router to an untrusted network.\n'
