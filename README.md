# 🤖 Termux MCP Server — Give Your AI Agent a Body

> **Turn your Android phone into an AI-controlled device.**
>
> Connect an MCP-compatible AI agent to **Termux:API** and expose real Android capabilities — battery, clipboard, camera, sensors, GPS, TTS, Wi-Fi, notifications, contacts, SMS and more.

[![MCP](https://img.shields.io/badge/MCP-compatible-7C3AED?style=for-the-badge)](https://modelcontextprotocol.io/)
[![Android](https://img.shields.io/badge/Android-Termux-34A853?style=for-the-badge)](https://termux.com/)
[![Node.js](https://img.shields.io/badge/Node.js-22%2B-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)
[![Sponsor](https://img.shields.io/badge/💜_Sponsor-GitHub_Sponsors-EA4AAA?style=for-the-badge)](https://github.com/sponsors/yashas-13)

---

## ⚡ The idea

Most AI agents can **think**.

Your phone can **see, hear, speak, sense, locate, notify and communicate**.

This project connects the two:

```text
                         🤖 AI AGENT
                              │
                              │ MCP
                              ▼
                    ┌─────────────────────┐
                    │  TERMUX MCP SERVER  │
                    │  tools + validation │
                    └──────────┬──────────┘
                               │
                               │ Termux:API
                               ▼
                    ┌─────────────────────┐
                    │     📱 ANDROID      │
                    │ 📷 🔊 📍 📋 🔋 📡 │
                    └─────────────────────┘
```

The result is a local bridge between **AI reasoning and Android capabilities**.

---

# 🚀 One command. Full AI stack.

If you want the complete **Termux MCP + 9Router + Pi** experience, don't install everything manually.

### 1️⃣ Install the Android prerequisites once

Install:

- **Termux**
- **Termux:API**

The Android apps must be installed separately; the shell bootstrap cannot install APKs. The bootstrap installs the Termux-side `termux-api` package.

### 2️⃣ Paste this ONE command into Termux

```bash
curl -fsSL https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh | bash
```

That's it. The installer is **interactive, ordered, fail-fast and rerunnable**.

> 🔐 **Security:** this is a convenience installer for a repository you trust. If you want to inspect it first, open [`scripts/bootstrap-ai-agent.sh`](scripts/bootstrap-ai-agent.sh) and run it locally instead of piping it to Bash.

---

# 🧬 What the one-shot installer actually does

The pipeline is intentionally ordered so each layer is available before the next layer depends on it:

```text
┌──────────────────────────────────────────────────────────────┐
│                 🟢 ONE-SHOT BOOTSTRAP                       │
└─────────────────────────────┬────────────────────────────────┘
                              │
                              ▼
                    Update / upgrade Termux
                              │
                              ▼
             Git + Node.js + curl + Termux:API
                              │
                              ▼
                 Clone / fast-forward repo
                              │
                              ▼
                    Install 9Router latest
                              │
                              ▼
                    Install Pi Coding Agent
                              │
                              ▼
                     Install pi-9router-ext
                              │
                              ▼
              Configure NINE_ROUTER_* environment
                              │
                              ▼
                  npm install — MCP server
                              │
                              ▼
                    Start `9router --tray`
                              │
                              ▼
                     Health-check `/v1/models`
                              │
                              ▼
                  Discover live model catalogue
                              │
                              ▼
                         Launch Pi
                              │
                              ▼
                 🆓 CONNECT A FREE ROUTE
                              │
                              ▼
                     /9router-models
                              │
                              ▼
                      SELECT A MODEL
                              │
                              ▼
                         🤖 CODE
                              │
                              ▼
                       📱 ANDROID
```

### What gets installed/configured

| Component | Purpose |
|---|---|
| Git | Clone/update the repository |
| Node.js | Runtime for MCP, 9Router and Pi |
| curl | Router health/model checks |
| Termux:API | Android capability bridge |
| 9Router latest | Local model routing/proxy |
| `9router --tray` | Background local router process |
| Pi Coding Agent | Terminal coding-agent harness |
| `pi-9router-ext` | 9Router provider/model integration for Pi |
| `NINE_ROUTER_BASE_URL` | Local router endpoint |
| `NINE_ROUTER_API_KEY` | Local router credential |
| MCP dependencies | Runtime for Termux MCP Server |

The bootstrap checks the Node.js version needed by the current Pi package and stops with a useful error rather than continuing with a broken installation.

---

# 🧑‍🚀 The interactive experience

The installer doesn't silently blast through everything. It guides the user:

```text
╔══════════════════════════════════════════════════════╗
║       🤖 TERMUX AI AGENT — ONE-SHOT SETUP           ║
║  MCP + Termux:API + 9Router + Pi + Free Models     ║
╚══════════════════════════════════════════════════════╝

Continue with the full installation? [Y/n]

Default router URL: http://localhost:20128
Press Enter to keep it, or enter another URL:

Enter your local 9Router API key:

Launch Pi now? [Y/n]
```

It also verifies the stack before declaring success.

---

# 🆓 Connect a free model and start building

When setup completes, you can launch Pi immediately or later:

```bash
source ~/.profile
pi
```

Inside Pi:

```text
/9router-status
/9router-config
/9router-reload
/9router-models
```

Select **any free provider/model currently available to you** in the live 9Router dashboard. Availability changes, so the project intentionally does not hard-code a model that may disappear.

Then select the discovered model:

```text
/model 9router/<model-id>
```

### 🎉 Now enjoy it

```text
🧠 FREE / AVAILABLE MODEL
          ↓
   🤖 Pi Coding Agent
          ↓
      🌐 9Router
          ↓
       Termux
          ↓
   📱 MCP capabilities
          ↓
       Android
```

Try asking your agent:

```text
Inspect this repository, understand the architecture, find the biggest engineering issue, and fix it safely.
```

Then connect the Termux MCP server to your MCP-capable client and combine coding-agent reasoning with Android actions.

---

# 🧠 Give another AI one instruction

Copy this into an AI coding agent that can operate your Termux environment:

```text
Set up the complete Termux AI stack end-to-end: verify Termux + Termux:API are installed, run https://raw.githubusercontent.com/yashas-13/termux-mcp-server/main/scripts/bootstrap-ai-agent.sh, install Git/Node.js/curl/termux-api, clone or update termux-mcp-server, install 9router@latest and start `9router --tray` on localhost:20128, install Pi Coding Agent and `pi-9router-ext`, configure NINE_ROUTER_BASE_URL and the user's local NINE_ROUTER_API_KEY, install the MCP dependencies, verify `/v1/models`, launch Pi, run `/9router-config`, `/9router-reload` and `/9router-models`, guide the user to connect any currently available free provider and select a discovered `9router/<model-id>`, then verify the Termux MCP tools; keep credentials private, keep 9Router local, and test read-only capabilities before side-effecting tools.
```

---

# 📱 What can your agent control?

| Tool | Capability | What it does |
|---|---|---|
| `battery_status` | 🔋 Battery | Read battery state and percentage |
| `vibrate` | 📳 Hardware | Vibrate the device |
| `torch` | 🔦 Hardware | Toggle the flashlight |
| `camera_capture` | 📸 Camera | Capture a photo |
| `clipboard_get` | 📋 Clipboard | Read clipboard contents |
| `clipboard_set` | ✍️ Clipboard | Write clipboard contents |
| `toast` | 🔔 UI | Show a device toast |
| `tts_speak` | 🔊 TTS | Speak text aloud |
| `wifi_info` | 📶 Network | Get Wi-Fi connection information |
| `sms_send` | 📱 Messaging | Send an SMS |
| `sms_list` | 📥 Messaging | Read SMS messages |
| `contact_list` | 👤 Contacts | List device contacts |
| `location_get` | 📍 Location | Read GPS/network location |
| `notification_list` | 🔔 Notifications | List current notifications |
| `sensor_list` | 🧭 Sensors | List available sensors |
| `sensor_data` | 📡 Sensors | Read a sensor sample |
| `share_text` | 🔗 Sharing | Open Android sharing flow |
| `ocr_image` | 👁️ OCR | Extract text from an image with Tesseract |
| `speak_battery_status` | 🤯 Demo | Read battery status and speak it |

---

# 💥 Try these agent workflows

```text
“Check my battery and tell me whether I should charge the phone.”
```

```text
“Read my clipboard and extract the important URLs.”
```

```text
“Take a photo, run OCR on it, and summarize the text.”
```

```text
“Get my current location and explain the coordinates.”
```

```text
“Read my latest SMS messages and summarize them.”
```

```text
“Speak the current battery percentage aloud.”
```

The real power comes from **composing multiple tools into an agent workflow**.

---

# 🏗️ Architecture

```text
                    ┌──────────────────────┐
                    │      AI CLIENT       │
                    │ Claude / Codex / ... │
                    └──────────┬───────────┘
                               │ MCP
                               ▼
                    ┌──────────────────────┐
                    │  Termux MCP Server   │
                    │        index.js      │
                    ├──────────────────────┤
                    │ tool registry        │
                    │ Zod validation       │
                    │ error handling       │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │      Termux:API      │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │       Android        │
                    └──────────────────────┘
```

For the complete runtime model and request lifecycle, see [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

---

# 📚 Developer documentation

| Document | Purpose |
|---|---|
| [`docs/DEVELOPER_GUIDE.md`](docs/DEVELOPER_GUIDE.md) | Development model, tool design, validation and extension workflow |
| [`docs/TOOL_REFERENCE.md`](docs/TOOL_REFERENCE.md) | Detailed current tool reference, parameters and risk profiles |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Runtime architecture, request lifecycle and data flow |
| [`docs/SECURITY.md`](docs/SECURITY.md) | Threat model, sensitive capabilities and deployment guidance |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Termux, Android, MCP, Node.js and capability diagnostics |
| [`docs/AGENT_BOOTSTRAP.md`](docs/AGENT_BOOTSTRAP.md) | Interactive one-shot Pi + 9Router + MCP installation |
| [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) | Contribution standards, testing and PR checklist |

---

# 🔎 Verify the installation

```bash
command -v git
node --version
command -v termux-battery-status
command -v 9router
command -v pi
pi --version
curl -fsS http://localhost:20128/v1/models
```

Verify Termux:API independently:

```bash
termux-battery-status
termux-clipboard-get
termux-wifi-connectioninfo
```

Inspect the router:

```bash
pgrep -af 9router
cat ~/.9router.pid 2>/dev/null || true
tail -n 50 ~/.9router.log
```

---

# 🔐 Security matters

This project exposes capabilities that can affect a real device and real-world data, including SMS, contacts, location, camera, clipboard and notifications.

Treat the MCP server as a **privileged local integration**.

- Run it on a device you control.
- Review which tools your MCP client can call.
- Keep 9Router on localhost unless secure authenticated remote access is intentionally configured.
- Never commit real API keys or tokens.
- Be especially careful with `sms_send`, contacts, location, camera and clipboard.
- Test read-only capabilities before enabling external side effects.

### ⚠️ Current hardening status

The repository should be hardened further before security-sensitive production use. In particular, command execution should migrate from shell-string execution to argument-safe process execution (`execFile`/equivalent), and high-impact capabilities should have explicit policy/confirmation controls.

**Do not expose the MCP server or local router directly to the public internet.**

---

# 🧪 Development

```bash
npm install
npm start
```

For serious changes verify:

- invalid arguments are rejected
- command failures are reported cleanly
- shell metacharacters cannot escape command boundaries
- sensitive tools are not accidentally enabled by default
- documentation matches actual tool behavior
- credentials never enter commits or public logs

See [`docs/DEVELOPER_GUIDE.md`](docs/DEVELOPER_GUIDE.md) and [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md).

---

# 🗺️ Roadmap

### Near term

- [ ] Replace shell-string execution with safe argument-based process execution
- [ ] Add automated tests
- [ ] Add capability allow/deny policy
- [ ] Add explicit confirmation for high-impact tools
- [ ] Add structured error responses
- [ ] Improve tool metadata and schemas
- [ ] Validate command mappings against current Termux:API

### Next level

- [ ] Calls and dialer controls
- [ ] Better notification actions
- [ ] Media controls
- [ ] File operations
- [ ] Calendar integration
- [ ] More Android intents
- [ ] Device automation profiles
- [ ] Event/trigger support
- [ ] Optional authenticated network transport

### Bigger vision

> **An open Android capability layer for autonomous AI agents.**

One small MCP server → many Android-native capabilities → composable agent workflows.

---

# 💜 Support the project

<div align="center">

## ☕ Fuel the next experiment

If this project helped you build something useful, **help turn the next idea into another Android capability.**

[![💜 Sponsor on GitHub](https://img.shields.io/badge/💜_SPONSOR_ON_GITHUB-EA4AAA?style=for-the-badge)](https://github.com/sponsors/yashas-13)

### `☕ → 💻 → 🤖 → 📱 → 🚀`

**Your support helps maintain the project, improve security, build new Android capabilities, test integrations, and keep the documentation sharp.**

A ⭐ star, 🐛 bug report, 💡 idea, 🔧 pull request, or 📢 share also helps enormously.

</div>

> **Want to fund a capability?** Propose an idea in an issue or discussion. Sponsorship supports maintenance and ambitious experiments but does not guarantee a specific feature or delivery date.

---

# ⭐ Build something your phone can actually do

Your AI already has a brain.

Your Android phone already has a body.

**This project connects them.** 🚀

- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Termux](https://termux.com/)
- [Termux:API](https://github.com/termux/termux-api)
- [Termux:API package](https://github.com/termux/termux-api-package)

## 📄 License

MIT — see [LICENSE](LICENSE).
