# Security Reference

> Security guidance for running Termux MCP Server with AI agents.

## Threat model

The server sits between an AI client and capabilities of a real Android device.

```text
AI model
  |
  | potentially untrusted / model-generated arguments
  v
MCP server
  |
  | privileged device operations
  v
Android
```

The model may make mistakes. A prompt injection, malicious document, compromised MCP client, or incorrect agent plan can cause an unintended tool call.

Treat every tool argument as untrusted input.

## Highest-risk capabilities

### SMS

`sms_send` can create an external communication side effect.

Recommended controls:

- explicit confirmation
- recipient validation
- message length limits
- rate limits
- audit logging
- deny-by-default autonomous policy

### Contacts

`contact_list` exposes personal data. Do not provide contact data to an agent unless the workflow requires it.

### Location

`location_get` can reveal a user's physical location. Treat location output as sensitive personal data.

### Camera

`camera_capture` can capture people, documents, screens, or other private information. Require user awareness and appropriate permissions.

### Clipboard

Clipboard contents may contain credentials, session tokens, payment data, or private messages. Agents should not automatically forward clipboard content to external services.

## Shell execution risk

The current implementation uses `child_process.exec()` for several commands. Some handlers construct shell command strings from MCP-controlled arguments.

This creates a command-injection risk because shell metacharacters can have semantics beyond the intended argument.

### Preferred design

Use argument-based process execution:

```js
execFile("termux-tts-speak", [text])
```

rather than constructing:

```js
exec(`termux-tts-speak "${text}"`)
```

The migration to safe process execution should be treated as a priority before security-sensitive autonomous deployment.

## Local-only recommendation

The current server uses stdio transport and is intended for local MCP client integration.

Do not expose the process through a network wrapper without adding:

- authentication
- authorization
- TLS where appropriate
- capability policies
- rate limiting
- audit logs
- request size limits
- timeout controls
- replay/abuse protections

## Capability policy

A robust deployment should have three policy states:

```text
ALLOW
  Tool executes automatically.

CONFIRM
  User approval is required before execution.

DENY
  Tool is unavailable to the agent.
```

Suggested defaults:

| Capability | Suggested policy |
|---|---|
| battery | ALLOW |
| wifi info | ALLOW |
| sensor list | ALLOW |
| sensor data | ALLOW |
| torch | ALLOW/CONFIRM |
| vibration | ALLOW |
| TTS | ALLOW |
| clipboard read | CONFIRM or restricted |
| clipboard write | CONFIRM |
| notifications | CONFIRM or restricted |
| location | CONFIRM or restricted |
| camera | CONFIRM |
| contacts | CONFIRM |
| SMS read | CONFIRM |
| SMS send | DENY by default / CONFIRM |
| external sharing | CONFIRM |

## Android permissions

Termux:API capabilities depend on Android runtime permissions and device-specific restrictions. The MCP server cannot bypass Android's permission model.

Grant only the permissions required by the workflows you actually use.

## Secret handling

Never place secrets in:

- tool descriptions
- README examples
- source code
- MCP configuration committed to Git
- logs
- screenshots

Do not log raw SMS, contact lists, location, clipboard contents, or camera data unless explicitly required for local debugging.

## Logging

Prefer structured, minimal logs:

```text
INFO tool=battery_status result=success duration_ms=42
WARN tool=sms_send policy=confirmation_required
ERROR tool=camera_capture reason=permission_denied
```

Avoid:

```text
SMS message: ...
Clipboard: ...
Location: ...
```

## Safe deployment checklist

Before connecting an autonomous agent:

- [ ] Termux and Termux:API are from trusted sources.
- [ ] Only required Android permissions are granted.
- [ ] The MCP server is local-only.
- [ ] Dangerous tools have explicit policy controls.
- [ ] SMS sending requires confirmation.
- [ ] Sensitive output is not logged.
- [ ] Shell execution is hardened.
- [ ] Tool arguments have strict validation.
- [ ] Dependencies are locked and reviewed.
- [ ] Tests cover malicious input.

## Responsible use

Use the server only on devices and accounts you are authorized to control. Do not use device capabilities to access another person's private information, send unwanted communications, bypass security controls, or perform unauthorized surveillance.
