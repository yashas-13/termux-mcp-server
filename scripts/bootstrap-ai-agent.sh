#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Termux AI-agent bootstrap for Termux MCP Server + 9Router + Pi + Pi 9Router extension.
NINE_ROUTER_BASE_URL="${NINE_ROUTER_BASE_URL:-http://localhost:20128}"
NINE_ROUTER_API_KEY="${NINE_ROUTER_API_KEY:-sk_9router}"

printf '\n==> Updating Termux and installing prerequisites...\n'
pkg update -y
pkg upgrade -y
pkg install -y git nodejs termux-api

printf '\n==> Installing 9Router...\n'
npm config set allow-scripts=9router --location=user
npm install -g 9router@latest

printf '\n==> Installing Pi Coding Agent...\n'
# Pi's documented npm installation mode.
npm install -g --ignore-scripts @earendil-works/pi-coding-agent

printf '\n==> Installing Pi 9Router extension...\n'
pi install npm:pi-9router-ext

PROFILE="$HOME/.profile"
mkdir -p "$(dirname "$PROFILE")"

# Keep managed router settings idempotent.
if [ -f "$PROFILE" ]; then
  sed -i '/^export NINE_ROUTER_BASE_URL=/d;/^export NINE_ROUTER_API_KEY=/d' "$PROFILE"
fi
{
  printf '\n# Termux MCP / 9Router / Pi\n'
  printf 'export NINE_ROUTER_BASE_URL=%q\n' "$NINE_ROUTER_BASE_URL"
  printf 'export NINE_ROUTER_API_KEY=%q\n' "$NINE_ROUTER_API_KEY"
} >> "$PROFILE"

export NINE_ROUTER_BASE_URL NINE_ROUTER_API_KEY

printf '\n==> Starting 9Router on %s...\n' "$NINE_ROUTER_BASE_URL"
# Start 9Router in the background when the configured endpoint is not reachable.
if ! (command -v curl >/dev/null 2>&1 && curl -fsS "$NINE_ROUTER_BASE_URL" >/dev/null 2>&1); then
  nohup 9router > "$HOME/.9router.log" 2>&1 &
  echo $! > "$HOME/.9router.pid"
fi

printf '\n[OK] AI-agent bootstrap complete.\n'
printf '[OK] 9Router: %s\n' "$NINE_ROUTER_BASE_URL"
printf '[OK] Pi: %s\n' "$(command -v pi)"
printf '[OK] Pi extension: pi-9router-ext\n'
printf '[OK] Log: %s/.9router.log\n' "$HOME"
printf '[OK] Reload shell: source %s\n' "$PROFILE"
printf '[OK] Start Pi: pi\n'
printf '[OK] Configure the extension inside Pi with: /9router-config\n'
