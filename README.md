# 🦞 OpenClaw Godot Plugin

> **TL;DR:** Vibe-code your game development remotely from anywhere! 🌍
> 
> **한줄요약:** 이제 집밖에서도 원격으로 바이브코딩으로 게임 개발 가능합니다! 🎮

Connect Godot 4.x to [OpenClaw](https://github.com/openclaw/openclaw) AI assistant via HTTP.

[![Godot](https://img.shields.io/badge/Godot-4.x-blue?logo=godot-engine)](https://godotengine.org)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-2026.2.3+-green)](https://github.com/openclaw/openclaw)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-support-yellow?logo=buy-me-a-coffee)](https://buymeacoffee.com/tomleelive)

## ⚠️ Disclaimer

This software is in **beta**. Use at your own risk.

- Always backup your project before using
- Test in a separate project first
- The authors are not responsible for any data loss or project corruption

See [LICENSE](LICENSE) for full terms.

## ✨ Features

- 🎬 **Scene Management** - Create, open, save, and inspect scenes
- 🔧 **Node Manipulation** - Create, find, modify, delete nodes
- 🎮 **Input Simulation** - Keyboard, mouse, and action input for game testing
- 📸 **Debug Tools** - Screenshots, scene tree view, console logs
- 🎯 **Editor Control** - Play, stop, pause scenes
- 📜 **Script Access** - List and read GDScript files
- 🔄 **Play Mode Stability** - Maintains connection during Play mode

## Requirements

| Component | Version |
|-----------|---------|
| **Godot** | 4.x |
| **OpenClaw** | 2026.2.3+ |

## Installation

### 1. Install OpenClaw Gateway Extension (Required)

Copy the gateway extension files to OpenClaw:

```bash
# Copy extension files
cp -r OpenClawPlugin~/* ~/.openclaw/extensions/godot/

# Restart gateway to load the extension
openclaw gateway restart

# Verify
openclaw godot status
```

> **Note:** `OpenClawPlugin~` contains the gateway extension that enables `godot_execute` and `godot_sessions` tools.

### 2. Install Godot Plugin

1. Copy `addons/openclaw` folder to your project's `addons/` directory
2. Enable the plugin: `Project → Project Settings → Plugins → OpenClaw → Enable`
3. The plugin will auto-connect to OpenClaw Gateway

### 3. Install OpenClaw Skill (Optional)

```bash
git clone https://github.com/TomLeeLive/openclaw-godot-skill.git ~/.openclaw/workspace/skills/godot-plugin
```

## Available Tools (30 tools, 80+ node types)

### Scene Tools (5)
| Tool | Description |
|------|-------------|
| `scene.getCurrent` | Get current scene info |
| `scene.list` | List all scenes in project |
| `scene.open` | Open a scene by path |
| `scene.save` | Save current scene |
| `scene.create` | Create new scene (Node2D/Node3D/Control) |

### Node Tools (6)
| Tool | Description |
|------|-------------|
| `node.find` | Find nodes by name, type, or group |
| `node.create` | Create a new node (80+ types supported) |
| `node.delete` | Delete a node |
| `node.getData` | Get node info and children |
| `node.getProperty` | Get node property value |
| `node.setProperty` | Set node property value (Vector2/3 supported) |

### Transform Tools (3)
| Tool | Description |
|------|-------------|
| `transform.setPosition` | Set node position |
| `transform.setRotation` | Set node rotation |
| `transform.setScale` | Set node scale |

### Editor Tools (4)
| Tool | Description |
|------|-------------|
| `editor.play` | Play current or custom scene |
| `editor.stop` | Stop playing |
| `editor.pause` | Toggle pause |
| `editor.getState` | Get editor state |

### Debug Tools (3)
| Tool | Description |
|------|-------------|
| `debug.screenshot` | Capture viewport screenshot |
| `debug.tree` | Get scene tree as text |
| `debug.log` | Print to output |

### Console Tools (2)
| Tool | Description |
|------|-------------|
| `console.getLogs` | Get logs from Godot log file |
| `console.clear` | Clear log marker (placeholder) |

### Input Tools (7) - NEW
| Tool | Description |
|------|-------------|
| `input.keyPress` | Press and release a key |
| `input.keyDown` | Press and hold a key |
| `input.keyUp` | Release a key |
| `input.mouseClick` | Click at position (left/right/middle) |
| `input.mouseMove` | Move mouse to position |
| `input.actionPress` | Press an input action |
| `input.actionRelease` | Release an input action |

### Script Tools (2)
| Tool | Description |
|------|-------------|
| `script.list` | List GDScript files |
| `script.read` | Read script content |

### Resource Tools (1)
| Tool | Description |
|------|-------------|
| `resource.list` | List resources by extension |

## Example Usage

### Scene Creation
```
You: Create a 2D platformer scene

OpenClaw: 
[Executes scene.create {rootType: "Node2D", name: "Level1"}]
[Executes node.create {type: "CharacterBody2D", name: "Player"}]
[Executes node.create {type: "Camera2D", name: "Camera", parent: "Player"}]
[Executes transform.setPosition {path: "Player", x: 100, y: 200}]

Done! Created Level1 scene with Player and Camera.
```

### Game Testing with Input
```
You: Test the player movement

OpenClaw:
[Executes editor.play]
[Executes input.keyDown {key: "W"}]  # Move up
[Executes input.keyUp {key: "W"}]
[Executes input.actionPress {action: "jump"}]
[Executes debug.screenshot]
[Executes editor.stop]

Tested player movement. Screenshot attached.
```

### Reading Logs
```
You: Check for errors

OpenClaw:
[Executes console.getLogs {type: "error", limit: 10}]

Found 2 errors:
- ERROR: Node not found: Player
- ERROR: Invalid resource path
```

## Configuration

The plugin connects to `http://localhost:18789` by default (OpenClaw Gateway).

To change, modify `GATEWAY_URL` in `connection_manager.gd`.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Godot Editor                             │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │           OpenClawPlugin (EditorPlugin)                 │ │
│  │           @tool script                                  │ │
│  └──────────────────────┬─────────────────────────────────┘ │
│                         │                                    │
│                         ▼                                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │         ConnectionManager                               │ │
│  │         (HTTP polling, PROCESS_MODE_ALWAYS)             │ │
│  │                                                          │ │
│  │  • Heartbeat: 30s interval                              │ │
│  │  • Auto-reconnect on disconnect                         │ │
│  │  • Maintains connection during Play mode                │ │
│  └──────────────────────┬─────────────────────────────────┘ │
│                         │                                    │
│                         ▼                                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │           Tools (40 tools)                              │ │
│  │                                                          │ │
│  │  • Scene/Node/Transform manipulation                    │ │
│  │  • Input simulation (keyboard, mouse, actions)          │ │
│  │  • Debug tools (screenshot, logs)                       │ │
│  │  • Editor control (play, stop)                          │ │
│  └────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP (port 18789)
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                   OpenClaw Gateway                            │
│                   http://localhost:18789                      │
│                                                               │
│  Endpoints:                                                   │
│  • POST /godot/register  - Register Godot session             │
│  • POST /godot/heartbeat - Keep session alive                 │
│  • GET  /godot/poll      - Poll for commands                  │
│  • POST /godot/result    - Send tool execution results        │
└──────────────────────────────────────────────────────────────┘
```

## File Structure

### Skill vs Extension

| Path | Purpose |
|------|---------|
| `~/.openclaw/workspace/skills/godot-plugin/` | **Skill** - AI learning documents (SKILL.md), workflow patterns, tool usage guide. Includes extension source for distribution. |
| `~/.openclaw/extensions/godot/` | **Extension** - Actual code loaded by Gateway. Implements `godot_execute` and `godot_sessions` tools. |

**Summary:** Skill = AI documentation, Extension = Executable code

### Installation Flow

```
Plugin (OpenClawPlugin~/)  ───copy───→  ~/.openclaw/extensions/godot/
                                └── Manual installation

Skill (extension/)         ───copy───→  ~/.openclaw/extensions/godot/
                                └── install-extension.sh
```

Both paths install the same extension code. Use whichever method is convenient.

## Troubleshooting

### Plugin won't load
- Check Godot version (4.x required)
- Look for parse errors in Output panel
- Ensure all .gd files are present in addons/openclaw/

### Connection issues
- Verify Gateway is running: `openclaw gateway status`
- Check URL: default is `http://localhost:18789`
- Look at OpenClaw dock panel in Godot for status

### Input not working
- Input simulation only works during Play mode
- Ensure the game window has focus
- Check if the action exists in Input Map

### Play mode disconnects
- Plugin uses `PROCESS_MODE_ALWAYS` to stay active
- Heartbeat interval is 30 seconds
- If disconnected, plugin auto-reconnects

## 🔐 Security: Model Invocation Setting

When publishing to ClawHub or installing as a skill, you can configure `disableModelInvocation` in the skill metadata:

| Setting | AI Auto-Invoke | User Explicit Request |
|---------|---------------|----------------------|
| `false` (default) | ✅ Allowed | ✅ Allowed |
| `true` | ❌ Blocked | ✅ Allowed |

### Recommendation for Godot Plugin: **`true`**

**Reason:** During Godot development, it's useful for AI to autonomously perform supporting tasks like checking scene tree, taking screenshots, and inspecting nodes.

**When to use `true`:** For sensitive tools (payments, deletions, message sending, etc.)

```yaml
# Example skill metadata
metadata:
  openclaw:
    disableModelInvocation: true  # Recommended for Godot plugin
```

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## License

MIT License

---

Made with 🦞 by the OpenClaw community
