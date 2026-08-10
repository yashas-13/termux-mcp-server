# Architecture Reference

## 1. System overview

Termux MCP Server is a local adapter between an MCP-compatible AI client and Android capabilities exposed by Termux:API.

```text
+-----------------------+
| AI agent / MCP client |
+-----------+-----------+
            |
            | MCP over stdio
            v
+-----------------------+
|   Termux MCP Server   |
|-----------------------|
| MCP transport         |
| Tool registry         |
| Zod validation        |
| Tool handlers         |
| Error translation     |
+-----------+-----------+
            |
            | Termux CLI
            v
+-----------------------+
|      Termux:API       |
+-----------+-----------+
            |
            v
+-----------------------+
| Android platform      |
| Camera / GPS / SMS    |
| Sensors / Clipboard   |
| TTS / Wi-Fi / etc.    |
+-----------------------+
```

## 2. Transport

The current server uses `StdioServerTransport` from the MCP SDK.

That means the MCP client normally starts the Node process and communicates through standard input/output.

This is useful for local integrations because the server does not need to listen on a network socket.

## 3. Request lifecycle

A typical tool call follows this sequence:

```text
1. MCP client discovers tools
        |
2. Client sends tools/call
        |
3. Server finds tool by name
        |
4. Zod validates arguments
        |
5. Handler executes capability
        |
6. Termux:API returns output
        |
7. Server converts output to MCP content
        |
8. Client returns result to the agent
```

## 4. Tool registry

The current implementation stores tools in the `TOOLS` array.

Each entry contains:

```text
name
 description
 schema
 handler
```

The registry is used by both `tools/list` and `tools/call`.

## 5. Validation layer

Zod schemas are used to validate incoming arguments before handlers execute.

Example:

```js
schema: z.object({
  provider: z.enum(["gps", "network", "passive"]).optional(),
  request: z.enum(["once", "last", "updates"]).optional(),
})
```

Validation protects the handler from malformed MCP input but should not be considered a complete security boundary. Semantic policy checks are still required for sensitive operations.

## 6. Command execution

The current implementation uses Node's `child_process.exec()` through a promisified wrapper.

Conceptually:

```text
validated MCP argument
        |
        v
command string
        |
        v
shell
        |
        v
Termux command
```

### Hardening direction

For model-controlled arguments, the preferred design is:

```text
validated arguments
        |
        v
command name + argv[]
        |
        v
execFile()
        |
        v
Termux command
```

This removes the shell as an unnecessary interpretation layer and substantially reduces command-injection risk.

## 7. Recommended future component boundaries

A production-oriented implementation should separate responsibilities:

```text
src/
├── server.js
├── tools/
│   ├── battery.js
│   ├── camera.js
│   ├── clipboard.js
│   ├── communications.js
│   └── sensors.js
├── runtime/
│   ├── command-runner.js
│   ├── errors.js
│   └── policy.js
└── schemas/
    └── tool-schemas.js
```

This is a future architecture direction, not a claim about the current repository layout.

## 8. Capability policy

The architecture should eventually support a policy layer between validation and execution:

```text
MCP request
   |
   v
Schema validation
   |
   v
Capability policy
   |
   +---- denied ----> policy error
   |
   v
Safe command runner
   |
   v
Termux:API
```

A policy can classify tools as:

- allow automatically
- require confirmation
- deny

## 9. Data sensitivity

Different capabilities expose different classes of data.

### Low sensitivity

- battery state
- sensor inventory
- torch state

### Moderate sensitivity

- Wi-Fi information
- notifications
- clipboard

### High sensitivity

- contacts
- SMS
- location
- camera output

Security policy should account for both the input and the output of a tool.

## 10. Error model

Failures can originate at several boundaries:

```text
MCP protocol
   |
   +-- invalid tool name
   +-- invalid arguments
   |
   v
Node runtime
   |
   +-- dependency failure
   +-- process failure
   |
   v
Termux
   |
   +-- command missing
   +-- permission denied
   +-- Android service unavailable
   |
   v
Android
   |
   +-- hardware unavailable
   +-- feature disabled
   +-- runtime permission missing
```

Future error handling should preserve the boundary where failure occurred and provide actionable remediation.

## 11. Multi-tool composition

MCP becomes more useful when tools are composed.

Example:

```text
battery_status
      |
      v
agent reasoning
      |
      +---- battery low ----> tts_speak
      |
      +---- battery healthy -> continue
```

Another example:

```text
camera_capture
      |
      v
ocr_image
      |
      v
AI interpretation
      |
      v
tts_speak
```

The server does not need to know the entire workflow. The agent can orchestrate individual capabilities.

## 12. Why stdio first?

A local stdio server has useful security properties:

- no exposed TCP port by default
- simple MCP client lifecycle
- easy local configuration
- fewer network attack surfaces

If network transport is added later, authentication, authorization, replay protection, origin controls, rate limits, and secure transport become mandatory design concerns.

## 13. Architecture goals

The project should evolve toward:

1. Safe command execution.
2. Explicit capability policy.
3. Strong schemas.
4. Structured errors.
5. Automated tests.
6. Clear separation of tools and runtime.
7. Local-first defaults.
8. Explicit confirmation for dangerous actions.
9. Stable tool contracts.
10. Excellent developer documentation.
