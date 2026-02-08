@tool
extends Node
## Handles HTTP communication with OpenClaw Gateway

signal command_received(tool_call_id: String, tool_name: String, args: Dictionary)
signal connection_changed(connected: bool)

const GATEWAY_URL = "http://localhost:18789"
const API_PREFIX = "/godot"
const POLL_INTERVAL = 0.5
const HEARTBEAT_INTERVAL = 10.0

var session_id: String = ""
var is_connected: bool = false
var is_running: bool = false

var http_register: HTTPRequest
var http_poll: HTTPRequest
var http_result: HTTPRequest
var http_heartbeat: HTTPRequest

var poll_timer: Timer
var heartbeat_timer: Timer

func _ready() -> void:
	# Create HTTP request nodes
	http_register = HTTPRequest.new()
	http_register.request_completed.connect(_on_register_completed)
	add_child(http_register)
	
	http_poll = HTTPRequest.new()
	http_poll.request_completed.connect(_on_poll_completed)
	add_child(http_poll)
	
	http_result = HTTPRequest.new()
	http_result.request_completed.connect(_on_result_completed)
	add_child(http_result)
	
	http_heartbeat = HTTPRequest.new()
	http_heartbeat.request_completed.connect(_on_heartbeat_completed)
	add_child(http_heartbeat)
	
	# Create timers
	poll_timer = Timer.new()
	poll_timer.wait_time = POLL_INTERVAL
	poll_timer.timeout.connect(_on_poll_timer)
	add_child(poll_timer)
	
	heartbeat_timer = Timer.new()
	heartbeat_timer.wait_time = HEARTBEAT_INTERVAL
	heartbeat_timer.timeout.connect(_on_heartbeat_timer)
	add_child(heartbeat_timer)

func start() -> void:
	if is_running:
		return
	is_running = true
	_register()

func stop() -> void:
	is_running = false
	poll_timer.stop()
	heartbeat_timer.stop()
	is_connected = false
	connection_changed.emit(false)

func reconnect() -> void:
	stop()
	await get_tree().create_timer(0.5).timeout
	start()

func _register() -> void:
	var data = {
		"project": ProjectSettings.get_setting("application/config/name", "Godot Project"),
		"version": Engine.get_version_info().string,
		"platform": "GodotEditor",
		"tools": _get_tool_count()
	}
	
	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	
	var err = http_register.request(GATEWAY_URL + API_PREFIX + "/register", headers, HTTPClient.METHOD_POST, json)
	if err != OK:
		print("[OpenClaw] Register request failed: %s" % err)
		_schedule_reconnect()

func _on_register_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[OpenClaw] Register failed: %s, %s" % [result, response_code])
		_schedule_reconnect()
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json and json.has("sessionId"):
		session_id = json.sessionId
		is_connected = true
		connection_changed.emit(true)
		print("[OpenClaw] Connected! Session: %s" % session_id)
		
		poll_timer.start()
		heartbeat_timer.start()
	else:
		print("[OpenClaw] Invalid register response")
		_schedule_reconnect()

func _on_poll_timer() -> void:
	if not is_connected or session_id.is_empty():
		return
	
	var url = "%s%s/poll?sessionId=%s" % [GATEWAY_URL, API_PREFIX, session_id]
	http_poll.request(url)

func _on_poll_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		return
	
	if response_code == 204:
		return  # No commands
	
	if response_code != 200:
		print("[OpenClaw] Poll error: %s" % response_code)
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json and json.has("toolCallId") and json.has("tool"):
		var tool_call_id = json.toolCallId
		var tool_name = json.tool
		var args = json.get("arguments", {})
		
		if args is String:
			args = JSON.parse_string(args)
			if args == null:
				args = {}
		
		command_received.emit(tool_call_id, tool_name, args)

func _on_heartbeat_timer() -> void:
	if not is_connected or session_id.is_empty():
		return
	
	var data = {"sessionId": session_id}
	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	
	http_heartbeat.request(GATEWAY_URL + API_PREFIX + "/heartbeat", headers, HTTPClient.METHOD_POST, json)

func _on_heartbeat_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[OpenClaw] Heartbeat failed, reconnecting...")
		is_connected = false
		connection_changed.emit(false)
		_schedule_reconnect()

func send_result(tool_call_id: String, result: Variant) -> void:
	var data = {
		"sessionId": session_id,
		"toolCallId": tool_call_id,
		"result": result
	}
	
	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	
	http_result.request(GATEWAY_URL + API_PREFIX + "/result", headers, HTTPClient.METHOD_POST, json)

func _on_result_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("[OpenClaw] Result send failed: %s" % response_code)

func _schedule_reconnect() -> void:
	if is_running:
		await get_tree().create_timer(5.0).timeout
		if is_running:
			_register()

func _get_tool_count() -> int:
	return 30  # Approximate tool count
