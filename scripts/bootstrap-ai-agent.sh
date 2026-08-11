#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

# One-shot Termux MCP + 9Router + Pi installer.
# Interactive prompts use /dev/tty so curl | bash is safe.
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash -s -- --verbose

REPO_URL="https://github.com/yashas-13/termux-mcp-server.git"
REPO_DIR="${REPO_DIR:-$HOME/termux-mcp-server}"
PI_PACKAGE="@earendil-works/pi-coding-agent"
NINE_ROUTER_BASE_URL="${NINE_ROUTER_BASE_URL:-http://127.0.0.1:20128}"
NINE_ROUTER_API_KEY="${NINE_ROUTER_API_KEY:-sk_9router}"
PROFILE="$HOME/.profile"
VERBOSE=0

for arg in "$@"; do
  case "$arg" in
    --verbose|-v) VERBOSE=1 ;;
    --help|-h)
      echo "Usage: bootstrap-ai-agent.sh [--verbose]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

# curl | bash sends the script through stdin. Move interactive input to the
# controlling terminal so prompts never consume downloaded script bytes.
if [ ! -t 0 ]; then
  [ -r /dev/tty ] || { echo "Interactive terminal required." >&2; exit 2; }
  exec </dev/tty
fi

CURRENT_STEP="initialization"
START_EPOCH="$(date +%s)"

cleanup() {
  rc=$?
  if [ "$rc" -ne 0 ]; then
    echo
    echo "ERROR: installation failed (exit $rc)"
    echo "Step: $CURRENT_STEP"
    echo "Repository: $REPO_DIR"
    echo "9Router log: $HOME/.9router.log"
  fi
}
trap cleanup EXIT

error_report() {
  rc=$?
  echo
  echo "ERROR: command failed at line $1 (exit $rc): $2" >&2
  exit "$rc"
}
trap 'error_report "$LINENO" "$BASH_COMMAND"' ERR

step() {
  CURRENT_STEP="$1"
  echo
  echo "=========================================================="
  echo "$CURRENT_STEP"
  echo "=========================================================="
}

run() {
  if [ "$VERBOSE" -eq 1 ]; then
    echo "+ $*"
  fi
  "$@"
}

run_verbose_npm() {
  if [ "$VERBOSE" -eq 1 ]; then
    NPM_CONFIG_LOGLEVEL=verbose "$@"
  else
    "$@"
  fi
}

exists() {
  command -v "$1" >/dev/null 2>&1
}

prompt() {
  local message="$1"
  local variable="$2"
  local value
  read -r -p "$message" value </dev/tty || exit 1
  printf -v "$variable" '%s' "$value"
}

prompt_secret() {
  local message="$1"
  local variable="$2"
  local value
  read -r -s -p "$message" value </dev/tty || exit 1
  echo
  printf -v "$variable" '%s' "$value"
}

echo
 echo "=========================================================="
echo " 9Router + Pi Agent + Android MCP Installer"
echo "=========================================================="
echo "Repository: $REPO_DIR"
echo "Router:     $NINE_ROUTER_BASE_URL"
echo "Mode:       $([ "$VERBOSE" -eq 1 ] && echo VERBOSE || echo NORMAL)"
echo
 echo "Prerequisite: Termux and Termux:API Android apps must already be installed."
echo

ANSWER=""
prompt "Continue? [Y/n] " ANSWER
case "${ANSWER:-Y}" in
  Y|y|YES|yes|Yes) ;;
  *) echo "Cancelled."; exit 0 ;;
esac

step "1/10 — Update Termux and install packages"
# pkg -y answers package confirmation prompts automatically.
run pkg update -y
run pkg upgrade -y
run pkg install -y git nodejs curl termux-api procps tmux fd ripgrep

for command_name in git node npm curl pgrep termux-battery-status tmux; do
  exists "$command_name" || { echo "Missing command: $command_name" >&2; exit 1; }
done

NODE_VERSION="$(node --version)"
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 22 ] || { echo "Pi requires Node.js >=22; found $NODE_VERSION" >&2; exit 1; }

echo "Git:       $(git --version)"
echo "Node.js:   $NODE_VERSION"
echo "npm:       $(npm --version)"
echo "Termux:API: READY"
echo "tmux:      $(tmux -V)"

step "2/10 — Clone or fully fast-forward the Git repository"
if [ -d "$REPO_DIR/.git" ]; then
  # Fetch the complete remote state first, then fast-forward local main.
  run git -C "$REPO_DIR" fetch --prune origin
  run git -C "$REPO_DIR" checkout main
  run git -C "$REPO_DIR" pull --ff-only origin main
  echo "Repository updated to latest fast-forwardable main."
elif [ -e "$REPO_DIR" ]; then
  echo "ERROR: $REPO_DIR exists but is not a Git repository." >&2
  exit 1
else
  run git clone --branch main --single-branch "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"
echo "Commit: $(git rev-parse --short HEAD)"

git status --short

step "3/10 — Install 9Router latest"
run npm config set allow-scripts=9router --location=user
run_verbose_npm npm install -g 9router@latest
exists 9router || { echo "9router is not in PATH." >&2; exit 1; }
echo "9Router: $(9router --version 2>/dev/null || echo installed)"

step "4/10 — Install Pi Coding Agent"
run_verbose_npm npm install -g --ignore-scripts "$PI_PACKAGE"
exists pi || { echo "Pi is not in PATH." >&2; exit 1; }
echo "Pi: $(pi --version 2>/dev/null || echo installed)"

step "5/10 — Install pi-9router-ext"
# Automatically accept a normal Y/n/default confirmation if the extension
# installer asks. stdin is not needed by the package installer itself.
yes "" | pi install npm:pi-9router-ext
 echo "pi-9router-ext: installed"

step "6/10 — Configure 9Router"
echo "Default URL: $NINE_ROUTER_BASE_URL"
CUSTOM_URL=""
prompt "Press Enter for default, or enter another URL: " CUSTOM_URL
[ -z "$CUSTOM_URL" ] || NINE_ROUTER_BASE_URL="$CUSTOM_URL"

CUSTOM_KEY=""
prompt_secret "Enter local 9Router API key (Enter = default): " CUSTOM_KEY
[ -z "$CUSTOM_KEY" ] || NINE_ROUTER_API_KEY="$CUSTOM_KEY"

[ -f "$PROFILE" ] || touch "$PROFILE"
sed -i '/^export NINE_ROUTER_BASE_URL=/d;/^export NINE_ROUTER_API_KEY=/d' "$PROFILE"
{
  echo
  echo "# Termux MCP / 9Router / Pi"
  printf 'export NINE_ROUTER_BASE_URL=%q\n' "$NINE_ROUTER_BASE_URL"
  printf 'export NINE_ROUTER_API_KEY=%q\n' "$NINE_ROUTER_API_KEY"
} >> "$PROFILE"

export NINE_ROUTER_BASE_URL NINE_ROUTER_API_KEY

echo "Router URL: $NINE_ROUTER_BASE_URL"
echo "API key:   configured (hidden)"

step "7/10 — Install MCP server dependencies"
run_verbose_npm npm install

echo "MCP npm dependencies: installed"

step "8/10 — Start 9Router --tray"
if pgrep -af '(^|/)9router( |$)' >/dev/null 2>&1; then
  echo "9Router is already running."
else
  : > "$HOME/.9router.log"
  nohup 9router --tray >> "$HOME/.9router.log" 2>&1 &
  ROUTER_PID=$!
  echo "$ROUTER_PID" > "$HOME/.9router.pid"
  sleep 3

  if kill -0 "$ROUTER_PID" 2>/dev/null; then
    echo "9Router running: PID $ROUTER_PID"
  else
    echo "ERROR: 9Router exited during startup." >&2
    echo "--- ~/.9router.log ---" >&2
    tail -n 80 "$HOME/.9router.log" >&2 || true
    exit 1
  fi
fi

step "9/10 — Verify 9Router"
MODEL_FILE="$HOME/.9router-models.json"

if curl -fsS --max-time 10 \
  "$NINE_ROUTER_BASE_URL/v1/models" \
  -o "$MODEL_FILE"; then
  echo "9Router /v1/models: READY"
  node -e '
    const fs=require("fs");
    try {
      const x=JSON.parse(fs.readFileSync(process.env.HOME+"/.9router-models.json","utf8"));
      const models=x.data||x.models||[];
      console.log("Models discovered: "+models.length);
      models.slice(0,50).forEach(m=>console.log("  - "+(m.id||m.name||m.model||"unknown")));
    } catch (_) {
      console.log("Model response saved to ~/.9router-models.json");
    }
  '
else
  echo "WARNING: 9Router is running but /v1/models is not reachable yet."
  echo "Check: tail -n 80 ~/.9router.log"
fi

step "10/10 — Final stack checks"
[ -x "$REPO_DIR/scripts/doctor.sh" ] || {
  echo "ERROR: scripts/doctor.sh not found." >&2
  exit 1
}

bash "$REPO_DIR/scripts/doctor.sh"

DURATION=$(( $(date +%s) - START_EPOCH ))

echo
echo "=========================================================="
echo " INSTALLATION COMPLETE"
echo "=========================================================="
echo "MCP:        $REPO_DIR"
echo "9Router:    $NINE_ROUTER_BASE_URL"
echo "Pi:         $(pi --version 2>/dev/null || echo installed)"
echo "Extension:  pi-9router-ext"
echo "Duration:   ${DURATION}s"
echo "Router log: $HOME/.9router.log"
echo
 echo "Start:"
echo "  source ~/.profile && pi"
echo
echo "Inside Pi:"
echo "  /9router-config"
echo "  /9router-reload"
echo "  /9router-models"
echo "  /model 9router/<model-id>"
echo
 echo "Choose any currently available free provider/model and start coding."
echo "=========================================================="

LAUNCH=""
prompt "Launch Pi now? [Y/n] " LAUNCH
case "${LAUNCH:-Y}" in
  Y|y|YES|yes|Yes)
    source "$PROFILE"
    cd "$REPO_DIR"
    exec pi
    ;;
  *)
    echo "Setup complete. Run: source ~/.profile && pi"
    ;;
esac
