@tool
extends Node
## MCP Bridge - HTTP Server for local MCP clients (Claude Code, Cursor)
## Receives tool calls via HTTP and routes to Godot tools

signal started
signal stopped
signal tool_received(tool_name: String, args: Dictionary)

var _server: TCPServer
var _clients: Array[StreamPeerTCP] = []
var _port: int = 27183
var _running: bool = false
var _tools_handler  # Reference to Tools node

func _ready() -> void:
	set_process(false)

func start(port: int, tools_handler) -> bool:
	if _running:
		stop()
	
	_port = port
	_tools_handler = tools_handler
	_server = TCPServer.new()
	
	var err = _server.listen(_port, "127.0.0.1")
	if err != OK:
		push_error("[OpenClaw MCP Bridge] Failed to start server on port %d: %s" % [_port, error_string(err)])
		return false
	
	_running = true
	set_process(true)
	print("[OpenClaw MCP Bridge] Server started on http://127.0.0.1:%d" % _port)
	started.emit()
	return true

func stop() -> void:
	if not _running:
		return
	
	set_process(false)
	_running = false
	
	# Close all client connections
	for client in _clients:
		if client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			client.disconnect_from_host()
	_clients.clear()
	
	# Stop server
	if _server:
		_server.stop()
		_server = null
	
	print("[OpenClaw MCP Bridge] Server stopped")
	stopped.emit()

func is_running() -> bool:
	return _running

func get_port() -> int:
	return _port

func _process(_delta: float) -> void:
	if not _running or not _server:
		return
	
	# Accept new connections
	if _server.is_connection_available():
		var client = _server.take_connection()
		if client:
			_clients.append(client)
			print("[OpenClaw MCP Bridge] Client connected")
	
	# Process existing connections
	var to_remove: Array[int] = []
	for i in range(_clients.size()):
		var client = _clients[i]
		
		# Poll first to update status
		client.poll()
		var status = client.get_status()
		
		match status:
			StreamPeerTCP.STATUS_CONNECTED:
				if client.get_available_bytes() > 0:
					_handle_client_data(client)
					to_remove.append(i)  # Close after handling (HTTP/1.0 style)
			StreamPeerTCP.STATUS_NONE, StreamPeerTCP.STATUS_ERROR:
				to_remove.append(i)
			StreamPeerTCP.STATUS_CONNECTING:
				pass  # Still connecting, wait
	
	# Remove disconnected clients (in reverse order)
	for i in range(to_remove.size() - 1, -1, -1):
		var client = _clients[to_remove[i]]
		client.disconnect_from_host()
		_clients.remove_at(to_remove[i])

func _handle_client_data(client: StreamPeerTCP) -> void:
	var data = client.get_utf8_string(client.get_available_bytes())
	if data.is_empty():
		return
	
	# Parse HTTP request
	var lines = data.split("\r\n")
	if lines.size() < 1:
		return
	
	# Parse request line (e.g., "POST /tool HTTP/1.1")
	var request_line = lines[0].split(" ")
	if request_line.size() < 3:
		_send_response(client, 400, {"error": "Bad request"})
		return
	
	var method = request_line[0]
	var path = request_line[1]
	
	# Find body (after empty line)
	var body = ""
	var found_empty = false
	for line in lines:
		if found_empty:
			body += line
		elif line.is_empty():
			found_empty = true
	
	# Route request
	if method == "POST" and path == "/tool":
		_handle_tool_request(client, body)
	elif method == "GET" and path == "/status":
		_handle_status_request(client)
	elif method == "OPTIONS":
		_handle_options_request(client)
	else:
		_send_response(client, 404, {"error": "Not found"})

func _handle_tool_request(client: StreamPeerTCP, body: String) -> void:
	# Parse JSON body
	var json = JSON.new()
	var err = json.parse(body)
	if err != OK:
		_send_response(client, 400, {"error": "Invalid JSON", "details": json.get_error_message()})
		return
	
	var data = json.data
	if not data is Dictionary:
		_send_response(client, 400, {"error": "Expected JSON object"})
		return
	
	var tool_name = data.get("tool", "")
	var args = data.get("arguments", {})
	
	if tool_name.is_empty():
		_send_response(client, 400, {"error": "Missing 'tool' field"})
		return
	
	# Execute tool
	print("[OpenClaw MCP Bridge] Tool: %s" % tool_name)
	tool_received.emit(tool_name, args)
	
	var result = {}
	if _tools_handler and _tools_handler.has_method("execute"):
		result = _tools_handler.execute(tool_name, args)
	else:
		result = {"success": false, "error": "Tools handler not available"}
	
	_send_response(client, 200, result)

func _handle_status_request(client: StreamPeerTCP) -> void:
	_send_response(client, 200, {
		"status": "running",
		"port": _port,
		"version": "1.4.0"
	})

func _handle_options_request(client: StreamPeerTCP) -> void:
	# CORS preflight
	var response = "HTTP/1.1 204 No Content\r\n"
	response += "Access-Control-Allow-Origin: *\r\n"
	response += "Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n"
	response += "Access-Control-Allow-Headers: Content-Type\r\n"
	response += "Content-Length: 0\r\n"
	response += "\r\n"
	client.put_data(response.to_utf8_buffer())

func _send_response(client: StreamPeerTCP, status_code: int, data: Dictionary) -> void:
	var json_body = JSON.stringify(data)
	var status_text = _get_status_text(status_code)
	
	var response = "HTTP/1.1 %d %s\r\n" % [status_code, status_text]
	response += "Content-Type: application/json\r\n"
	response += "Access-Control-Allow-Origin: *\r\n"
	response += "Content-Length: %d\r\n" % json_body.length()
	response += "\r\n"
	response += json_body
	
	client.put_data(response.to_utf8_buffer())

func _get_status_text(code: int) -> String:
	match code:
		200: return "OK"
		204: return "No Content"
		400: return "Bad Request"
		404: return "Not Found"
		500: return "Internal Server Error"
		_: return "Unknown"
