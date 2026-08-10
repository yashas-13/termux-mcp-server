# 🤖 Termux MCP Server — Give Your AI Agent a Body

> **Turn your Android phone into an AI-controlled device.**
>
> Connect Claude Code, Codex, OpenClaw, or any MCP-compatible agent to **Termux:API** and give it real phone capabilities — battery, clipboard, camera, sensors, GPS, TTS, Wi-Fi, notifications, contacts, and SMS.

[![MCP](https://img.shields.io/badge/MCP-compatible-7C3AED?style=for-the-badge)](https://modelcontextprotocol.io/)
[![Android](https://img.shields.io/badge/Android-Termux-34A853?style=for-the-badge)](https://termux.com/)
[![Node.js](https://img.shields.io/badge/Node.js-%3E%3D18-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)
[![Sponsor](https://img.shields.io/badge/💜_Sponsor-GitHub_Sponsors-EA4AAA?style=for-the-badge)](https://github.com/sponsors/yashas-13)

## ⚡ What is this?

Most AI agents can **think**.

Your phone can **see, hear, move, speak, locate, notify, and communicate**.

This project connects the two.

```text
AI AGENT / LLM
      │
      │ MCP
      ▼
Termux MCP Server
      │
      │ Termux:API
      ▼
Android phone
```

### The result

Your agent can go from:

> “I need information from my phone.”

To actually **interacting with the phone** instead of only describing what you should do.

---

## 🎯 Why this is interesting

- 🆕 **Newcomers:** install the prerequisites, connect an MCP client, and start experimenting.
- 📱 **Termux users:** expose Android capabilities as composable agent tools.
- 🧑‍💻 **AI developers:** build device-aware agents on top of MCP.
- 🛠️ **Builders:** combine camera, OCR, sensors, clipboard, TTS, GPS, messaging and device controls into workflows.

---

# 🚀 Zero-to-Agent: copy, paste, go

The following is the **full bootstrap path** for a fresh Termux environment.

> **Prerequisite:** install the Termux Android app and the **Termux:API Android app** first. The Android app and the `termux-api` package work together.

### 🟢 One-shot setup

```bash
pkg update -y && pkg upgrade -y && pkg install -y git nodejs termux-api && git clone https://github.com/yashas-13/termux-mcp-server.git && cd termux-mcp-server && npm install && npm start
```

That command:

```text
1. Updates Termux package metadata
2. Upgrades installed packages
3. Installs Git
4. Installs Node.js
5. Installs the Termux:API CLI package
6. Clones this repository
7. Enters the repository
8. Installs Node dependencies
9. Starts the MCP server
```

### 👁️ Optional OCR support

If you want the `ocr_image` capability:

```bash
pkg install -y tesseract
```

### 🔎 Verify Termux:API before debugging MCP

Run these directly in Termux:

```bash
termux-battery-status
termux-clipboard-get
termux-wifi-connectioninfo
```

If those commands work, the underlying Termux:API bridge is available and you can move on to MCP integration.

---

# 🧠 Connect your AI agent

The server uses **MCP stdio transport**. Your MCP client launches the Node process locally.

Generic configuration:

```json
{
  "mcpServers": {
    "termux": {
      "command": "node",
      "args": [
        "/absolute/path/to/termux-mcp-server/index.js"
      ]
    }
  }
}
```

### 🤖 One-line instruction for an AI coding agent

```text
Integrate https://github.com/yashas-13/termux-mcp-server as a local MCP server: first verify/install Git, Node.js, the Termux:API Android app and the `termux-api` package, then clone the repository, run `npm install`, configure the absolute `index.js` path in the MCP client, start the server, discover all exposed tools, test read-only capabilities first, and only enable side-effecting tools such as SMS after explicit security/permission review.
```

> **Do not blindly give an autonomous agent unrestricted access to SMS, contacts, location, camera, clipboard, or other sensitive capabilities.** Treat the server as a privileged local integration.

---

# 🛠️ What can your agent do?

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

# 💥 The fun starts here

Once connected, try:

```text
“Check the battery and tell me whether I should charge the phone.”
```

```text
“Read my clipboard and extract the important URLs.”
```

```text
“Turn on the flashlight for 5 seconds, then turn it off.”
```

```text
“Take a photo using the back camera.”
```

```text
“Get my current location and explain what the coordinates mean.”
```

```text
“Read the latest SMS messages and summarize them.”
```

```text
“Speak the current battery percentage aloud.”
```

The interesting part is not any single tool. It is the ability to **combine tools into agentic workflows**.

---

# 🧩 Build workflows, not just commands

```text
Trigger
  ↓
Read device state
  ↓
Reason about the result
  ↓
Call another Android capability
  ↓
Return a human-friendly result
```

Example:

```text
Battery check
   ↓
Battery < 20%?
   ↓
Yes
   ↓
Speak warning
   ↓
Show toast
```

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

---

# 📚 Developer documentation

| Document | Purpose |
|---|---|
| [`docs/DEVELOPER_GUIDE.md`](docs/DEVELOPER_GUIDE.md) | Development model, tool design, validation and extension workflow |
| [`docs/TOOL_REFERENCE.md`](docs/TOOL_REFERENCE.md) | Detailed reference for current MCP tools and risk profiles |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Runtime architecture, request lifecycle and data flow |
| [`docs/SECURITY.md`](docs/SECURITY.md) | Threat model, sensitive capabilities and deployment guidance |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Termux, Android, MCP, Node.js and capability diagnostics |
| [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) | Contribution standards, testing and PR checklist |

---

# 🔐 Security matters

This project exposes capabilities that can affect a real device and real-world data, including SMS, contacts, location, camera, clipboard and notifications.

Treat the MCP server as a **privileged local integration**.

- Run it on a device you control.
- Review which tools your MCP client can call.
- Avoid exposing it to an untrusted network.
- Use explicit confirmation for external side effects.
- Be especially careful with `sms_send`, contacts, location, camera and clipboard access.

### ⚠️ Development status

The repository should be hardened further before security-sensitive production use. In particular, command execution should migrate from shell-string execution to argument-safe process execution (`execFile`/equivalent), and dangerous capabilities should have explicit policy/confirmation controls.

**Do not expose this server directly to the public internet.**

---

# 🧪 Development checklist

```bash
npm install
npm start
```

Then test against a real Termux + Termux:API installation.

For serious changes verify:

- invalid arguments are rejected
- command failures are reported cleanly
- shell metacharacters cannot escape command boundaries
- sensitive tools are not accidentally enabled by default
- documentation matches actual tool behavior

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

**No pressure:** a ⭐ star, 🐛 bug report, 💡 idea, 🔧 pull request, or 📢 share also helps enormously.

</div>

> ### 🧪 Want to fund a capability?
> If you're a sponsor and have a feature you'd love to see — propose it in an issue or discussion. Sponsorship helps prioritize maintenance and ambitious new experiments, but does not guarantee a specific feature or delivery date.

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
