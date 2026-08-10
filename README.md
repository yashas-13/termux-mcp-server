# 🤖 Termux MCP Server — Give Your AI Agent a Body

> **Turn your Android phone into an AI-controlled device.**
>
> Connect Claude Code, Codex, OpenClaw, or any MCP-compatible agent to **Termux:API** and give it real phone capabilities — battery, clipboard, camera, sensors, GPS, TTS, Wi-Fi, notifications, contacts, and SMS.

[![MCP](https://img.shields.io/badge/MCP-compatible-7C3AED?style=for-the-badge)](https://modelcontextprotocol.io/)
[![Android](https://img.shields.io/badge/Android-Termux-34A853?style=for-the-badge)](https://termux.com/)
[![Node.js](https://img.shields.io/badge/Node.js-%3E%3D18-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![License](https://img.shields.io/badge/license-MIT-blue?style=for-the-badge)](LICENSE)

## ⚡ What is this?

Most AI agents can **think**.

Your phone can **see, hear, move, speak, locate, notify, and communicate**.

This project connects the two.

```text
┌───────────────────────────────┐
│        AI AGENT / LLM         │
│ Claude • Codex • OpenClaw     │
└───────────────┬───────────────┘
                │ MCP
                ▼
┌───────────────────────────────┐
│       Termux MCP Server       │
│   typed tools + validation    │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│          Termux:API           │
└───────────────┬───────────────┘
                │
                ▼
┌───────────────────────────────┐
│          Android phone        │
│ camera • GPS • SMS • sensors  │
│ clipboard • torch • TTS • ... │
└───────────────────────────────┘
```

### The result

Your agent can go from:

> “I need information from my phone.”

To actually **interacting with the phone** instead of only describing what you should do.

---

## 🎯 Why this is interesting

### For newcomers

You do not need to understand MCP first.

Install Termux + Termux:API, run the server, connect your AI client, and start experimenting.

### For Termux power users

Turn Android into a scriptable hardware endpoint for your agent.

### For AI developers

Use a small MCP server as a foundation for building richer Android agents, automation systems, and device-aware workflows.

### For hackers and builders

Combine it with your existing agent stack and create things like:

- 📸 **“Take a photo and analyze it.”**
- 📋 **“Read my clipboard and summarize it.”**
- 🔋 **“Check my battery and tell me if I should charge.”**
- 📍 **“Get my current location.”**
- 🔊 **“Read this result aloud.”**
- 🔦 **“Turn on the flashlight.”**
- 📱 **“Send this SMS.”** *(explicitly enable and secure this capability before autonomous use)*
- 🧭 **“Read the available sensors.”**

---

# 🚀 Get started in minutes

## 1. Install Termux

Install **Termux** from a trusted source such as F-Droid.

## 2. Install Termux:API

Install the **Termux:API Android app** and then install the CLI package inside Termux:

```bash
pkg update
pkg install termux-api nodejs git
```

For OCR:

```bash
pkg install tesseract
```

> **Important:** The Termux:API Android app and the `termux-api` CLI package work together. Installing only one is not enough.

## 3. Clone the server

```bash
git clone https://github.com/yashas-13/termux-mcp-server.git
cd termux-mcp-server
npm install
```

## 4. Run it

```bash
npm start
```

The server uses **MCP stdio transport**, so your MCP client launches it as a local process.

---

# 🧠 Connect your AI agent

The server is designed to work with MCP-compatible clients.

A generic configuration looks like:

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

For example, the project can be used as a local MCP server by tools such as Claude Code and other MCP-compatible agent runtimes.

> Your client may use a different configuration file or UI. Keep the `command` and absolute `index.js` path concept the same.

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

Once connected, you can ask your agent things like:

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

The interesting part is not any single tool.

It is the ability to **combine tools into agentic workflows**.

---

# 🧩 Build workflows, not just commands

The real power of MCP appears when the model chains several capabilities:

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

That same pattern can become a much larger Android agent.

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
                    ├──────────────────────┤
                    │ battery              │
                    │ camera               │
                    │ clipboard            │
                    │ contacts             │
                    │ location             │
                    │ notifications        │
                    │ sensors              │
                    │ SMS                  │
                    │ TTS                  │
                    │ Wi-Fi                │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │       Android        │
                    └──────────────────────┘
```

The server is intentionally small: **MCP in, typed tool calls, Termux:API out.**

---

# 🔐 Security matters

This project exposes capabilities that can affect a real device and real-world data.

That includes:

- SMS
- Contacts
- Location
- Camera
- Clipboard
- Notifications
- Device controls

Treat the MCP server as a **privileged local integration**.

### Before using it with an autonomous agent

- Run it on a device you control.
- Review which tools your MCP client is allowed to call.
- Avoid exposing the server to an untrusted network.
- Be especially careful with `sms_send`, contacts, location, camera, and clipboard access.
- Prefer explicit confirmation for actions with external side effects.

### ⚠️ Development status

This repository is an active project and should be hardened further before being treated as a security-sensitive production service.

In particular, command execution should be migrated from shell-string execution to argument-safe process execution (`execFile`/equivalent), and dangerous capabilities should have explicit policy/confirmation controls.

**Do not expose this server directly to the public internet.**

---

# 🔧 Developer guide

## Project structure

```text
termux-mcp-server/
├── index.js          # MCP server + tool registry
├── package.json      # Node.js metadata and scripts
├── package-lock.json # Locked dependency tree
├── README.md         # Documentation
└── LICENSE           # MIT license
```

## Add a new Termux tool

The core pattern is:

```js
{
  name: "example_tool",
  description: "Do something useful with Android.",
  schema: z.object({
    value: z.string().describe("Input value"),
  }),
  handler: async (args) => {
    // Execute the corresponding Termux:API command.
    // Prefer argument-safe process execution for new tools.
  },
}
```

The server exposes the registered tools through MCP and validates incoming arguments with Zod.

---

# 🧪 Local development checklist

Before opening a PR, verify:

```bash
npm install
npm start
```

Then test the tools on a real Termux + Termux:API installation.

For serious changes, also verify:

- invalid arguments are rejected
- command failures are reported cleanly
- shell metacharacters cannot escape the intended command boundary
- sensitive tools are not accidentally enabled by default
- README examples match actual tool behavior

---

# 🗺️ Roadmap

The goal is to turn this from a simple command bridge into a **robust Android agent capability layer**.

### Near term

- [ ] Replace shell-string execution with safe argument-based process execution
- [ ] Add automated tests
- [ ] Add capability allow/deny policy
- [ ] Add explicit confirmation for high-impact tools
- [ ] Add structured error responses
- [ ] Add better tool metadata and schemas
- [ ] Fix and validate all command mappings against current Termux:API

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

# 🤝 Contributing

Have a useful Termux:API integration?

Add it as a focused MCP tool, document the required Android/Termux permissions, test it on-device, and open a pull request.

Good contributions are:

- small and composable
- safe by default
- clearly validated
- documented with examples
- tested against real Termux:API behavior

---

# ⭐ Why star this project?

Because the interesting future of AI is not just:

> “An AI that can write code.”

It is:

> **“An AI that can interact with the world around it.”**

Android is already packed with useful hardware and APIs.

Termux gives us a powerful bridge.

MCP gives agents a standard way to use tools.

This project connects those pieces.

**Build something weird. Build something useful. Build something your phone can actually do.** 🚀

---

## 📚 Learn more

- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Termux](https://termux.com/)
- [Termux:API](https://github.com/termux/termux-api)
- [Termux:API package](https://github.com/termux/termux-api-package)

---

## 📄 License

MIT — see [LICENSE](LICENSE).
