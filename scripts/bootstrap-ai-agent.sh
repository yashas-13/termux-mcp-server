#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# Termux AI agent bootstrap for Termux MCP Server + 9Router + Pi extension.
# Override these before running if your local 9Router uses different values.
NINE_ROUTER_BASE_URL="${NINE_ROUTER_BASE_URL:-http://localhost:20128}"
NINE_ROUTER_API_KEY="${NINE_ROUTER_API_KEY:-sk_9router}"

pkg update -y
pkg upgrade -y
pkg install -y git nodejs termux-api

npm config set allow-scripts=9router --location=user
npm install -g 9router@latest

if ! command -v pi >/dev/null 2>&1; then
  echo "[!] 'pi' was not found. Install your preferred Pi coding-agent package, then rerun this script."
else
  pi install npm:pi-9router-ext
fi

PROFILE="$HOME/.profile"
mkdir -p "$(dirname "$PROFILE")"

# Remove older managed exports, then write the current values.
if [ -f "$PROFILE" ]; then
  sed -i '/^export NINE_ROUTER_BASE_URL=/d;/^export NINE_ROUTER_API_KEY=/d' "$PROFILE"
fi
{
  printf '\n# Termux MCP / 9Router\n'
  printf 'export NINE_ROUTER_BASE_URL=%q\n' "$NINE_ROUTER_BASE_URL"
  printf 'export NINE_ROUTER_API_KEY=%q\n' "$NINE_ROUTER_API_KEY"
} >> "$PROFILE"

export NINE_ROUTER_BASE_URL NINE_ROUTER_API_KEY

# Start 9Router in the background if it is not already listening on the configured port.
if ! (command -v curl >/dev/null 2>&1 && curl -fsS "$NINE_ROUTER_BASE_URL" >/dev/null 2>&1); then
  nohup 9router > "$HOME/.9router.log" 2>&1 &
  echo $! > "$HOME/.9router.pid"
fi

printf '\n[OK] AI agent bootstrap complete.\n'
printf '[OK] 9Router: %s\n' "$NINE_ROUTER_BASE_URL"
printf '[OK] API key: %s\n' "$NINE_ROUTER_API_KEY"
printf '[OK] Log: %s/.9router.log\n' "$HOME"
printf '[OK] Reload shell: source %s\n' "$PROFILE"
printf '[OK] Then start Pi with: pi\n'
