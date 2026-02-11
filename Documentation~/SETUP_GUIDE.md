# OpenClaw Godot Plugin - Setup Guide

This guide explains how to set up the OpenClaw Godot Plugin for different use cases.

## 🎯 What is This?

The OpenClaw Godot Plugin connects your Godot Editor to an AI assistant, enabling **AI-assisted game development**. Think of it as having a coding partner who can:

- Inspect and modify your scene tree
- Create nodes, adjust transforms, set properties
- Run your game and simulate input
- Take screenshots and read logs
- All through natural conversation!

## 🤔 Which Mode Do I Need?

Before diving into setup, understand which mode fits your workflow:

| How You Use AI | Mode Needed | Why |
|----------------|-------------|-----|
| **Chat apps** (Telegram, Discord) | Mode A: Gateway | OpenClaw routes commands to Godot |
| **Claude Code** in terminal | Mode B: MCP | Direct connection needed |
| **Cursor / VS Code** | Mode B: MCP | Direct connection needed |
| **Claude Desktop** app | Mode B: MCP | Direct connection needed |
| **Both** | Hybrid | Best of both worlds |

### If You Already Use OpenClaw...

If you're chatting with an AI assistant through OpenClaw (like Telegram or Discord), **you don't need MCP setup** - the assistant already has Godot tools via the Gateway!

```
You (Telegram) → OpenClaw Gateway → AI Assistant → godot_execute tool → Godot
                                    ↑
                            Already has access!
```

### When MCP is Useful

MCP (Model Context Protocol) is useful when:
1. **Using Claude Code directly** in terminal (not through OpenClaw)
2. **Using Claude Desktop** app
3. **Using Cursor** or other MCP-compatible editors
4. **Spawning Claude Code as sub-agent** from OpenClaw for coding + testing workflows

```
# Without MCP:
$ claude
> Control Godot  →  ❌ No tools available

# With MCP:
$ claude
> Control Godot  →  ✅ godot.* tools available
```

---

## 🅰️ Mode A: OpenClaw Gateway (Remote Access)

**When to use:** When you want to develop games remotely via Telegram, Discord, or web.

### Prerequisites

- Node.js 18+
- Godot 4.x
- OpenClaw installed (`npm install -g openclaw`)

### Setup Steps

#### Step 1: Install OpenClaw Gateway

```bash
# Install OpenClaw globally
npm install -g openclaw

# Initialize configuration (first time only)
openclaw init

# Start the Gateway
openclaw gateway start
```

#### Step 2: Install Gateway Extension

The extension enables `godot_execute` and `godot_sessions` tools in OpenClaw.

```bash
# Clone the plugin repository
git clone https://github.com/TomLeeLive/openclaw-godot-plugin.git

# Copy extension files to OpenClaw
cp -r openclaw-godot-plugin/OpenClawPlugin~/* ~/.openclaw/extensions/godot/

# Restart Gateway to load the extension
openclaw gateway restart

# Verify installation
openclaw godot status
```

#### Step 3: Install Godot Plugin

1. Copy `addons/openclaw` folder to your Godot project's `addons/` directory
2. Open your project in Godot
3. Enable the plugin: `Project → Project Settings → Plugins → OpenClaw → Enable`
4. The plugin automatically connects to OpenClaw Gateway

#### Step 4: Verify Connection

1. Check the Output panel for: `[OpenClaw] Connected to Gateway`
2. Or run: `openclaw godot sessions` to see your Godot instance

#### Step 5: Configure Chat Integration (Optional)

Set up Telegram, Discord, or other chat platforms:

```bash
openclaw config
```

### Architecture

```
┌──────────────┐      ┌─────────────────┐      ┌──────────────┐
│  Telegram/   │ ───→ │    OpenClaw     │ ───→ │    Godot     │
│  Discord/Web │ ←─── │    Gateway      │ ←─── │    Editor    │
└──────────────┘      └─────────────────┘      └──────────────┘
     Phone              Your Computer           Your Computer
   (Anywhere)           (port 18789)            (HTTP polling)
```

### Example Usage

From your phone at a café:
```
You: "What's in my current scene?"
AI: TestScene3D contains: Player (CharacterBody3D), Camera3D, DirectionalLight3D

You: "Add an enemy at position 10, 0, 5"
AI: [Creates Node3D "Enemy" at (10, 0, 5)]
    Done! Enemy created.

You: "Run the game and take a screenshot"
AI: [Plays scene, captures screenshot]
    Here's the gameplay screenshot.
```

---

## 🅱️ Mode B: MCP Direct (Local Development)

**When to use:** When you want to use Claude Code, Claude Desktop, or Cursor to directly control Godot.

### Prerequisites

- Node.js 18+
- Godot 4.x
- Claude Code or MCP-compatible client

### Setup Steps

#### Step 1: Install Godot Plugin

Same as Mode A Step 3:
1. Copy `addons/openclaw` to your project's `addons/` folder
2. Enable: `Project → Project Settings → Plugins → OpenClaw → Enable`

#### Step 2: Install MCP Server Dependencies

```bash
# Navigate to MCP server directory
cd /path/to/openclaw-godot-plugin/MCP~

# Install dependencies
npm install
```

#### Step 3: Register MCP Server

**For Claude Code:**
```bash
claude mcp add godot -- node /full/path/to/openclaw-godot-plugin/MCP~/index.js
```

**For Claude Desktop:**

Edit `~/Library/Application Support/Claude/claude_desktop_config.json` (Mac) or `%APPDATA%\Claude\claude_desktop_config.json` (Windows):

```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["/full/path/to/openclaw-godot-plugin/MCP~/index.js"]
    }
  }
}
```

**For Cursor:**

Edit your `.cursor/mcp.json`:
```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["/full/path/to/openclaw-godot-plugin/MCP~/index.js"]
    }
  }
}
```

#### Step 4: Enable MCP Bridge in Godot

1. Open your Godot project
2. The MCP Bridge starts automatically with the plugin
3. Default port: 27183

#### Step 5: Use Claude Code

```bash
$ claude

> List all scenes in the project
AI: Found 5 scenes: main.tscn, player.tscn, enemy.tscn, level1.tscn, ui.tscn

> Create a CharacterBody2D node named "Player" with a Sprite2D child
AI: [Creates CharacterBody2D "Player"]
    [Creates Sprite2D under "Player"]
    Done! Player node with Sprite2D child created.

> Run the game and press W key
AI: [Starts game]
    [Simulates W key press]
    Game running with W key pressed.
```

### Architecture

```
┌──────────────┐      ┌─────────────────┐      ┌──────────────┐
│ Claude Code  │ ───→ │   MCP Server    │ ───→ │    Godot     │
│ / Desktop    │ ←─── │   (Node.js)     │ ←─── │    Editor    │
│ / Cursor     │      │                 │      │              │
└──────────────┘      └─────────────────┘      └──────────────┘
    Terminal             localhost:27183        localhost:27183
```

---

## 🔀 Hybrid Mode (Both)

You can run both modes simultaneously without conflicts!

```
At home:   Claude Code → MCP → Godot (local, fast)
Outside:   Telegram → OpenClaw Gateway → Godot (remote)
```

### Port Configuration

| Service | Default Port | Description |
|---------|--------------|-------------|
| MCP Bridge | 27183 | For Claude Code / Desktop / Cursor |
| OpenClaw Gateway | 18789 | For Telegram / Discord / Web |

---

## 🔧 Configuration

### Changing Gateway URL

Edit `addons/openclaw/connection_manager.gd`:
```gdscript
const GATEWAY_URL = "http://localhost:18789"  # Change if needed
```

### Changing MCP Port

Edit `addons/openclaw/mcp_bridge.gd`:
```gdscript
const MCP_PORT = 27183  # Change if needed
```

---

## 🛠️ Troubleshooting

### Plugin won't load

1. Check Godot version (4.x required)
2. Look for parse errors in Output panel
3. Ensure all `.gd` files are present in `addons/openclaw/`

### Gateway connection issues

1. Verify Gateway is running: `openclaw gateway status`
2. Check URL matches: default `http://localhost:18789`
3. Check Output panel for `[OpenClaw]` messages
4. Verify extension is installed: `ls ~/.openclaw/extensions/godot/`

### MCP connection issues

1. Check MCP server is registered: `claude mcp list`
2. Verify path is absolute (not relative)
3. Check Godot Output for `[MCP Bridge]` messages
4. Verify port 27183 is not in use: `lsof -i :27183`

### Input simulation not working

1. Input simulation only works during Play mode
2. Ensure the game window has focus
3. For actions, verify the action exists in Input Map

### Play mode disconnects

1. Plugin uses `PROCESS_MODE_ALWAYS` to stay active during Play
2. Heartbeat interval is 30 seconds
3. If disconnected, plugin auto-reconnects

---

## 📋 Quick Reference

| Task | Command |
|------|---------|
| Start Gateway | `openclaw gateway start` |
| Stop Gateway | `openclaw gateway stop` |
| Check Gateway Status | `openclaw gateway status` |
| Check Godot Sessions | `openclaw godot sessions` |
| Add MCP to Claude Code | `claude mcp add godot -- node /path/to/MCP~/index.js` |
| List MCP Servers | `claude mcp list` |

---

## 📖 Next Steps

- [DEVELOPMENT.md](DEVELOPMENT.md) - For contributors
- [TESTING.md](TESTING.md) - Testing guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute

---

Made with 🦞 by the OpenClaw community
