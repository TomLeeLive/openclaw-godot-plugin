@tool
extends EditorPlugin
## OpenClaw Plugin for Godot 4.x
## Connects Godot Editor to OpenClaw AI assistant

const ConnectionManager = preload("res://addons/openclaw/connection_manager.gd")
const Tools = preload("res://addons/openclaw/tools.gd")
const MCPBridge = preload("res://addons/openclaw/mcp_bridge.gd")

var connection_manager
var tools
var mcp_bridge
var dock: Control

# Gateway UI
var status_label: Label
var gateway_url_input: LineEdit

# MCP UI
var mcp_status_label: Label
var mcp_port_input: SpinBox
var mcp_toggle_btn: Button

# Settings
var mcp_port: int = 27183
var mcp_auto_start: bool = true
var gateway_url: String = "http://localhost:18789"

func _enter_tree() -> void:
	print("[OpenClaw] Plugin loading...")
	
	# Load settings
	_load_settings()
	
	# Create connection manager (Gateway)
	connection_manager = ConnectionManager.new()
	add_child(connection_manager)
	
	# Create tools handler
	tools = Tools.new()
	tools.editor_interface = get_editor_interface()
	tools.editor_plugin = self
	add_child(tools)
	
	# Create MCP bridge (local HTTP server)
	mcp_bridge = MCPBridge.new()
	mcp_bridge.started.connect(_on_mcp_started)
	mcp_bridge.stopped.connect(_on_mcp_stopped)
	add_child(mcp_bridge)
	
	# Connect signals
	connection_manager.command_received.connect(_on_command_received)
	connection_manager.connection_changed.connect(_on_connection_changed)
	
	# Create dock UI
	_create_dock()
	
	# Start connections (deferred to ensure _ready() has run)
	connection_manager.call_deferred("start")
	
	# Auto-start MCP bridge
	if mcp_auto_start:
		call_deferred("_start_mcp_bridge")
	
	print("[OpenClaw] Plugin loaded!")

func _exit_tree() -> void:
	print("[OpenClaw] Plugin unloading...")
	
	# Save settings
	_save_settings()
	
	# Stop MCP bridge
	if mcp_bridge:
		mcp_bridge.stop()
		mcp_bridge.queue_free()
	
	if connection_manager:
		connection_manager.stop()
		connection_manager.queue_free()
	
	if tools:
		tools.queue_free()
	
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()
	
	print("[OpenClaw] Plugin unloaded!")

func _load_settings() -> void:
	var config = ConfigFile.new()
	var path = "user://openclaw_settings.cfg"
	if config.load(path) == OK:
		mcp_port = config.get_value("mcp", "port", 27183)
		mcp_auto_start = config.get_value("mcp", "auto_start", true)
		gateway_url = config.get_value("gateway", "url", "http://localhost:18789")

func _save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("mcp", "port", mcp_port)
	config.set_value("mcp", "auto_start", mcp_auto_start)
	config.set_value("gateway", "url", gateway_url)
	config.save("user://openclaw_settings.cfg")

func _create_dock() -> void:
	dock = VBoxContainer.new()
	dock.name = "OpenClaw"
	
	# Title
	var title = Label.new()
	title.text = "🦞 OpenClaw"
	title.add_theme_font_size_override("font_size", 16)
	dock.add_child(title)
	
	# Separator
	dock.add_child(HSeparator.new())
	
	# === Gateway Section ===
	var gateway_title = Label.new()
	gateway_title.text = "Gateway (Remote)"
	gateway_title.add_theme_font_size_override("font_size", 13)
	dock.add_child(gateway_title)
	
	# Status
	status_label = Label.new()
	status_label.text = "Status: Connecting..."
	dock.add_child(status_label)
	
	# Gateway URL input
	var url_container = HBoxContainer.new()
	var url_label = Label.new()
	url_label.text = "URL:"
	url_label.custom_minimum_size.x = 35
	url_container.add_child(url_label)
	
	gateway_url_input = LineEdit.new()
	gateway_url_input.text = gateway_url
	gateway_url_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gateway_url_input.text_changed.connect(_on_gateway_url_changed)
	url_container.add_child(gateway_url_input)
	dock.add_child(url_container)
	
	# Gateway buttons
	var gateway_btns = HBoxContainer.new()
	
	var connect_btn = Button.new()
	connect_btn.text = "Connect"
	connect_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	connect_btn.pressed.connect(_on_connect_pressed)
	gateway_btns.add_child(connect_btn)
	
	var disconnect_btn = Button.new()
	disconnect_btn.text = "Disconnect"
	disconnect_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	disconnect_btn.pressed.connect(_on_disconnect_pressed)
	gateway_btns.add_child(disconnect_btn)
	
	dock.add_child(gateway_btns)
	
	# Separator
	dock.add_child(HSeparator.new())
	
	# === MCP Section ===
	var mcp_title = Label.new()
	mcp_title.text = "MCP Bridge (Local)"
	mcp_title.add_theme_font_size_override("font_size", 13)
	dock.add_child(mcp_title)
	
	# MCP Info
	var mcp_info = Label.new()
	mcp_info.text = "For Claude Code / Cursor"
	mcp_info.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	mcp_info.add_theme_font_size_override("font_size", 11)
	dock.add_child(mcp_info)
	
	# MCP Status
	mcp_status_label = Label.new()
	mcp_status_label.text = "Status: ● Stopped"
	mcp_status_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	dock.add_child(mcp_status_label)
	
	# MCP Port input
	var port_container = HBoxContainer.new()
	var port_label = Label.new()
	port_label.text = "Port:"
	port_label.custom_minimum_size.x = 35
	port_container.add_child(port_label)
	
	mcp_port_input = SpinBox.new()
	mcp_port_input.min_value = 1024
	mcp_port_input.max_value = 65535
	mcp_port_input.value = mcp_port
	mcp_port_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mcp_port_input.value_changed.connect(_on_mcp_port_changed)
	port_container.add_child(mcp_port_input)
	dock.add_child(port_container)
	
	# MCP Start/Stop button
	mcp_toggle_btn = Button.new()
	mcp_toggle_btn.text = "Start MCP Bridge"
	mcp_toggle_btn.pressed.connect(_on_mcp_toggle_pressed)
	dock.add_child(mcp_toggle_btn)
	
	# Separator
	dock.add_child(HSeparator.new())
	
	# MCP Command help
	var cmd_title = Label.new()
	cmd_title.text = "Claude Code Setup:"
	cmd_title.add_theme_font_size_override("font_size", 11)
	dock.add_child(cmd_title)
	
	var mcp_cmd = Label.new()
	mcp_cmd.text = "claude mcp add godot --\n  node <path>/MCP~/index.js"
	mcp_cmd.add_theme_color_override("font_color", Color(0.4, 0.6, 0.8))
	mcp_cmd.add_theme_font_size_override("font_size", 10)
	dock.add_child(mcp_cmd)
	
	# Separator
	dock.add_child(HSeparator.new())
	
	# === Info Section ===
	var info_label = Label.new()
	info_label.text = "Tools: 30 | v1.4.0"
	info_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	info_label.add_theme_font_size_override("font_size", 11)
	dock.add_child(info_label)
	
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

#region Gateway

func _on_gateway_url_changed(new_url: String) -> void:
	gateway_url = new_url
	_save_settings()

func _on_connect_pressed() -> void:
	connection_manager.reconnect()

func _on_disconnect_pressed() -> void:
	connection_manager.stop()

func _on_connection_changed(connected: bool) -> void:
	if status_label:
		if connected:
			status_label.text = "Status: ✅ Connected"
			status_label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
		else:
			status_label.text = "Status: ❌ Disconnected"
			status_label.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3))

#endregion

#region MCP Bridge

func _on_mcp_port_changed(new_port: float) -> void:
	mcp_port = int(new_port)
	_save_settings()
	
	# Restart bridge if running
	if mcp_bridge and mcp_bridge.is_running():
		mcp_bridge.stop()
		_start_mcp_bridge()

func _on_mcp_toggle_pressed() -> void:
	if mcp_bridge.is_running():
		mcp_bridge.stop()
	else:
		_start_mcp_bridge()

func _start_mcp_bridge() -> void:
	if mcp_bridge.start(mcp_port, tools):
		_update_mcp_ui(true)
	else:
		_update_mcp_ui(false, "Failed to start")

func _on_mcp_started() -> void:
	_update_mcp_ui(true)

func _on_mcp_stopped() -> void:
	_update_mcp_ui(false)

func _update_mcp_ui(running: bool, error_msg: String = "") -> void:
	if mcp_status_label:
		if not error_msg.is_empty():
			mcp_status_label.text = "Status: ⚠️ " + error_msg
			mcp_status_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.2))
		elif running:
			mcp_status_label.text = "Status: ● Running (:%d)" % mcp_port
			mcp_status_label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
		else:
			mcp_status_label.text = "Status: ● Stopped"
			mcp_status_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	
	if mcp_toggle_btn:
		mcp_toggle_btn.text = "Stop MCP Bridge" if running else "Start MCP Bridge"
	
	if mcp_port_input:
		mcp_port_input.editable = not running

#endregion

#region Command Handling

func _on_command_received(tool_call_id: String, tool_name: String, args: Dictionary) -> void:
	print("[OpenClaw] Command: %s" % tool_name)
	
	var result = tools.execute(tool_name, args)
	connection_manager.send_result(tool_call_id, result)

#endregion
