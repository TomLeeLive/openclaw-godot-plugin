# Changelog

All notable changes to OpenClaw Godot Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.3] - 2026-02-09

### Added
- Buy Me a Coffee support (`.github/FUNDING.yml`)
- Sponsor badge in README

### Changed
- Branding: Updated emoji from 🐾 to 🦞 (completed)

## [1.2.2] - 2026-02-09

### Changed
- Branding: Updated emoji from 🐾 to 🦞

## [1.2.1] - 2026-02-08

### Added
- Documentation: Skill vs Extension file structure explanation in README

### Fixed
- Synced extension version across plugin and skill

## [1.2.0] - 2026-02-08

### Improved
- `node.create` now supports 80+ node types (previously ~18)
  - Added: CSG nodes (CSGBox3D, CSGSphere3D, CSGCylinder3D, etc.)
  - Added: UI nodes (ColorRect, TextureRect, Panel, containers, etc.)
  - Added: Physics nodes (StaticBody2D/3D, CollisionShape2D/3D, etc.)
  - Added: Audio nodes (AudioStreamPlayer, AudioStreamPlayer2D/3D)
  - Added: Particle nodes (GPUParticles2D/3D, CPUParticles2D/3D)
  - Added: Many more (MeshInstance3D, TileMap, Line2D, etc.)
- Unknown types now return error instead of silently creating Node

### Fixed
- Removed `Tween.new()` (not supported in Godot 4.x - use `create_tween()`)

## [1.1.0] - 2026-02-08

### Added
- `scene.create` - Create new scenes programmatically (Node2D/Node3D/Control)
- `console.getLogs` - Read Godot log files with filtering
- `console.clear` - Clear log marker (placeholder)
- Input simulation tools (7 tools):
  - `input.keyPress` - Press and release a key
  - `input.keyDown` - Press and hold a key
  - `input.keyUp` - Release a key
  - `input.mouseClick` - Click at position
  - `input.mouseMove` - Move mouse to position
  - `input.actionPress` - Press an input action
  - `input.actionRelease` - Release an input action

### Fixed
- Vector2/Vector3 conversion in `node.setProperty` - dictionaries now auto-convert
- `scene.save` using ResourceSaver instead of EditorInterface (no progress dialog error)
- `scene.open` void return handling for Godot 4.x
- HTTP request concurrency issues with polling flags

### Improved
- Play mode connection stability with `PROCESS_MODE_ALWAYS`
- Heartbeat interval reduced to 30 seconds

## [1.0.0] - 2026-02-08

### Added
- Initial release with 30 tools
- Scene tools: getCurrent, list, open, save
- Node tools: find, create, delete, getData, getProperty, setProperty
- Transform tools: setPosition, setRotation, setScale
- Editor tools: play, stop, pause, getState
- Debug tools: screenshot, tree, log
- Script tools: list, read
- Resource tools: list
- HTTP polling connection to OpenClaw Gateway
- Dock UI with connection status

[1.1.0]: https://github.com/TomLeeLive/openclaw-godot-plugin/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/TomLeeLive/openclaw-godot-plugin/releases/tag/v1.0.0
