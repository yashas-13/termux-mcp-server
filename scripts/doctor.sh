#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

# Termux MCP / AI stack diagnostic.
# Usage:
#   bash scripts/doctor.sh
#   curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/doctor.sh | bash

PASS=0
WARN=0
FAIL=0

section() { printf '\n\033[1;36m━━━ %s ━━━\033[0m\n' "$*"; }
ok() { PASS=$((PASS + 1)); printf '  \033[1;32m✅ PASS\033[0m %s\n' "$*"; }
warn() { WARN=$((WARN + 1)); printf '  \033[1;33m⚠️  WARN\033[0m %s\n' "$*"; }
bad() { FAIL=$((FAIL + 1)); printf '  \033[1;31m❌ FAIL\033[0m %s\n' "$*"; }
info() { printf '  ℹ️  %s\n' "$*"; }

printf '\n╔══════════════════════════════════════════════════════╗\n'
printf '║          🤖 ANDROID AGENT DOCTOR                   ║\n'
printf '║   Termux • MCP • 9Router • Pi • Hermes • Android  ║\n'
printf '╚══════════════════════════════════════════════════════╝\n'
printf '\nThis performs diagnostics only; it does not modify your system.\n'

section 'SYSTEM'
info "OS: $(uname -s)"
info "Architecture: $(uname -m)"
info "Termux prefix: ${PREFIX:-unknown}"
info "Home: ${HOME:-unknown}"

if [ -d /data/data/com.termux ]; then ok 'Running inside Termux'; else bad 'Not running inside Termux'; fi

for cmd in pkg git node npm curl; do
  if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd → $(command -v "$cmd")"; else bad "$cmd is missing"; fi
done

if command -v node >/dev/null 2>&1; then
  NODE_VERSION="$(node --version | sed 's/^v//')"
  NODE_MAJOR="${NODE_VERSION%%.*}"
  info "Node.js: v$NODE_VERSION"
  if [ "$NODE_MAJOR" -ge 22 ]; then ok 'Node.js >= 22'; else bad 'Node.js 22+ required by current Pi stack'; fi
fi

if command -v python >/dev/null 2>&1; then
  info "Python: $(python --version 2>&1)"
  ok 'Python available for Hermes/Termux tooling'
else
  warn 'Python missing — Hermes may need it'
fi

section 'TERMUX:API'
if command -v termux-battery-status >/dev/null 2>&1; then ok 'termux-api package installed'; else bad 'termux-api package missing — run: pkg install termux-api'; fi

api_check() {
  local name="$1" cmd="$2"
  local out
  if out=$(timeout 10s bash -c "$cmd" 2>&1); then
    ok "$name responded"
    printf '     %s\n' "$(printf '%s' "$out" | head -c 240 | tr '\n' ' ')"
  else
    bad "$name failed: $(printf '%s' "$out" | tail -n 1)"
  fi
}

if command -v termux-battery-status >/dev/null 2>&1; then api_check 'Battery API' 'termux-battery-status'; fi
if command -v termux-wifi-connectioninfo >/dev/null 2>&1; then api_check 'Wi-Fi API' 'termux-wifi-connectioninfo'; fi
if command -v termux-clipboard-get >/dev/null 2>&1; then api_check 'Clipboard API' 'termux-clipboard-get'; fi

section 'TERMUX MCP SERVER'
REPO_DIR="${REPO_DIR:-$HOME/termux-mcp-server}"
if [ -d "$REPO_DIR/.git" ]; then
  ok "Repository: $REPO_DIR"
  info "Branch: $(git -C "$REPO_DIR" branch --show-current 2>/dev/null || true)"
  info "Commit: $(git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || true)"
else
  bad "Repository not found at $REPO_DIR"
fi

if [ -f "$REPO_DIR/package.json" ]; then ok 'package.json present'; else bad 'package.json missing'; fi
if [ -d "$REPO_DIR/node_modules" ]; then ok 'Node dependencies installed'; else warn 'node_modules missing — run: npm install'; fi

section '9ROUTER'
if command -v 9router >/dev/null 2>&1; then
  ok "9router → $(command -v 9router)"
  info "Version: $(9router --version 2>/dev/null || printf 'unknown')"
else
  bad '9router missing'
fi

BASE_URL="${NINE_ROUTER_BASE_URL:-http://localhost:20128}"
info "Base URL: $BASE_URL"

if command -v 9router >/dev/null 2>&1; then
  if pgrep -af '[9]router' >/dev/null 2>&1; then ok '9Router process is running'; else warn '9Router process is not running'; fi
fi

if command -v curl >/dev/null 2>&1; then
  if curl -fsS --max-time 8 "$BASE_URL/v1/models" -o "$HOME/.termux-mcp-doctor-models.json"; then
    ok '9Router /v1/models reachable'
    node -e 'const fs=require("fs");try{const x=JSON.parse(fs.readFileSync(process.env.HOME+"/.termux-mcp-doctor-models.json","utf8")); const a=x.data||x.models||[]; console.log(`     discovered models: ${a.length}`); a.slice(0,10).forEach(m=>console.log(`       • ${m.id||m.name||m.model||"unknown"}`));}catch(e){console.log("     response received but was not standard JSON")}' || true
  else
    warn "9Router API not reachable at $BASE_URL — start it with: 9router --tray"
  fi
fi

section 'PI CODING AGENT'
if command -v pi >/dev/null 2>&1; then
  ok "Pi → $(command -v pi)"
  info "Version: $(pi --version 2>/dev/null || printf 'unknown')"
  if pi list >/tmp/termux-mcp-pi-list.$$ 2>&1; then
    ok 'Pi package/extension registry responds'
    grep -F 'pi-9router-ext' /tmp/termux-mcp-pi-list.$$ >/dev/null 2>&1 && ok 'pi-9router-ext appears installed' || warn 'pi-9router-ext not found in Pi package list'
  else
    warn 'Pi registry check failed'
  fi
  rm -f /tmp/termux-mcp-pi-list.$$
else
  bad 'Pi Coding Agent missing'
fi

section 'HERMES AGENT'
if command -v hermes >/dev/null 2>&1; then
  ok "Hermes → $(command -v hermes)"
  info "Version: $(hermes --version 2>/dev/null || hermes version 2>/dev/null || printf 'unknown')"
  if hermes doctor >/tmp/termux-mcp-hermes-doctor.$$ 2>&1; then
    ok 'Hermes doctor passed'
    tail -n 8 /tmp/termux-mcp-hermes-doctor.$$ | sed 's/^/     /'
  else
    bad 'Hermes doctor reported a failure'
    tail -n 20 /tmp/termux-mcp-hermes-doctor.$$ | sed 's/^/     /'
  fi
  rm -f /tmp/termux-mcp-hermes-doctor.$$
else
  bad 'Hermes Agent missing — run the one-shot installer or the official Hermes Termux installer'
fi

section 'ENVIRONMENT'
if [ -n "${NINE_ROUTER_BASE_URL:-}" ]; then ok "NINE_ROUTER_BASE_URL=$NINE_ROUTER_BASE_URL"; else warn 'NINE_ROUTER_BASE_URL is not exported in this shell'; fi
if [ -n "${NINE_ROUTER_API_KEY:-}" ]; then ok 'NINE_ROUTER_API_KEY is set'; else warn 'NINE_ROUTER_API_KEY is not exported in this shell'; fi

section 'SECURITY'
info '9Router should remain on localhost unless authenticated remote access is intentionally configured.'
info 'Never commit real API keys or paste them into public logs/issues.'
info 'Treat SMS, contacts, location, camera and clipboard tools as sensitive capabilities.'
info 'Hermes and third-party agent packages can execute code; review packages and keep them in trusted environments.'

section 'RESULT'
printf '\n  PASS: %d\n  WARN: %d\n  FAIL: %d\n\n' "$PASS" "$WARN" "$FAIL"

if [ "$FAIL" -gt 0 ]; then
  printf '❌ STACK STATUS: NOT READY — fix FAIL items and rerun doctor.\n\n'
  exit 1
elif [ "$WARN" -gt 0 ]; then
  printf '🟡 STACK STATUS: PARTIALLY READY — review WARN items.\n\n'
  exit 0
else
  printf '🟢 STACK STATUS: READY — all diagnostics passed.\n\n'
  exit 0
fi
