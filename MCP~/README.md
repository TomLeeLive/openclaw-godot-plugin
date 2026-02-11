# OpenClaw Godot MCP Server

MCP (Model Context Protocol) server for direct Claude Code integration with Godot.

## Architecture

```
┌─────────────────┐     stdio      ┌──────────────────┐     HTTP      ┌──────────────────┐
│   Claude Code   │ ←───────────→  │  MCP Server      │ ←──────────→  │  Godot Editor    │
│   or Desktop    │    MCP         │  (this package)  │   :27183      │  (MCP Bridge)    │
└─────────────────┘                └──────────────────┘               └──────────────────┘
```

## Prerequisites

1. Godot project with OpenClaw Godot Plugin installed
2. MCP Bridge enabled in Godot (Project > Tools > OpenClaw > Start MCP Bridge)
3. Node.js 18+

## Installation

```bash
cd MCP~
npm install
```

## Usage with Claude Code

```bash
claude mcp add godot -- node /path/to/openclaw-godot-plugin/MCP~/index.js
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GODOT_HOST` | `127.0.0.1` | Godot MCP Bridge host |
| `GODOT_PORT` | `27183` | Godot MCP Bridge port |

## License

MIT License
