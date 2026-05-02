const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ErrorCode,
  McpError,
} = require("@modelcontextprotocol/sdk/types.js");
const { z } = require("zod");
const { exec } = require("child_process");
const { promisify } = require("util");
const fs = require("fs").promises;
const path = require("path");

const execPromise = promisify(exec);

/**
 * Robust execution wrapper with error handling
 */
async function safeExec(cmd) {
  try {
    const { stdout, stderr } = await execPromise(cmd);
    if (stderr && stderr.trim()) {
      console.error(`Termux command stderr: ${stderr}`);
    }
    return stdout;
  } catch (error) {
    throw new McpError(
      ErrorCode.InternalError,
      `Termux command failed: ${error.message}`
    );
  }
}

const server = new Server(
  {
    name: "termux-api",
    version: "1.2.0",
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
    schema: z.object({}),
    handler: async () => {
      const stdout = await safeExec("termux-battery-status");
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "vibrate",
    description: "Vibrate the device.",
    schema: z.object({
      duration: z.number().optional().describe("Duration in milliseconds (default 1000)"),
      force: z.boolean().optional().describe("Force vibration even in silent mode"),
    }),
    handler: async (args) => {
      let cmd = "termux-vibrate";
      if (args.duration) cmd += ` -d ${args.duration}`;
      if (args.force) cmd += " -f";
      await safeExec(cmd);
      return {
        content: [{ type: "text", text: "Vibration triggered" }],
      };
    },
  },
  {
    name: "toast",
    description: "Show a toast notification on the device.",
    schema: z.object({
      text: z.string().describe("The text to show"),
      short: z.boolean().optional().describe("Use short duration"),
    }),
    handler: async (args) => {
      let cmd = `termux-toast "${args.text.replace(/"/g, '\\"')}"`;
      if (args.short) cmd += " -s";
      await safeExec(cmd);
      return {
        content: [{ type: "text", text: "Toast shown" }],
      };
    },
  },
  {
    name: "tts_speak",
    description: "Speak text using the system's text-to-speech engine.",
    schema: z.object({
      text: z.string().describe("The text to speak"),
    }),
    handler: async (args) => {
      await safeExec(`termux-tts-speak "${args.text.replace(/"/g, '\\"')}"`);
      return {
        content: [{ type: "text", text: "Speaking: " + args.text }],
      };
    },
  },
  {
    name: "torch",
    description: "Toggle the device torch/flash.",
    schema: z.object({
      on: z.boolean().describe("Turn torch on or off"),
    }),
    handler: async (args) => {
      await safeExec(`termux-torch ${args.on ? "on" : "off"}`);
      return {
        content: [{ type: "text", text: `Torch turned ${args.on ? "on" : "off"}` }],
      };
    },
  },
  {
    name: "clipboard_get",
    description: "Get the current content of the system clipboard.",
    schema: z.object({}),
    handler: async () => {
      const stdout = await safeExec("termux-clipboard-get");
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "clipboard_set",
    description: "Set the content of the system clipboard.",
    schema: z.object({
      text: z.string().describe("The text to copy to clipboard"),
    }),
    handler: async (args) => {
      await safeExec(`termux-clipboard-set "${args.text.replace(/"/g, '\\"')}"`);
      return {
        content: [{ type: "text", text: "Clipboard updated" }],
      };
    },
  },
  {
    name: "sms_send",
    description: "Send an SMS message.",
    schema: z.object({
      number: z.string().describe("Phone number to send to"),
      message: z.string().describe("Message content"),
    }),
    handler: async (args) => {
      await safeExec(`termux-sms-send -n ${args.number} "${args.message.replace(/"/g, '\\"')}"`);
      return {
        content: [{ type: "text", text: `SMS sent to ${args.number}` }],
      };
    },
  },
  {
    name: "sms_list",
    description: "List SMS messages.",
    schema: z.object({
      limit: z.number().optional().describe("Limit number of messages"),
      offset: z.number().optional().describe("Offset in message list"),
    }),
    handler: async (args) => {
      let cmd = "termux-sms-list";
      if (args.limit) cmd += ` -l ${args.limit}`;
      if (args.offset) cmd += ` -o ${args.offset}`;
      const stdout = await safeExec(cmd);
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "contact_list",
    description: "List phone contacts.",
    schema: z.object({}),
    handler: async () => {
      const stdout = await safeExec("termux-contact-list");
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "location_get",
    description: "Get current GPS location.",
    schema: z.object({
      provider: z.enum(["gps", "network", "passive"]).optional().describe("Location provider"),
      request: z.enum(["once", "last", "updates"]).optional().describe("Request type"),
    }),
    handler: async (args) => {
      let cmd = "termux-location";
      if (args.provider) cmd += ` -p ${args.provider}`;
      if (args.request) cmd += ` -r ${args.request}`;
      const stdout = await safeExec(cmd);
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "notification_list",
    description: "List current notifications.",
    schema: z.object({}),
    handler: async () => {
      const stdout = await safeExec("termux-notification-list");
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "wifi_info",
    description: "Get WiFi connection information.",
    schema: z.object({}),
    handler: async () => {
      const stdout = await safeExec("termux-wifi-connectioninfo");
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "camera_capture",
    description: "Take a photo with the device camera.",
    schema: z.object({
      camera_id: z.string().optional().describe("Camera ID (usually 0 for back, 1 for front)"),
      output_file: z.string().describe("Path to save the photo"),
    }),
    handler: async (args) => {
      let cmd = `termux-camera-photo -c ${args.camera_id || "0"} "${args.output_file}"`;
      await safeExec(cmd);
      return {
        content: [{ type: "text", text: `Photo saved to ${args.output_file}` }],
      };
    },
  },
  {
    name: "ocr_image",
    description: "Perform OCR on an image file using Tesseract.",
    schema: z.object({
      image_path: z.string().describe("Path to the image file"),
    }),
    handler: async (args) => {
      const stdout = await safeExec(`tesseract "${args.image_path}" stdout`);
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "share_text",
    description: "Share text with other applications.",
    schema: z.object({
      text: z.string().describe("Text to share"),
      title: z.string().optional().describe("Share dialog title"),
    }),
    handler: async (args) => {
      let cmd = `termux-share -a edit -t "${args.title || "Share Text"}" "${args.text.replace(/"/g, '\\"')}"`;
      await safeExec(cmd);
      return {
        content: [{ type: "text", text: "Share dialog opened" }],
      };
    },
  },
  {
    name: "sensor_data",
    description: "Get data from a specific sensor (one-shot).",
    schema: z.object({
      sensor: z.string().describe("Sensor name (from sensor_list)"),
    }),
    handler: async (args) => {
      // termux-sensor -n 1 returns one sample
      const stdout = await safeExec(`termux-sensor -n 1 -s "${args.sensor}"`);
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "sensor_list",
    description: "List available sensors.",
    schema: z.object({}),
    handler: async () => {
      const stdout = await safeExec("termux-sensor -l");
      return {
        content: [{ type: "text", text: stdout }],
      };
    },
  },
  {
    name: "speak_battery_status",
    description: "Combined trick: Check battery status and speak it out loud.",
    schema: z.object({}),
    handler: async () => {
      const stdout = await safeExec("termux-battery-status");
      const battery = JSON.parse(stdout);
      const text = `Battery is at ${battery.percentage} percent and is ${battery.status}.`;
      await safeExec(`termux-tts-speak "${text}"`);
      return {
        content: [{ type: "text", text: text }],
      };
    },
  },
];

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: TOOLS.map(({ name, description, schema }) => ({
    name,
    description,
    inputSchema: {
      type: "object",
      properties: schema.shape ? Object.fromEntries(
        Object.entries(schema.shape).map(([k, v]) => [
          k,
          {
            type: v._def.typeName.toLowerCase().replace("zod", ""),
            description: v.description,
            ...(v instanceof z.ZodEnum ? { enum: v._def.values } : {}),
          }
        ])
      ) : {},
      required: schema.shape ? Object.entries(schema.shape)
        .filter(([_, v]) => !v.isOptional())
        .map(([k, _]) => k) : [],
    },
  })),
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  try {
    const tool = TOOLS.find((t) => t.name === request.params.name);
    if (!tool) {
      throw new McpError(ErrorCode.MethodNotFound, `Tool not found: ${request.params.name}`);
    }

    const validatedArgs = tool.schema.parse(request.params.arguments || {});
    return tool.handler(validatedArgs);
  } catch (error) {
    if (error instanceof z.ZodError) {
      throw new McpError(
        ErrorCode.InvalidParams,
        `Invalid arguments: ${error.errors.map(e => `${e.path}: ${e.message}`).join(", ")}`
      );
    }
    throw error;
  }
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
