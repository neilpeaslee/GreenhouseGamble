extends CanvasLayer
class_name TableInfo

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/MarginContainer/HBox/TitleLabel
@onready var light_bar: ProgressBar = $Panel/MarginContainer/HBox/LightRow/LightBar
@onready var temp_bar: ProgressBar = $Panel/MarginContainer/HBox/TempRow/TempBar
@onready var humid_bar: ProgressBar = $Panel/MarginContainer/HBox/HumidRow/HumidBar
@onready var trays_label: Label = $Panel/MarginContainer/HBox/TraysLabel

@onready var light_low_marker: ColorRect = $Panel/MarginContainer/HBox/LightRow/LightBar/LowMarker
@onready var light_high_marker: ColorRect = $Panel/MarginContainer/HBox/LightRow/LightBar/HighMarker
@onready var temp_low_marker: ColorRect = $Panel/MarginContainer/HBox/TempRow/TempBar/LowMarker
@onready var temp_high_marker: ColorRect = $Panel/MarginContainer/HBox/TempRow/TempBar/HighMarker
@onready var humid_low_marker: ColorRect = $Panel/MarginContainer/HBox/HumidRow/HumidBar/LowMarker
@onready var humid_high_marker: ColorRect = $Panel/MarginContainer/HBox/HumidRow/HumidBar/HighMarker

const LIGHT_TOLERANCE: float = 0.5
const TEMP_TOLERANCE: float = 10.0
const HUMID_TOLERANCE: float = 0.3

var _tween: Tween
var _current_table: Table
var _current_tray: PlantTray


func _ready() -> void:
	panel.modulate.a = 0.0
	hide()


func _process(_delta: float) -> void:
	if visible and _current_table:
		_update_values()


func show_info(table: Table, tray: PlantTray = null) -> void:
	if _current_table == table and _current_tray == tray and visible:
		return

	_current_table = table
	_current_tray = tray
	_update_values()
	_update_range_indicators()
	show()

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)

	panel.modulate.a = 0.0
	panel.offset_top = 432.0
	panel.offset_bottom = 482.0

	_tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	_tween.parallel().tween_property(panel, "offset_top", 382.0, 0.2)
	_tween.parallel().tween_property(panel, "offset_bottom", 432.0, 0.2)


func hide_info() -> void:
	if not visible:
		return

	_current_table = null
	_current_tray = null

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_CUBIC)

	_tween.tween_property(panel, "modulate:a", 0.0, 0.2)
	_tween.parallel().tween_property(panel, "offset_top", 432.0, 0.2)
	_tween.parallel().tween_property(panel, "offset_bottom", 482.0, 0.2)
	_tween.tween_callback(hide)


func _update_values() -> void:
	if not _current_table:
		return

	title_label.text = "Table %d" % _current_table.table_id
	light_bar.value = _current_table.light_level
	temp_bar.value = _current_table.temperature
	humid_bar.value = _current_table.humidity

	var tray_count = _current_table.get_tray_count()
	var total_slots = 6
	trays_label.text = "Trays: %d/%d" % [tray_count, total_slots]


func get_current_table() -> Table:
	return _current_table


func _update_range_indicators() -> void:
	if not _current_tray:
		_hide_all_markers()
		return

	_position_markers(
		light_bar, light_low_marker, light_high_marker,
		_current_tray.preferred_light, LIGHT_TOLERANCE
	)
	_position_markers(
		temp_bar, temp_low_marker, temp_high_marker,
		_current_tray.preferred_temperature, TEMP_TOLERANCE
	)
	_position_markers(
		humid_bar, humid_low_marker, humid_high_marker,
		_current_tray.preferred_humidity, HUMID_TOLERANCE
	)


func _position_markers(bar: ProgressBar, low_marker: ColorRect, high_marker: ColorRect,
		preferred: float, tolerance: float) -> void:
	var bar_width = bar.custom_minimum_size.x
	var low_value = max(bar.min_value, preferred - tolerance)
	var high_value = min(bar.max_value, preferred + tolerance)

	var low_pos = (low_value / bar.max_value) * bar_width
	var high_pos = (high_value / bar.max_value) * bar_width

	low_marker.offset_left = low_pos - 1
	low_marker.offset_right = low_pos + 1
	low_marker.visible = true

	high_marker.offset_left = high_pos - 1
	high_marker.offset_right = high_pos + 1
	high_marker.visible = true


func _hide_all_markers() -> void:
	light_low_marker.visible = false
	light_high_marker.visible = false
	temp_low_marker.visible = false
	temp_high_marker.visible = false
	humid_low_marker.visible = false
	humid_high_marker.visible = false
