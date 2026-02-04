extends Node
class_name GameManagerClass

signal game_won

const PlantTrayScene = preload("res://scenes/plant/plantTray.tscn")

var _tables: Array[Table] = []
var _total_slots: int = 0
var _game_won: bool = false


func _ready() -> void:
	# Wait one frame for the scene tree to be fully loaded
	await get_tree().process_frame
	_find_and_connect_tables()


func _find_and_connect_tables() -> void:
	_tables.clear()
	_total_slots = 0

	# Find all Table nodes in the scene
	var tables = get_tree().get_nodes_in_group("tables")
	if tables.is_empty():
		# Fallback: find tables by class
		for node in get_tree().current_scene.get_children():
			_find_tables_recursive(node)
	else:
		for table in tables:
			if table is Table:
				_register_table(table)

	# Connect to any existing trays on tables
	for table in _tables:
		if not is_instance_valid(table):
			continue
		for tray in table.get_all_trays():
			_connect_tray(tray)


func _find_tables_recursive(node: Node) -> void:
	if node is Table:
		_register_table(node)
	for child in node.get_children():
		_find_tables_recursive(child)


func _register_table(table: Table) -> void:
	_tables.append(table)
	_total_slots += 6  # Each table has 6 slots
	table.tray_placed.connect(_on_tray_placed)
	table.tray_removed.connect(_on_tray_removed)


func _connect_tray(tray: PlantTray) -> void:
	if not tray.fully_grown.is_connected(_on_tray_fully_grown):
		tray.fully_grown.connect(_on_tray_fully_grown)


func _on_tray_placed(_table: Table, _slot: Area2D, tray: Node2D) -> void:
	if tray is PlantTray:
		_connect_tray(tray)
		_check_win_condition()


func _on_tray_removed(_table: Table, _slot: Area2D, _tray: Node2D) -> void:
	# No need to check win condition when a tray is removed
	pass


func _on_tray_fully_grown(_tray: PlantTray) -> void:
	_check_win_condition()


func _check_win_condition() -> void:
	if _game_won:
		return

	# Check if all tables are full and all trays are fully grown
	var total_trays: int = 0
	var fully_grown_count: int = 0

	for table in _tables:
		if not is_instance_valid(table):
			continue
		var trays = table.get_all_trays()
		total_trays += trays.size()
		for tray in trays:
			if tray is PlantTray and tray.is_fully_grown:
				fully_grown_count += 1

	# Win condition: all slots filled AND all trays fully grown
	if total_trays >= _total_slots and fully_grown_count >= _total_slots:
		_trigger_win()


func _trigger_win() -> void:
	_game_won = true
	game_won.emit()

	# Show win message with restart option
	UIManager.show_message("You WON!", "Play Again")
	UIManager.get_message_box().dismissed.connect(_on_play_again, CONNECT_ONE_SHOT)


func _on_play_again() -> void:
	_game_won = false
	_tables.clear()
	_total_slots = 0
	get_tree().reload_current_scene()
	# Wait for new scene to load, then re-find tables
	await get_tree().tree_changed
	await get_tree().process_frame
	_find_and_connect_tables()


func get_progress() -> Dictionary:
	var total_trays: int = 0
	var fully_grown_count: int = 0

	for table in _tables:
		if not is_instance_valid(table):
			continue
		var trays = table.get_all_trays()
		total_trays += trays.size()
		for tray in trays:
			if tray is PlantTray and tray.is_fully_grown:
				fully_grown_count += 1

	return {
		"total_slots": _total_slots,
		"filled_slots": total_trays,
		"fully_grown": fully_grown_count
	}


func _input(event: InputEvent) -> void:
	# Help screen
	if event.is_action_pressed("show_help") and not UIManager.is_paused() and not UIManager.is_help_visible():
		UIManager.show_help()
		get_viewport().set_input_as_handled()
		return

	# Pause menu
	if event.is_action_pressed("ui_cancel") and not UIManager.is_paused() and not UIManager.is_help_visible():
		UIManager.show_pause_menu()
		get_viewport().set_input_as_handled()
		return

	# Debug functions (remove for release)
	if event.is_action_pressed("debug_fill_trays"):
		debug_fill_all_slots()
	elif event.is_action_pressed("debug_grow_trays"):
		debug_grow_all_trays()


func debug_fill_all_slots() -> void:
	for table in _tables:
		if not is_instance_valid(table):
			continue
		for slot in table.get_empty_slots():
			var tray = PlantTrayScene.instantiate() as PlantTray
			get_tree().current_scene.add_child(tray)
			tray.global_position = slot.global_position + Vector2(0, 11)
			table.place_tray_in_slot(slot, tray)
	UIManager.show_toast("DEBUG: Filled all slots")


func debug_grow_all_trays() -> void:
	for table in _tables:
		if not is_instance_valid(table):
			continue
		for tray in table.get_all_trays():
			if tray is PlantTray and not tray.is_fully_grown:
				tray.growth_progress = tray.max_growth_stages
				tray.growth_stage = tray.max_growth_stages
				tray.is_fully_grown = true
				tray.update_sprite()
				tray.fully_grown.emit(tray)
	UIManager.show_toast("DEBUG: All trays fully grown")
