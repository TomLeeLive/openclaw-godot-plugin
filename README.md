# 🐾 OpenClaw Godot Plugin

Connect Godot 4.x to [OpenClaw](https://github.com/openclaw/openclaw) AI assistant via HTTP.

[![Godot](https://img.shields.io/badge/Godot-4.x-blue?logo=godot-engine)](https://godotengine.org)
[![OpenClaw](https://img.shields.io/badge/OpenClaw-2026.2.3+-green)](https://github.com/openclaw/openclaw)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## ✨ Features

- 🎬 **Scene Management** - Open, save, and inspect scenes
- 🔧 **Node Manipulation** - Create, find, modify, delete nodes
- 📸 **Debug Tools** - Screenshots, scene tree view
- 🎮 **Editor Control** - Play, stop, pause scenes
- 📜 **Script Access** - List and read GDScript files

## Requirements

| Component | Version |
|-----------|---------|
| **Godot** | 4.x |
| **OpenClaw** | 2026.2.3+ |

## Installation

1. Copy `addons/openclaw` folder to your project's `addons/` directory
2. Enable the plugin: `Project → Project Settings → Plugins → OpenClaw → Enable`
3. The plugin will auto-connect to OpenClaw Gateway

## Available Tools (30)

### Scene Tools
| Tool | Description |
|------|-------------|
| `scene.getCurrent` | Get current scene info |
| `scene.list` | List all scenes in project |
| `scene.open` | Open a scene by path |
| `scene.save` | Save current scene |

### Node Tools
| Tool | Description |
|------|-------------|
| `node.find` | Find nodes by name, type, or group |
| `node.create` | Create a new node |
| `node.delete` | Delete a node |
| `node.getData` | Get node info and children |
| `node.getProperty` | Get node property value |
| `node.setProperty` | Set node property value |

### Transform Tools
| Tool | Description |
|------|-------------|
| `transform.setPosition` | Set node position |
| `transform.setRotation` | Set node rotation |
| `transform.setScale` | Set node scale |

### Editor Tools
| Tool | Description |
|------|-------------|
| `editor.play` | Play current or custom scene |
| `editor.stop` | Stop playing |
| `editor.pause` | Toggle pause |
| `editor.getState` | Get editor state |

### Debug Tools
| Tool | Description |
|------|-------------|
| `debug.screenshot` | Capture viewport screenshot |
| `debug.tree` | Get scene tree as text |
| `debug.log` | Print to output |

### Script Tools
| Tool | Description |
|------|-------------|
| `script.list` | List GDScript files |
| `script.read` | Read script content |

### Resource Tools
| Tool | Description |
|------|-------------|
| `resource.list` | List resources by extension |

## Example Usage

```
You: What nodes are in my scene?

OpenClaw: [Executes debug.tree]

Your scene tree:
▶ Main [Node2D]
  ▶ Player [CharacterBody2D]
    ▶ Sprite [Sprite2D]
    ▶ CollisionShape [CollisionShape2D]
  ▶ TileMap [TileMap]
  ▶ UI [CanvasLayer]
```

```
You: Create a Camera2D at position (100, 200)

OpenClaw: 
[Executes node.create {type: "Camera2D", name: "MainCamera"}]
[Executes transform.setPosition {path: "MainCamera", x: 100, y: 200}]

Done! Created Camera2D "MainCamera" at position (100, 200).
```

## Configuration

The plugin connects to `http://localhost:18789` by default (OpenClaw Gateway).

To change, modify `GATEWAY_URL` in `connection_manager.gd`.

## License

MIT License

---

Made with 🐾 by the OpenClaw community
