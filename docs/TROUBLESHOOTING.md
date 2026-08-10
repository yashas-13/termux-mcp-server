# Troubleshooting

## 1. `termux-battery-status: command not found`

Install the Termux API package:

```bash
pkg update
pkg install termux-api
```

Also verify that the Termux:API Android application is installed.

Then run:

```bash
which termux-battery-status
termux-battery-status
```

## 2. Termux:API app is installed but commands fail

Check that the Termux and Termux:API installations come from compatible sources. Mixing packages from incompatible distribution channels can cause signature or package integration problems.

Verify the CLI package:

```bash
pkg list-installed | grep termux-api
```

## 3. Permission denied

Android permissions are controlled by the Android application layer.

Open Android settings and review permissions for Termux and Termux:API.

The MCP server cannot grant Android permissions itself.

## 4. Server starts but MCP client cannot connect

Confirm that Node.js works:

```bash
node --version
npm --version
```

Then start the server manually:

```bash
npm start
```

The server uses stdio. It is expected to wait for an MCP client rather than open a browser or HTTP page.

Also make sure the MCP client configuration uses an absolute path to `index.js` where required.

## 5. Tool discovery fails

Check the MCP client logs and confirm the process starts successfully.

Useful checks:

```bash
node index.js
```

The server's normal diagnostic output is written to stderr so that MCP stdout remains available for protocol traffic.

## 6. SMS does not send

Check:

1. Android SMS permission.
2. SIM/service availability.
3. Termux:API installation.
4. Recipient number formatting.
5. Whether the device permits SMS through the current SIM configuration.

Test the underlying command independently:

```bash
termux-sms-send -n "+91XXXXXXXXXX" "Test message"
```

Do not use a real recipient until you have confirmed the workflow is intentional.

## 7. Camera capture fails

Verify camera permission and available camera IDs.

```bash
termux-camera-info
```

Then test:

```bash
termux-camera-photo -c 0 "$HOME/test.jpg"
```

If camera `0` is unavailable, inspect the reported camera IDs.

## 8. Location returns no data

Check Android location permission and device location services.

Try:

```bash
termux-location -p gps -r once
```

GPS may require outdoor visibility and a short acquisition period.

## 9. Sensors fail

List available sensors:

```bash
termux-sensor -l
```

Then request one sample from a specific sensor:

```bash
termux-sensor -n 1 -s "SENSOR_NAME"
```

Sensor names differ between Android devices.

## 10. OCR fails

Verify Tesseract:

```bash
tesseract --version
```

Then test independently:

```bash
tesseract image.jpg stdout
```

## 11. Clipboard operations fail

Test directly:

```bash
termux-clipboard-set "hello"
termux-clipboard-get
```

Some Android versions impose additional clipboard access restrictions depending on app state.

## 12. TTS does not speak

Test:

```bash
termux-tts-speak "Hello from Termux"
```

Check Android media volume and available text-to-speech engines.

## 13. Wi-Fi information is empty

Test:

```bash
termux-wifi-connectioninfo
```

Android version, Wi-Fi state, location settings, and device vendor restrictions can affect returned information.

## 14. Node dependency problems

Remove and reinstall dependencies:

```bash
rm -rf node_modules
npm install
```

Check the runtime:

```bash
node --version
```

The project currently targets Node.js 18+.

## 15. Tool works manually but fails through MCP

This usually means the boundary between the MCP argument and the Termux command is the problem.

Compare:

```text
Manual CLI
   |
   v
Termux API
```

against:

```text
MCP client
   |
   v
Zod validation
   |
   v
handler
   |
   v
Termux API
```

Check the exact validated arguments and error returned by the handler.

## 16. Security debugging

Never test shell-injection payloads against a device you do not control.

For local development, test that dangerous characters are treated as data rather than shell syntax after migrating to argument-based execution.

## 17. General diagnostic sequence

When a tool fails, debug from the bottom upward:

```text
Android permission/service
        ↓
Termux:API command
        ↓
Node command runner
        ↓
MCP tool handler
        ↓
MCP client configuration
        ↓
AI agent workflow
```

Start with the lowest layer that can independently reproduce the failure.
