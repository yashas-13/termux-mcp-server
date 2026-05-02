# Termux API MCP Server

An MCP server that allows Claude and other AI models to interact with Android hardware features via the Termux API.

## Features

- **Battery**: Get status and percentage.
- **Hardware**: Control torch, vibration, and camera.
- **System**: Get/set clipboard, show toasts, and share text.
- **Sensors**: List and read from available device sensors.
- **Communication**: Send SMS and list contacts/SMS.
- **Location**: Get GPS coordinates.
- **OCR**: Extract text from images using Tesseract.
- **TTS**: Speak text using the system engine.

## Prerequisites

1.  **Termux**: Install from F-Droid.
2.  **Termux:API**: Install the app from F-Droid and the package:
    ```bash
    pkg install termux-api
    ```
3.  **Node.js**:
    ```bash
    pkg install nodejs
    ```
4.  **(Optional) Tesseract**: For OCR features:
    ```bash
    pkg install tesseract
    ```

## Installation

```bash
git clone https://github.com/yashas-13/termux-mcp-server
cd termux-mcp-server
npm install
```

## Configuration

Add the following to your Claude Code MCP configuration (`~/.claude/mcp.json`):

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

## Tools

### Hardware
- `torch`: Toggle flash.
- `vibrate`: Trigger vibration.
- `camera_capture`: Take photos.

### System
- `battery_status`: Get battery level.
- `clipboard_get` / `clipboard_set`: Manage clipboard.
- `toast`: Show screen messages.
- `tts_speak`: Text-to-speech.
- `wifi_info`: Get WiFi details.

### Communication
- `sms_send`: Send text messages.
- `sms_list`: List received messages.
- `contact_list`: List device contacts.

### Sensors & Location
- `location_get`: Get GPS location.
- `sensor_list`: List all sensors.
- `sensor_data`: Read specific sensor.

### Automation
- `ocr_image`: Extract text from files.
- `speak_battery_status`: Combined trick.

## License

MIT
