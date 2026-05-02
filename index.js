const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require("@modelcontextprotocol/sdk/types.js");
const { z } = require("zod");
const { exec } = require("child_process");
const { promisify } = require("util");

const execPromise = promisify(exec);

const server = new Server(
  {
    name: "termux-api",
    version: "1.0.0",
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
  console.error("Termux API MCP server running on stdio");
}

main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});
