#!/usr/bin/env node
/**
 * OpenClaw Godot MCP Server
 * Bridges MCP protocol to Godot Plugin via HTTP
 * 
 * Usage with Claude Code:
 *   claude mcp add godot -- node /path/to/MCP~/index.js
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

const GODOT_HOST = process.env.GODOT_HOST || '127.0.0.1';
const GODOT_PORT = process.env.GODOT_PORT || 27183;
const GODOT_URL = `http://${GODOT_HOST}:${GODOT_PORT}`;

// Tool definitions - mirrors Godot plugin tools
const TOOLS = [
  // Scene tools
  { name: 'scene.getCurrent', description: 'Get current scene info', inputSchema: { type: 'object', properties: {} } },
  { name: 'scene.list', description: 'List all scenes in project', inputSchema: { type: 'object', properties: {} } },
  { name: 'scene.open', description: 'Open a scene by path', inputSchema: { type: 'object', properties: { path: { type: 'string' } }, required: ['path'] } },
  { name: 'scene.save', description: 'Save current scene', inputSchema: { type: 'object', properties: {} } },
  { name: 'scene.new', description: 'Create a new scene', inputSchema: { type: 'object', properties: { name: { type: 'string' } } } },
  
  // Node tools
  { name: 'node.find', description: 'Find node by name or path', inputSchema: { type: 'object', properties: { name: { type: 'string' }, path: { type: 'string' } } } },
  { name: 'node.create', description: 'Create a new node', inputSchema: { type: 'object', properties: { type: { type: 'string' }, name: { type: 'string' }, parent: { type: 'string' } }, required: ['type'] } },
  { name: 'node.delete', description: 'Delete a node', inputSchema: { type: 'object', properties: { path: { type: 'string' } }, required: ['path'] } },
  { name: 'node.getData', description: 'Get node data and properties', inputSchema: { type: 'object', properties: { path: { type: 'string' } }, required: ['path'] } },
  { name: 'node.setProperty', description: 'Set node property', inputSchema: { type: 'object', properties: { path: { type: 'string' }, property: { type: 'string' }, value: {} }, required: ['path', 'property', 'value'] } },
  
  // Transform tools
  { name: 'transform.getPosition', description: 'Get node position', inputSchema: { type: 'object', properties: { path: { type: 'string' } }, required: ['path'] } },
  { name: 'transform.setPosition', description: 'Set node position', inputSchema: { type: 'object', properties: { path: { type: 'string' }, x: { type: 'number' }, y: { type: 'number' }, z: { type: 'number' } }, required: ['path'] } },
  
  // Debug tools
  { name: 'debug.tree', description: 'Get scene tree hierarchy', inputSchema: { type: 'object', properties: { depth: { type: 'number' } } } },
  { name: 'debug.screenshot', description: 'Capture screenshot', inputSchema: { type: 'object', properties: { filename: { type: 'string' } } } },
  { name: 'debug.log', description: 'Write to Godot output', inputSchema: { type: 'object', properties: { message: { type: 'string' } }, required: ['message'] } },
  
  // Editor tools
  { name: 'editor.play', description: 'Run the game', inputSchema: { type: 'object', properties: {} } },
  { name: 'editor.stop', description: 'Stop the game', inputSchema: { type: 'object', properties: {} } },
  { name: 'editor.pause', description: 'Pause the game', inputSchema: { type: 'object', properties: {} } },
  { name: 'editor.getState', description: 'Get editor state', inputSchema: { type: 'object', properties: {} } },
  
  // Input simulation
  { name: 'input.simulateKey', description: 'Simulate keyboard input', inputSchema: { type: 'object', properties: { key: { type: 'string' }, pressed: { type: 'boolean' } }, required: ['key'] } },
  { name: 'input.simulateMouse', description: 'Simulate mouse input', inputSchema: { type: 'object', properties: { button: { type: 'string' }, pressed: { type: 'boolean' }, x: { type: 'number' }, y: { type: 'number' } } } },
  { name: 'input.simulateAction', description: 'Simulate input action', inputSchema: { type: 'object', properties: { action: { type: 'string' }, pressed: { type: 'boolean' } }, required: ['action'] } },
  
  // Script tools
  { name: 'script.list', description: 'List scripts in project', inputSchema: { type: 'object', properties: { path: { type: 'string' } } } },
  { name: 'script.read', description: 'Read script content', inputSchema: { type: 'object', properties: { path: { type: 'string' } }, required: ['path'] } },
  
  // Resource tools
  { name: 'resource.list', description: 'List resources in path', inputSchema: { type: 'object', properties: { path: { type: 'string' }, filter: { type: 'string' } } } },
];

class GodotMCPServer {
  constructor() {
    this.server = new Server(
      { name: 'openclaw-godot', version: '1.0.0' },
      { capabilities: { tools: {} } }
    );
    
    this.setupHandlers();
  }
  
  setupHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: TOOLS
    }));
    
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;
      
      try {
        const result = await this.executeGodotTool(name, args || {});
        return {
          content: [{ type: 'text', text: JSON.stringify(result, null, 2) }]
        };
      } catch (error) {
        return {
          content: [{ type: 'text', text: `Error: ${error.message}` }],
          isError: true
        };
      }
    });
  }
  
  async executeGodotTool(tool, args) {
    const url = `${GODOT_URL}/tool`;
    
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ tool, arguments: args })
    });
    
    if (!response.ok) {
      throw new Error(`Godot returned ${response.status}: ${await response.text()}`);
    }
    
    return await response.json();
  }
  
  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('[OpenClaw Godot MCP] Server started');
  }
}

const server = new GodotMCPServer();
server.run().catch(console.error);
