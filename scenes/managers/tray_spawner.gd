class_name TraySpawner
extends Node

signal tray_spawned(tray: PlantTray)
signal spawn_failed(reason: String)

@export var plant_tray_scene: PackedScene
@export var spawn_table: Table  # The table where new trays spawn (Table 1)
@export var drop_offset: Vector2 = Vector2(0, 11)  # Offset from slot center

# Optional: auto-spawn settings
@export_group("Auto Spawn")
@export var auto_spawn_enabled: bool = false
@export var auto_spawn_interval: float = 5.0  # Seconds between spawns
@export var max_trays_on_spawn_table: int = 6

var _spawn_timer: float = 0.0
var _countdown_active: bool = false
var _spawn_paused: bool = false

func _ready() -> void:
	if plant_tray_scene == null:
		push_warning("TraySpawner: plant_tray_scene not assigned")
	if spawn_table:
		spawn_table.tray_removed.connect(_on_spawn_table_tray_removed)

func _process(delta: float) -> void:
	if not auto_spawn_enabled:
		if _countdown_active:
			UIManager.stop_countdown()
			_countdown_active = false
		return

	if _spawn_paused:
		return

	_spawn_timer += delta

	var time_remaining = auto_spawn_interval - _spawn_timer
	UIManager.update_countdown(time_remaining, "Next spawn in:")
	_countdown_active = true

	if _spawn_timer >= auto_spawn_interval:
		_spawn_timer = 0.0
		try_auto_spawn()

func try_auto_spawn() -> void:
	if spawn_table == null:
		return
	if spawn_table.get_tray_count() >= max_trays_on_spawn_table:
		spawn_failed.emit("No empty slots on spawn table")
		if not _are_all_slots_full():
			UIManager.show_toast("No empty slots on spawn table")
		_spawn_paused = true
		UIManager.stop_countdown()
		_countdown_active = false
		return
		
	spawn_tray()

func spawn_tray() -> PlantTray:	
	if plant_tray_scene == null:
		spawn_failed.emit("No plant tray scene assigned")
		return null

	if spawn_table == null:
		spawn_failed.emit("No spawn table assigned")
		return null

	var empty_slots = spawn_table.get_empty_slots()
	if empty_slots.is_empty():
		spawn_failed.emit("No empty slots on spawn table")
		if not _are_all_slots_full():
			UIManager.show_toast("No empty slots on spawn table")
		return null

	# Spawn in the first empty slot
	var slot = empty_slots[0]
	return spawn_tray_at_slot(slot)

func spawn_tray_at_slot(slot: Area2D) -> PlantTray:
	if plant_tray_scene == null:
		spawn_failed.emit("No plant tray scene assigned")
		return null

	var tray = plant_tray_scene.instantiate() as PlantTray
	if tray == null:
		spawn_failed.emit("Failed to instantiate plant tray")
		return null

	# Add to scene tree (as sibling of tables for proper y-sorting)
	get_tree().current_scene.add_child(tray)

	# Position at slot
	tray.global_position = slot.global_position + drop_offset

	# Notify table that tray was placed
	var table: Table = slot.get_parent()
	table.place_tray_in_slot(slot, tray)

	tray_spawned.emit(tray)
	return tray

func spawn_tray_at_random_slot() -> PlantTray:
	if spawn_table == null:
		spawn_failed.emit("No spawn table assigned")
		return null

	var empty_slots = spawn_table.get_empty_slots()
	if empty_slots.is_empty():
		spawn_failed.emit("No empty slots on spawn table")
		return null

	var random_slot = empty_slots[randi() % empty_slots.size()]
	return spawn_tray_at_slot(random_slot)

func get_spawn_table() -> Table:
	return spawn_table

func set_spawn_table(table: Table) -> void:
	if spawn_table and spawn_table.tray_removed.is_connected(_on_spawn_table_tray_removed):
		spawn_table.tray_removed.disconnect(_on_spawn_table_tray_removed)
	spawn_table = table
	if spawn_table:
		spawn_table.tray_removed.connect(_on_spawn_table_tray_removed)


func _on_spawn_table_tray_removed(_table: Table, _slot: Area2D, _tray: PlantTray) -> void:
	if _spawn_paused and auto_spawn_enabled:
		_spawn_paused = false
		_spawn_timer = 0.0


func _are_all_slots_full() -> bool:
	var progress = GameManager.get_progress()
	return progress.filled_slots >= progress.total_slots
