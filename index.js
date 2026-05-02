const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require("@modelcontextprotocol/sdk/types.js");
const { z } = require("zod");
const { exec } = require("child_process");
const { promisify } = require("util");
const fs = require("fs").promises;
const path = require("path");

const execPromise = promisify(exec);

const server = new Server(
  {
    name: "termux-api",
    version: "1.1.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

const TOOLS = [
  {
    name: "battery_status",
    description: "Get the current battery status of the device.",
    inputSchema: {
      type: "object",
      properties: {},
    },
    handler: async () => {
      const { stdout } = await execPromise("termux-battery-status");
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "vibrate",
    description: "Vibrate the device.",
    inputSchema: {
      type: "object",
      properties: {
        duration: {
          type: "number",
          description: "Duration in milliseconds (default 1000)",
        },
        force: {
          type: "boolean",
          description: "Force vibration even in silent mode",
        },
      },
    },
    handler: async (args) => {
      let cmd = "termux-vibrate";
      if (args.duration) cmd += ` -d ${args.duration}`;
      if (args.force) cmd += " -f";
      await execPromise(cmd);
      return {
        content: [{ type: "text", text: "Vibration started" }],
      };
    },
  },
  {
    name: "toast",
    description: "Show a toast notification on the device.",
    inputSchema: {
      type: "object",
      properties: {
        text: { type: "string", description: "The text to show" },
        short: { type: "boolean", description: "Use short duration" },
      },
      required: ["text"],
    },
    handler: async (args) => {
      let cmd = `termux-toast "${args.text.replace(/"/g, '\\"')}"`;
      if (args.short) cmd += " -s";
      await execPromise(cmd);
      return {
        content: [{ type: "text", text: "Toast shown" }],
      };
    },
  },
  {
    name: "tts_speak",
    description: "Speak text using the system's text-to-speech engine.",
    inputSchema: {
      type: "object",
      properties: {
        text: { type: "string", description: "The text to speak" },
      },
      required: ["text"],
    },
    handler: async (args) => {
      await execPromise(`termux-tts-speak "${args.text.replace(/"/g, '\\"')}"`);
      return {
        content: [{ type: "text", text: "Speaking: " + args.text }],
      };
    },
  },
  {
    name: "torch",
    description: "Toggle the device torch/flash.",
    inputSchema: {
      type: "object",
      properties: {
        on: { type: "boolean", description: "Turn torch on or off" },
      },
      required: ["on"],
    },
    handler: async (args) => {
      await execPromise(`termux-torch ${args.on ? "on" : "off"}`);
      return {
        content: [{ type: "text", text: `Torch turned ${args.on ? "on" : "off"}` }],
      };
    },
  },
  {
    name: "clipboard_get",
    description: "Get the current content of the system clipboard.",
    inputSchema: {
      type: "object",
      properties: {},
    },
    handler: async () => {
      const { stdout } = await execPromise("termux-clipboard-get");
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "clipboard_set",
    description: "Set the content of the system clipboard.",
    inputSchema: {
      type: "object",
      properties: {
        text: { type: "string", description: "The text to copy to clipboard" },
      },
      required: ["text"],
    },
    handler: async (args) => {
      await execPromise(`termux-clipboard-set "${args.text.replace(/"/g, '\\"')}"`);
      return {
        content: [{ type: "text", text: "Clipboard updated" }],
      };
    },
  },
  {
    name: "sms_send",
    description: "Send an SMS message.",
    inputSchema: {
      type: "object",
      properties: {
        number: { type: "string", description: "Phone number to send to" },
        message: { type: "string", description: "Message content" },
      },
      required: ["number", "message"],
    },
    handler: async (args) => {
      await execPromise(`termux-sms-send -n ${args.number} "${args.message.replace(/"/g, '\\"')}"`);
      return {
        content: [{ type: "text", text: `SMS sent to ${args.number}` }],
      };
    },
  },
  {
    name: "contact_list",
    description: "List phone contacts.",
    inputSchema: {
      type: "object",
      properties: {},
    },
    handler: async () => {
      const { stdout } = await execPromise("termux-contact-list");
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "location_get",
    description: "Get current GPS location.",
    inputSchema: {
      type: "object",
      properties: {
        provider: { type: "string", enum: ["gps", "network", "passive"], description: "Location provider" },
        request: { type: "string", enum: ["once", "last", "updates"], description: "Request type" },
      },
    },
    handler: async (args) => {
      let cmd = "termux-location";
      if (args.provider) cmd += ` -p ${args.provider}`;
      if (args.request) cmd += ` -r ${args.request}`;
      const { stdout } = await execPromise(cmd);
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "wifi_info",
    description: "Get WiFi connection information.",
    inputSchema: {
      type: "object",
      properties: {},
    },
    handler: async () => {
      const { stdout } = await execPromise("termux-wifi-connectioninfo");
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "camera_capture",
    description: "Take a photo with the device camera.",
    inputSchema: {
      type: "object",
      properties: {
        camera_id: { type: "string", description: "Camera ID (usually 0 for back, 1 for front)" },
        output_file: { type: "string", description: "Path to save the photo" },
      },
      required: ["output_file"],
    },
    handler: async (args) => {
      let cmd = `termux-camera-photo -c ${args.camera_id || "0"} "${args.output_file}"`;
      await execPromise(cmd);
      return {
        content: [{ type: "text", text: `Photo saved to ${args.output_file}` }],
      };
    },
  },
  {
    name: "ocr_image",
    description: "Perform OCR on an image file using Tesseract.",
    inputSchema: {
      type: "object",
      properties: {
        image_path: { type: "string", description: "Path to the image file" },
      },
      required: ["image_path"],
    },
    handler: async (args) => {
      const { stdout } = await execPromise(`tesseract "${args.image_path}" stdout`);
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "share_text",
    description: "Share text with other applications.",
    inputSchema: {
      type: "object",
      properties: {
        text: { type: "string", description: "Text to share" },
        title: { type: "string", description: "Share dialog title" },
      },
      required: ["text"],
    },
    handler: async (args) => {
      let cmd = `termux-share -a edit -t "${args.title || "Share Text"}" "${args.text.replace(/"/g, '\\"')}"`;
      await execPromise(cmd);
      return {
        content: [{ type: "text", text: "Share dialog opened" }],
      };
    },
  },
  {
    name: "speak_battery_status",
    description: "Combined trick: Check battery status and speak it out loud.",
    inputSchema: {
      type: "object",
      properties: {},
    },
    handler: async () => {
      const { stdout } = await execPromise("termux-battery-status");
      const battery = JSON.parse(stdout);
      const text = `Battery is at ${battery.percentage} percent and is ${battery.status}.`;
      await execPromise(`termux-tts-speak "${text}"`);
      return {
        content: [{ type: "text", text: text }],
      };
    },
  },
];

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: TOOLS.map(({ handler, ...tool }) => tool),
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const tool = TOOLS.find((t) => t.name === request.params.name);
  if (!tool) {
    throw new Error(`Tool not found: ${request.params.name}`);
  }
  return tool.handler(request.params.arguments || {});
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Termux API MCP server v1.1.0 running on stdio");
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});
