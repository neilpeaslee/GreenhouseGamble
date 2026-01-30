class_name PlantTray
extends StaticBody2D

signal growth_changed(tray: PlantTray, growth_stage: int)
signal fully_grown(tray: PlantTray)

@export_range(0.0, 10.0) var base_growth_rate: float = 1.0  # Base growth per second

# Environment preferences (optimal values for fastest growth)
@export_group("Optimal Conditions")
@export_range(0.0, 2.0) var preferred_light: float = 1.0
@export_range(0.0, 50.0) var preferred_temperature: float = 22.0
@export_range(0.0, 1.0) var preferred_humidity: float = 0.6

# Current state
var current_table: Table = null
var growth_progress: float = 0.0
var growth_stage: int = 0
var max_growth_stages: int = 5  # 6 frames (0-5)
var is_fully_grown: bool = false

@onready var plant_sprite: AnimatedSprite2D = $PlantSprite

func _ready() -> void:
	# Stop auto-animation - we'll control frames manually based on growth
	if plant_sprite:
		plant_sprite.stop()
		plant_sprite.frame = 0

func _process(delta: float) -> void:
	if is_fully_grown:
		return

	var growth_modifier = calculate_growth_modifier()
	growth_progress += base_growth_rate * growth_modifier * delta

	# Check for growth stage advancement
	var new_stage = int(growth_progress)
	if new_stage > growth_stage and new_stage <= max_growth_stages:
		growth_stage = new_stage
		update_sprite()
		growth_changed.emit(self, growth_stage)

		if growth_stage >= max_growth_stages:
			is_fully_grown = true
			fully_grown.emit(self)

func calculate_growth_modifier() -> float:
	if current_table == null:
		return 0.0  # No growth when not on a table

	# Calculate how well current conditions match preferred conditions
	var light_factor = calculate_factor(current_table.light_level, preferred_light, 0.5)
	var temp_factor = calculate_factor(current_table.temperature, preferred_temperature, 10.0)
	var humidity_factor = calculate_factor(current_table.humidity, preferred_humidity, 0.3)

	# Combined modifier (average of all factors)
	return (light_factor + temp_factor + humidity_factor) / 3.0

func calculate_factor(current: float, preferred: float, tolerance: float) -> float:
	# Returns 1.0 when current == preferred, decreasing as they diverge
	var difference = abs(current - preferred)
	return max(0.0, 1.0 - (difference / tolerance))

func update_sprite() -> void:
	if plant_sprite:
		plant_sprite.frame = min(growth_stage, plant_sprite.sprite_frames.get_frame_count("default") - 1)

func set_current_table(table: Table) -> void:
	current_table = table

func get_current_table() -> Table:
	return current_table

func get_growth_percentage() -> float:
	return (growth_progress / float(max_growth_stages)) * 100.0

func reset_growth() -> void:
	growth_progress = 0.0
	growth_stage = 0
	is_fully_grown = false
	update_sprite()
