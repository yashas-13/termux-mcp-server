# Developer Guide

> Developer reference for building, extending, testing, and integrating Termux MCP Server.

## 1. Project purpose

Termux MCP Server is a local Model Context Protocol (MCP) server that exposes Android capabilities available through Termux:API as MCP tools.

The intended flow is:

```text
AI client / agent
       |
       | MCP
       v
Termux MCP Server
       |
       | Termux CLI commands
       v
Termux:API
       |
       v
Android
```

The project is deliberately small. `index.js` currently contains the MCP server, tool registry, Zod schemas, handlers, and stdio transport.

## 2. Requirements

- Android device
- Termux
- Termux:API Android application
- `termux-api` package inside Termux
- Node.js 18+
- npm
- Git
- Optional: Tesseract for OCR

Install the basic runtime inside Termux:

```bash
pkg update
pkg install nodejs git termux-api
```

For OCR:

```bash
pkg install tesseract
```

## 3. Install the project

```bash
git clone https://github.com/yashas-13/termux-mcp-server.git
cd termux-mcp-server
npm install
npm start
```

The server uses MCP stdio transport. An MCP client normally starts the process itself.

## 4. Repository structure

```text
termux-mcp-server/
├── index.js
├── package.json
├── package-lock.json
├── README.md
├── LICENSE
└── docs/
    ├── DEVELOPER_GUIDE.md
    ├── TOOL_REFERENCE.md
    ├── ARCHITECTURE.md
    ├── SECURITY.md
    ├── TROUBLESHOOTING.md
    └── CONTRIBUTING.md
```

## 5. Tool model

Each tool is represented by an object containing:

```js
{
  name: "tool_name",
  description: "What the tool does",
  schema: z.object({}),
  handler: async (args) => {
    // perform operation
    return {
      content: [{ type: "text", text: "result" }],
    };
  },
}
```

### `name`

Stable MCP tool identifier. Prefer lowercase `snake_case` names.

### `description`

Write a model-friendly description. State what the tool does and avoid vague language.

### `schema`

Zod schema defining accepted arguments. Keep validation close to the tool boundary.

### `handler`

The implementation that maps validated arguments to the underlying Android/Termux operation.

## 6. Adding a new tool

Example concept:

```js
{
  name: "example_tool",
  description: "Perform an example operation.",
  schema: z.object({
    value: z.string().min(1).describe("Value to process"),
  }),
  handler: async (args) => {
    const result = await runCommand([args.value]);
    return {
      content: [{ type: "text", text: result }],
    };
  },
}
```

For new tools, prefer argument-safe process execution such as `execFile` rather than interpolating user-controlled values into shell command strings.

## 7. Input validation

Validate everything supplied by an MCP client.

Good validation should cover:

- required vs optional values
- string length
- numeric ranges
- enumerated values
- filesystem paths
- phone numbers
- identifiers
- mutually exclusive options

Example:

```js
const schema = z.object({
  duration: z.number().int().min(1).max(60000).optional(),
});
```

## 8. Output handling

Termux commands commonly return JSON or text. Preserve machine-readable JSON where practical.

For JSON output:

```js
const raw = await runCommand([]);
const data = JSON.parse(raw);
return {
  content: [{
    type: "text",
    text: JSON.stringify(data, null, 2),
  }],
};
```

Do not silently convert structured data into prose when the agent may need the fields for another tool call.

## 9. Error handling

Errors should tell the caller:

1. which operation failed
2. whether the failure is validation, missing dependency, permission, or runtime failure
3. what the user can do next

Avoid leaking secrets or unnecessary shell internals.

## 10. Tool design guidelines

A good tool should be:

- focused on one capability
- deterministic where possible
- validated
- documented
- safe by default
- easy for an LLM to understand
- composable with other tools

Prefer several small tools over one giant tool with dozens of switches.

## 11. Capability classification

Use these categories when designing future tools:

### Read-only

Examples: battery status, Wi-Fi information, sensor discovery.

### Local device control

Examples: torch, vibration, TTS, clipboard write.

### Sensitive data

Examples: contacts, SMS history, location, clipboard contents.

### External side effects

Examples: SMS sending, sharing, calls, external intents.

Sensitive and side-effecting tools should have stronger validation and, where possible, explicit confirmation or policy controls.

## 12. MCP client integration

A generic stdio configuration is:

```json
{
  "mcpServers": {
    "termux": {
      "command": "node",
      "args": ["/absolute/path/to/termux-mcp-server/index.js"]
    }
  }
}
```

The exact configuration location varies by MCP client.

## 13. Development workflow

Recommended workflow:

```text
Understand capability
        |
        v
Define tool contract
        |
        v
Write validation tests
        |
        v
Implement safe command mapping
        |
        v
Test on real Termux
        |
        v
Document example
        |
        v
Review security impact
```

## 14. Before opening a pull request

Run:

```bash
npm install
npm start
```

Then verify the changed tool against a real Termux + Termux:API installation.

Check:

- valid inputs
- invalid inputs
- missing Android permissions
- missing Termux commands
- command failure
- unexpected output
- shell metacharacters
- sensitive-data exposure
- side effects

## 15. Design direction

The long-term direction is to separate the current monolithic implementation into focused components:

```text
MCP transport
     |
     v
Tool registry
     |
     +--> validation
     |
     +--> capability policy
     |
     +--> safe command runner
     |
     +--> result normalization
     |
     v
Termux adapters
```

This separation will make the server easier to test, secure, and extend.
