class_name Table
extends StaticBody2D

signal tray_placed(table: Table, slot: Area2D, tray: StaticBody2D)
signal tray_removed(table: Table, slot: Area2D, tray: StaticBody2D)

@export var table_id: int = 1
@export_group("Environment Properties")
@export_range(0.0, 2.0) var light_level: float = 1.0
@export_range(0.0, 50.0) var temperature: float = 20.0  # Celsius
@export_range(0.0, 1.0) var humidity: float = 0.5

# Track which trays are in which slots: slot_name -> PlantTray reference
var occupied_slots: Dictionary = {}

func place_tray_in_slot(slot: Area2D, tray: Node2D) -> void:
	var slot_name = slot.name
	occupied_slots[slot_name] = tray
	if tray.has_method("set_current_table"):
		tray.set_current_table(self)
	tray_placed.emit(self, slot, tray)

func remove_tray_from_slot(slot: Area2D, tray: Node2D) -> void:
	var slot_name = slot.name
	if occupied_slots.has(slot_name) and occupied_slots[slot_name] == tray:
		occupied_slots.erase(slot_name)
	if tray.has_method("set_current_table"):
		tray.set_current_table(null)
	tray_removed.emit(self, slot, tray)

func remove_tray(tray: Node2D) -> void:
	for slot_name in occupied_slots.keys():
		if occupied_slots[slot_name] == tray:
			var slot = get_node_or_null(str(slot_name)) as Area2D
			occupied_slots.erase(slot_name)
			if tray.has_method("set_current_table"):
				tray.set_current_table(null)
			if slot:
				tray_removed.emit(self, slot, tray)
			return

func get_slot_by_name(slot_name: String) -> Area2D:
	return get_node_or_null(slot_name)

func get_slot_by_index(index: int) -> Area2D:
	return get_node_or_null("TraySlot%d" % index)

func is_slot_occupied(slot: Area2D) -> bool:
	return occupied_slots.has(slot.name)

func get_empty_slots() -> Array[Area2D]:
	var empty: Array[Area2D] = []
	for i in range(1, 7):
		var slot = get_node_or_null("TraySlot%d" % i) as Area2D
		if slot and not occupied_slots.has(slot.name):
			empty.append(slot)
	return empty

func get_occupied_slots() -> Array[Area2D]:
	var occupied: Array[Area2D] = []
	for i in range(1, 7):
		var slot = get_node_or_null("TraySlot%d" % i) as Area2D
		if slot and occupied_slots.has(slot.name):
			occupied.append(slot)
	return occupied

func get_tray_count() -> int:
	return occupied_slots.size()

func get_all_trays() -> Array:
	return occupied_slots.values()
