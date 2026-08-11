#!/data/data/com.termux/files/usr/bin/bash
set -u

PASS=0
WARN=0
FAIL=0

section() { printf '\n━━━ %s ━━━\n' "$*"; }
ok() { PASS=$((PASS + 1)); printf '  PASS  %s\n' "$*"; }
warn() { WARN=$((WARN + 1)); printf '  WARN  %s\n' "$*"; }
bad() { FAIL=$((FAIL + 1)); printf '  FAIL  %s\n' "$*"; }
info() { printf '  INFO  %s\n' "$*"; }

printf '\n==========================================================\n'
printf ' Termux MCP + 9Router + Pi — Doctor\n'
printf '==========================================================\n'
printf 'Diagnostics only; no system changes.\n'

section 'SYSTEM'
info "OS: $(uname -s)"
info "Architecture: $(uname -m)"
info "Termux prefix: ${PREFIX:-unknown}"

if [ -d /data/data/com.termux ]; then ok 'Running inside Termux'; else bad 'Not running inside Termux'; fi

for cmd in pkg git node npm curl; do
  if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd → $(command -v "$cmd")"; else bad "$cmd is missing"; fi
done

if command -v node >/dev/null 2>&1; then
  NODE_VERSION="$(node --version | sed 's/^v//')"
  NODE_MAJOR="${NODE_VERSION%%.*}"
  info "Node.js: v$NODE_VERSION"
  if [ "$NODE_MAJOR" -ge 22 ]; then ok 'Node.js >= 22'; else bad 'Node.js 22+ required'; fi
fi

section 'TERMUX:API'
if command -v termux-battery-status >/dev/null 2>&1; then ok 'termux-api installed'; else bad 'termux-api missing'; fi

if command -v termux-battery-status >/dev/null 2>&1; then
  if termux-battery-status >/dev/null 2>&1; then ok 'Battery API responds'; else bad 'Battery API failed'; fi
fi

if command -v termux-wifi-connectioninfo >/dev/null 2>&1; then
  if termux-wifi-connectioninfo >/dev/null 2>&1; then ok 'Wi-Fi API responds'; else warn 'Wi-Fi API failed'; fi
fi

if command -v termux-clipboard-get >/dev/null 2>&1; then
  if termux-clipboard-get >/dev/null 2>&1; then ok 'Clipboard API responds'; else warn 'Clipboard API failed'; fi
fi

section 'TERMUX MCP SERVER'
REPO_DIR="${REPO_DIR:-$HOME/termux-mcp-server}"
if [ -d "$REPO_DIR/.git" ]; then
  ok "Repository: $REPO_DIR"
  info "Branch: $(git -C "$REPO_DIR" branch --show-current 2>/dev/null || true)"
  info "Commit: $(git -C "$REPO_DIR" rev-parse --short HEAD 2>/dev/null || true)"
else
  bad "Repository not found at $REPO_DIR"
fi

[ -f "$REPO_DIR/package.json" ] && ok 'package.json present' || bad 'package.json missing'
[ -d "$REPO_DIR/node_modules" ] && ok 'Node dependencies installed' || warn 'node_modules missing — run npm install'

section '9ROUTER'
if command -v 9router >/dev/null 2>&1; then
  ok "9Router → $(command -v 9router)"
  info "Version: $(9router --version 2>/dev/null || printf 'unknown')"
else
  bad '9Router missing'
fi

BASE_URL="${NINE_ROUTER_BASE_URL:-http://127.0.0.1:20128}"
info "Base URL: $BASE_URL"

if command -v 9router >/dev/null 2>&1; then
  if pgrep -af '[9]router' >/dev/null 2>&1; then ok '9Router process running'; else warn '9Router process not running'; fi
fi

if command -v curl >/dev/null 2>&1; then
  MODEL_FILE="$HOME/.termux-mcp-doctor-models.json"
  if curl -fsS --max-time 8 "$BASE_URL/v1/models" -o "$MODEL_FILE"; then
    ok '9Router /v1/models reachable'
    node -e 'const fs=require("fs");try{const x=JSON.parse(fs.readFileSync(process.env.HOME+"/.termux-mcp-doctor-models.json","utf8"));const a=x.data||x.models||[];console.log("  INFO  models discovered: "+a.length);a.slice(0,10).forEach(m=>console.log("    - "+(m.id||m.name||m.model||"unknown")))}catch(e){console.log("  WARN  model response was not standard JSON")}' || true
  else
    warn "9Router /v1/models not reachable at $BASE_URL"
  fi
fi

section 'PI CODING AGENT'
if command -v pi >/dev/null 2>&1; then
  ok "Pi → $(command -v pi)"
  info "Version: $(pi --version 2>/dev/null || printf 'unknown')"
  if pi list >/tmp/termux-mcp-pi-list.$$ 2>&1; then
    ok 'Pi package registry responds'
    if grep -F 'pi-9router-ext' /tmp/termux-mcp-pi-list.$$ >/dev/null 2>&1; then
      ok 'pi-9router-ext appears installed'
    else
      warn 'pi-9router-ext not found in Pi package list'
    fi
  else
    warn 'Pi package registry check failed'
  fi
  rm -f /tmp/termux-mcp-pi-list.$$
else
  bad 'Pi Coding Agent missing'
fi

section 'ENVIRONMENT'
if [ -n "${NINE_ROUTER_BASE_URL:-}" ]; then ok "NINE_ROUTER_BASE_URL=$NINE_ROUTER_BASE_URL"; else warn 'NINE_ROUTER_BASE_URL is not exported in this shell'; fi
if [ -n "${NINE_ROUTER_API_KEY:-}" ]; then ok 'NINE_ROUTER_API_KEY is set'; else warn 'NINE_ROUTER_API_KEY is not exported in this shell'; fi

section 'SECURITY'
info 'Keep 9Router on localhost unless authenticated remote access is intentionally configured.'
info 'Never commit real API keys.'
info 'Treat Android side-effecting capabilities such as SMS, contacts, location and clipboard as sensitive.'

section 'RESULT'
printf '\n  PASS: %d\n  WARN: %d\n  FAIL: %d\n\n' "$PASS" "$WARN" "$FAIL"

if [ "$FAIL" -gt 0 ]; then
  printf 'STACK STATUS: NOT READY\n'
  exit 1
elif [ "$WARN" -gt 0 ]; then
  printf 'STACK STATUS: READY WITH WARNINGS\n'
  exit 0
else
  printf 'STACK STATUS: READY\n'
  exit 0
fi
