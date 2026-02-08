@tool
extends Node
## Implements OpenClaw tools for Godot Editor

var editor_interface  # EditorInterface
var editor_plugin     # EditorPlugin

func execute(tool_name: String, args: Dictionary) -> Variant:
	match tool_name:
		# Scene tools
		"scene.getCurrent":
			return scene_get_current()
		"scene.list":
			return scene_list()
		"scene.open":
			return scene_open(args)
		"scene.save":
			return scene_save()
		
		# Node tools
		"node.find":
			return node_find(args)
		"node.create":
			return node_create(args)
		"node.delete":
			return node_delete(args)
		"node.getData":
			return node_get_data(args)
		"node.setProperty":
			return node_set_property(args)
		"node.getProperty":
			return node_get_property(args)
		
		# Transform tools
		"transform.setPosition":
			return transform_set_position(args)
		"transform.setRotation":
			return transform_set_rotation(args)
		"transform.setScale":
			return transform_set_scale(args)
		
		# Editor tools
		"editor.play":
			return editor_play(args)
		"editor.stop":
			return editor_stop()
		"editor.pause":
			return editor_pause()
		"editor.getState":
			return editor_get_state()
		
		# Debug tools
		"debug.screenshot":
			return debug_screenshot(args)
		"debug.tree":
			return debug_tree(args)
		"debug.log":
			return debug_log(args)
		
		# Script tools
		"script.list":
			return script_list(args)
		"script.read":
			return script_read(args)
		
		# Resource tools
		"resource.list":
			return resource_list(args)
		
		_:
			return {"success": false, "error": "Unknown tool: %s" % tool_name}

#region Scene Tools

func scene_get_current() -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene open"}
	
	return {
		"success": true,
		"name": scene.name,
		"path": scene.scene_file_path,
		"nodeCount": _count_nodes(scene)
	}

func scene_list() -> Dictionary:
	var scenes: Array = []
	var dir = DirAccess.open("res://")
	if dir:
		_find_scenes(dir, "res://", scenes)
	
	return {"success": true, "scenes": scenes}

func _find_scenes(dir: DirAccess, path: String, scenes: Array) -> void:
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			var subdir = DirAccess.open(path + file_name)
			if subdir:
				_find_scenes(subdir, path + file_name + "/", scenes)
		elif file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
			scenes.append(path + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func scene_open(args: Dictionary) -> Dictionary:
	var path = args.get("path", "")
	if path.is_empty():
		return {"success": false, "error": "Path required"}
	
	var err = editor_interface.open_scene_from_path(path)
	return {"success": err == OK, "path": path}

func scene_save() -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene to save"}
	
	editor_interface.save_scene()
	return {"success": true}

#endregion

#region Node Tools

func node_find(args: Dictionary) -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene open"}
	
	var name_filter = args.get("name", "")
	var type_filter = args.get("type", "")
	var group_filter = args.get("group", "")
	
	var results: Array = []
	_find_nodes(scene, name_filter, type_filter, group_filter, results)
	
	return {"success": true, "nodes": results}

func _find_nodes(node: Node, name_filter: String, type_filter: String, group_filter: String, results: Array) -> void:
	var is_match = true
	
	if not name_filter.is_empty() and not name_filter in node.name:
		is_match = false
	if not type_filter.is_empty() and node.get_class() != type_filter:
		is_match = false
	if not group_filter.is_empty() and not node.is_in_group(group_filter):
		is_match = false
	
	if is_match and (not name_filter.is_empty() or not type_filter.is_empty() or not group_filter.is_empty()):
		results.append({
			"name": node.name,
			"type": node.get_class(),
			"path": str(node.get_path())
		})
	
	for child in node.get_children():
		_find_nodes(child, name_filter, type_filter, group_filter, results)

func node_create(args: Dictionary) -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene open"}
	
	var type_name = args.get("type", "Node")
	var node_name = args.get("name", "NewNode")
	var parent_path = args.get("parent", "")
	
	var new_node: Node
	match type_name:
		"Node2D": new_node = Node2D.new()
		"Node3D": new_node = Node3D.new()
		"Sprite2D": new_node = Sprite2D.new()
		"Sprite3D": new_node = Sprite3D.new()
		"CharacterBody2D": new_node = CharacterBody2D.new()
		"CharacterBody3D": new_node = CharacterBody3D.new()
		"RigidBody2D": new_node = RigidBody2D.new()
		"RigidBody3D": new_node = RigidBody3D.new()
		"Area2D": new_node = Area2D.new()
		"Area3D": new_node = Area3D.new()
		"Camera2D": new_node = Camera2D.new()
		"Camera3D": new_node = Camera3D.new()
		"Light2D": new_node = PointLight2D.new()
		"DirectionalLight3D": new_node = DirectionalLight3D.new()
		"Label": new_node = Label.new()
		"Button": new_node = Button.new()
		"Control": new_node = Control.new()
		_: new_node = Node.new()
	
	new_node.name = node_name
	
	var parent = scene
	if not parent_path.is_empty():
		parent = scene.get_node_or_null(parent_path)
		if not parent:
			new_node.queue_free()
			return {"success": false, "error": "Parent not found: %s" % parent_path}
	
	parent.add_child(new_node)
	new_node.owner = scene
	
	return {"success": true, "name": new_node.name, "path": str(new_node.get_path())}

func node_delete(args: Dictionary) -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene open"}
	
	var path = args.get("path", "")
	if path.is_empty():
		return {"success": false, "error": "Path required"}
	
	var node = scene.get_node_or_null(path)
	if not node:
		return {"success": false, "error": "Node not found: %s" % path}
	
	if node == scene:
		return {"success": false, "error": "Cannot delete scene root"}
	
	node.queue_free()
	return {"success": true}

func node_get_data(args: Dictionary) -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene open"}
	
	var path = args.get("path", "")
	var node = scene if path.is_empty() else scene.get_node_or_null(path)
	if not node:
		return {"success": false, "error": "Node not found"}
	
	var data = {
		"name": node.name,
		"type": node.get_class(),
		"path": str(node.get_path()),
		"children": [],
		"groups": node.get_groups()
	}
	
	for child in node.get_children():
		data.children.append({"name": child.name, "type": child.get_class()})
	
	# Add transform for spatial nodes
	if node is Node2D:
		data["position"] = {"x": node.position.x, "y": node.position.y}
		data["rotation"] = node.rotation_degrees
		data["scale"] = {"x": node.scale.x, "y": node.scale.y}
	elif node is Node3D:
		data["position"] = {"x": node.position.x, "y": node.position.y, "z": node.position.z}
		data["rotation"] = {"x": node.rotation_degrees.x, "y": node.rotation_degrees.y, "z": node.rotation_degrees.z}
		data["scale"] = {"x": node.scale.x, "y": node.scale.y, "z": node.scale.z}
	
	return {"success": true, "data": data}

func node_get_property(args: Dictionary) -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene open"}
	
	var path = args.get("path", "")
	var prop = args.get("property", "")
	
	var node = scene.get_node_or_null(path)
	if not node:
		return {"success": false, "error": "Node not found"}
	
	if prop.is_empty():
		# Return all properties
		var props = {}
		for p in node.get_property_list():
			if p.usage & PROPERTY_USAGE_EDITOR:
				props[p.name] = node.get(p.name)
		return {"success": true, "properties": props}
	else:
		var value = node.get(prop)
		return {"success": true, "property": prop, "value": value}

func node_set_property(args: Dictionary) -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene open"}
	
	var path = args.get("path", "")
	var prop = args.get("property", "")
	var value = args.get("value")
	
	if prop.is_empty():
		return {"success": false, "error": "Property name required"}
	
	var node = scene.get_node_or_null(path)
	if not node:
		return {"success": false, "error": "Node not found"}
	
	node.set(prop, value)
	return {"success": true}

#endregion

#region Transform Tools

func transform_set_position(args: Dictionary) -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene open"}
	
	var path = args.get("path", "")
	var node = scene.get_node_or_null(path)
	if not node:
		return {"success": false, "error": "Node not found"}
	
	if node is Node2D:
		node.position = Vector2(args.get("x", 0), args.get("y", 0))
	elif node is Node3D:
		node.position = Vector3(args.get("x", 0), args.get("y", 0), args.get("z", 0))
	else:
		return {"success": false, "error": "Node is not a spatial node"}
	
	return {"success": true}

func transform_set_rotation(args: Dictionary) -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene open"}
	
	var path = args.get("path", "")
	var node = scene.get_node_or_null(path)
	if not node:
		return {"success": false, "error": "Node not found"}
	
	if node is Node2D:
		node.rotation_degrees = args.get("degrees", 0)
	elif node is Node3D:
		node.rotation_degrees = Vector3(args.get("x", 0), args.get("y", 0), args.get("z", 0))
	else:
		return {"success": false, "error": "Node is not a spatial node"}
	
	return {"success": true}

func transform_set_scale(args: Dictionary) -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene open"}
	
	var path = args.get("path", "")
	var node = scene.get_node_or_null(path)
	if not node:
		return {"success": false, "error": "Node not found"}
	
	if node is Node2D:
		node.scale = Vector2(args.get("x", 1), args.get("y", 1))
	elif node is Node3D:
		node.scale = Vector3(args.get("x", 1), args.get("y", 1), args.get("z", 1))
	else:
		return {"success": false, "error": "Node is not a spatial node"}
	
	return {"success": true}

#endregion

#region Editor Tools

func editor_play(args: Dictionary) -> Dictionary:
	var scene_path = args.get("scene", "")
	
	if scene_path.is_empty():
		editor_interface.play_current_scene()
	else:
		editor_interface.play_custom_scene(scene_path)
	
	return {"success": true}

func editor_stop() -> Dictionary:
	editor_interface.stop_playing_scene()
	return {"success": true}

func editor_pause() -> Dictionary:
	# Toggle pause
	var tree = Engine.get_main_loop()
	if tree:
		tree.paused = not tree.paused
		return {"success": true, "paused": tree.paused}
	return {"success": false, "error": "No scene tree"}

func editor_get_state() -> Dictionary:
	return {
		"success": true,
		"isPlaying": editor_interface.is_playing_scene(),
		"version": Engine.get_version_info().string,
		"projectName": ProjectSettings.get_setting("application/config/name", ""),
		"editedScene": editor_interface.get_edited_scene_root().scene_file_path if editor_interface.get_edited_scene_root() else ""
	}

#endregion

#region Debug Tools

func debug_screenshot(args: Dictionary) -> Dictionary:
	var viewport = editor_interface.get_editor_viewport_2d() if args.get("2d", false) else editor_interface.get_editor_viewport_3d()
	if not viewport:
		return {"success": false, "error": "Viewport not found"}
	
	var img = viewport.get_texture().get_image()
	var path = "user://screenshot_%s.png" % Time.get_datetime_string_from_system().replace(":", "-")
	img.save_png(path)
	
	return {"success": true, "path": ProjectSettings.globalize_path(path)}

func debug_tree(args: Dictionary) -> Dictionary:
	var scene = editor_interface.get_edited_scene_root()
	if not scene:
		return {"success": false, "error": "No scene open"}
	
	var depth = args.get("depth", 3)
	var tree_str = _build_tree_string(scene, 0, depth)
	
	return {"success": true, "tree": tree_str}

func _build_tree_string(node: Node, level: int, max_depth: int) -> String:
	if level > max_depth:
		return ""
	
	var indent = "  ".repeat(level)
	var result = "%s▶ %s [%s]\n" % [indent, node.name, node.get_class()]
	
	for child in node.get_children():
		result += _build_tree_string(child, level + 1, max_depth)
	
	return result

func debug_log(args: Dictionary) -> Dictionary:
	var message = args.get("message", "")
	var type = args.get("type", "log")
	
	match type:
		"error": push_error(message)
		"warning": push_warning(message)
		_: print(message)
	
	return {"success": true}

#endregion

#region Script Tools

func script_list(args: Dictionary) -> Dictionary:
	var folder = args.get("folder", "res://")
	var scripts: Array = []
	
	var dir = DirAccess.open(folder)
	if dir:
		_find_scripts(dir, folder, scripts)
	
	return {"success": true, "scripts": scripts}

func _find_scripts(dir: DirAccess, path: String, scripts: Array) -> void:
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			var subdir = DirAccess.open(path + file_name)
			if subdir:
				_find_scripts(subdir, path + file_name + "/", scripts)
		elif file_name.ends_with(".gd"):
			scripts.append(path + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

func script_read(args: Dictionary) -> Dictionary:
	var path = args.get("path", "")
	if path.is_empty():
		return {"success": false, "error": "Path required"}
	
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {"success": false, "error": "Cannot open file"}
	
	var content = file.get_as_text()
	file.close()
	
	return {"success": true, "content": content}

#endregion

#region Resource Tools

func resource_list(args: Dictionary) -> Dictionary:
	var folder = args.get("folder", "res://")
	var extension = args.get("extension", "")
	var resources: Array = []
	
	var dir = DirAccess.open(folder)
	if dir:
		_find_resources(dir, folder, extension, resources)
	
	return {"success": true, "resources": resources}

func _find_resources(dir: DirAccess, path: String, ext: String, resources: Array) -> void:
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("."):
			var subdir = DirAccess.open(path + file_name)
			if subdir:
				_find_resources(subdir, path + file_name + "/", ext, resources)
		elif ext.is_empty() or file_name.ends_with(ext):
			resources.append(path + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

#endregion

func _count_nodes(node: Node) -> int:
	var count = 1
	for child in node.get_children():
		count += _count_nodes(child)
	return count
