# Contributing

Thanks for helping turn Termux MCP Server into a reliable Android capability layer for AI agents.

## Contribution philosophy

Prefer contributions that are:

- focused
- composable
- secure by default
- easy to test
- easy for AI agents to understand
- documented with real examples

## Before changing code

Understand:

1. The Termux:API command you are wrapping.
2. Required Android permissions.
3. Expected stdout/stderr behavior.
4. Possible failure modes.
5. Whether the capability exposes sensitive data.
6. Whether the operation has an external side effect.

## Adding a tool

A new tool should normally include:

- tool name
- clear description
- Zod schema
- handler
- validation
- error behavior
- user-facing example
- security classification
- documentation update

## Tool naming

Use lowercase `snake_case`.

Good:

```text
battery_status
camera_capture
sensor_data
sms_list
```

Avoid ambiguous names such as:

```text
thing
run
android
helper
```

## Security requirements

Never add a new tool by blindly interpolating model-controlled values into a shell command.

Prefer:

```text
validated arguments
      ↓
command + argv[]
      ↓
execFile()
```

Avoid:

```text
argument
   ↓
string interpolation
   ↓
shell
```

If a tool can send messages, access private information, capture media, share data, or create an external side effect, document that clearly.

## Documentation requirements

Update `docs/TOOL_REFERENCE.md` for every new public tool.

Include:

- purpose
- arguments
- underlying Termux capability
- requirements
- use cases
- security risk
- example

Update the main README when the feature is significant enough to be part of the project's primary story.

## Testing

At minimum test:

### Valid input

The expected command succeeds and the MCP result is correct.

### Invalid input

Malformed values are rejected before command execution.

### Runtime failure

Missing commands, denied permissions, and non-zero exits become understandable errors.

### Security

Arguments containing shell metacharacters must not escape the intended argument boundary.

### Real-device behavior

For Android capabilities, test on an actual Termux + Termux:API installation whenever possible.

## Pull request checklist

- [ ] Code is focused.
- [ ] Inputs are validated.
- [ ] No unnecessary shell execution.
- [ ] Sensitive capabilities are identified.
- [ ] Error behavior is understandable.
- [ ] Tool reference is updated.
- [ ] README is updated if appropriate.
- [ ] Real Termux behavior has been checked.
- [ ] No secrets or private data are committed.

## Commit messages

Prefer concise conventional-style messages:

```text
feat: add media playback tool
fix: validate sensor arguments
security: replace shell command execution
 docs: expand camera tool reference
```

## What makes a great contribution?

A great contribution does more than add another command. It makes the capability reliable for an AI agent.

Think about:

```text
Can the model understand the tool?
Can invalid input be rejected?
Can failures be diagnosed?
Can the action be safely composed?
Can a user understand its permissions?
Can another developer extend it?
```

If the answer is yes, the contribution is probably useful.
