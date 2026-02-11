# OpenClaw Godot Plugin - Setup Guide

This guide explains how to set up the OpenClaw Godot Plugin for different use cases.

## 🅰️ Mode A: OpenClaw Gateway (Remote Access)

**When to use:** When you want to develop games remotely via Telegram, Discord, or web.

### Setup Steps

```bash
# 1. Install OpenClaw
npm install -g openclaw

# 2. Start Gateway
openclaw gateway start

# 3. Install Godot Plugin
#    Copy addons/openclaw to your project's addons folder

# 4. Enable Plugin
#    Project > Project Settings > Plugins > OpenClaw > Enable

# 5. Configure chat integration (optional)
openclaw config
```

### How it works

```
┌──────────────┐      ┌─────────────────┐      ┌──────────────┐
│  Telegram/   │ ───→ │    OpenClaw     │ ───→ │    Godot     │
│  Discord/Web │ ←─── │    Gateway      │ ←─── │    Editor    │
└──────────────┘      └─────────────────┘      └──────────────┘
     Phone              Your Computer           Your Computer
```

### Example Usage

From your phone:
```
You: "What nodes are in the current scene?"
AI: Found 8 nodes: Node2D, Sprite2D, Player, Enemy, ...

You: "Move Player to (100, 200)"
AI: Done. Player moved to (100, 200)

You: "Run the game"
AI: Game started
```

---

## 🅱️ Mode B: MCP Direct (Local Development)

**When to use:** When you want to use Claude Code or Cursor to directly control Godot.

### Setup Steps

```bash
# 1. Install Godot Plugin (same as above)

# 2. Install MCP server dependencies
cd /path/to/openclaw-godot-plugin/MCP~
npm install

# 3. Register MCP server with Claude Code
claude mcp add godot -- node /full/path/to/openclaw-godot-plugin/MCP~/index.js

# 4. Enable MCP Bridge in Godot
#    Project > Tools > OpenClaw > Start MCP Bridge

# 5. Use Claude Code
claude
```

### How it works

```
┌──────────────┐      ┌─────────────────┐      ┌──────────────┐
│ Claude Code  │ ───→ │   MCP Server    │ ───→ │    Godot     │
│ or Desktop   │ ←─── │   (Node.js)     │ ←─── │    Editor    │
└──────────────┘      └─────────────────┘      └──────────────┘
    Terminal             localhost:27183        localhost:27183
```

### Example Usage

```
$ claude
> List all scenes in the project
AI: Found 5 scenes: main.tscn, player.tscn, enemy.tscn, ...

> Create a Sprite2D node named "Background"
AI: Created Sprite2D node "Background"

> Run the game and press Space
AI: Game running, simulating Space key
```

---

## 🔀 Hybrid Mode (Both)

Both modes can run simultaneously.

| Service | Default Port |
|---------|--------------|
| MCP Bridge | 27183 |
| OpenClaw Gateway | 18789 |

---

## Quick Reference

| Task | Command |
|------|---------|
| Start Gateway | `openclaw gateway start` |
| Add MCP to Claude | `claude mcp add godot -- node /path/to/MCP~/index.js` |
| Start MCP Bridge | Project > Tools > OpenClaw > Start MCP Bridge |
