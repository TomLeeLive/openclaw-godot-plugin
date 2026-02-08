@tool
extends EditorPlugin
## OpenClaw Plugin for Godot 4.x
## Connects Godot Editor to OpenClaw AI assistant

const ConnectionManager = preload("res://addons/openclaw/connection_manager.gd")
const Tools = preload("res://addons/openclaw/tools.gd")

var connection_manager
var tools
var status_label: Label
var dock: Control

func _enter_tree() -> void:
	print("[OpenClaw] Plugin loading...")
	
	# Create connection manager
	connection_manager = ConnectionManager.new()
	add_child(connection_manager)
	
	# Create tools handler
	tools = Tools.new()
	tools.editor_interface = get_editor_interface()
	tools.editor_plugin = self
	add_child(tools)
	
	# Connect signals
	connection_manager.command_received.connect(_on_command_received)
	connection_manager.connection_changed.connect(_on_connection_changed)
	
	# Create dock UI
	_create_dock()
	
	# Start connection (deferred to ensure _ready() has run)
	connection_manager.call_deferred("start")
	
	print("[OpenClaw] Plugin loaded!")

func _exit_tree() -> void:
	print("[OpenClaw] Plugin unloading...")
	
	if connection_manager:
		connection_manager.stop()
		connection_manager.queue_free()
	
	if tools:
		tools.queue_free()
	
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()
	
	print("[OpenClaw] Plugin unloaded!")

func _create_dock() -> void:
	dock = VBoxContainer.new()
	dock.name = "OpenClaw"
	
	# Title
	var title = Label.new()
	title.text = "🐾 OpenClaw"
	title.add_theme_font_size_override("font_size", 16)
	dock.add_child(title)
	
	# Status
	status_label = Label.new()
	status_label.text = "Status: Connecting..."
	dock.add_child(status_label)
	
	# Gateway URL
	var url_label = Label.new()
	url_label.text = "Gateway: http://localhost:18789"
	url_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	dock.add_child(url_label)
	
	# Reconnect button
	var reconnect_btn = Button.new()
	reconnect_btn.text = "Reconnect"
	reconnect_btn.pressed.connect(_on_reconnect_pressed)
	dock.add_child(reconnect_btn)
	
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)

func _on_reconnect_pressed() -> void:
	connection_manager.reconnect()

func _on_connection_changed(connected: bool) -> void:
	if status_label:
		if connected:
			status_label.text = "Status: ✅ Connected"
			status_label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
		else:
			status_label.text = "Status: ❌ Disconnected"
			status_label.add_theme_color_override("font_color", Color(0.8, 0.3, 0.3))

func _on_command_received(tool_call_id: String, tool_name: String, args: Dictionary) -> void:
	print("[OpenClaw] Command: %s" % tool_name)
	
	var result = tools.execute(tool_name, args)
	connection_manager.send_result(tool_call_id, result)
