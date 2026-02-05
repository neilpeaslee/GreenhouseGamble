extends CanvasLayer
class_name TableInfo

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/MarginContainer/HBox/TitleLabel
@onready var light_bar: ProgressBar = $Panel/MarginContainer/HBox/LightRow/LightBar
@onready var temp_bar: ProgressBar = $Panel/MarginContainer/HBox/TempRow/TempBar
@onready var humid_bar: ProgressBar = $Panel/MarginContainer/HBox/HumidRow/HumidBar
@onready var trays_label: Label = $Panel/MarginContainer/HBox/TraysLabel

var _tween: Tween
var _current_table: Table


func _ready() -> void:
	panel.modulate.a = 0.0
	hide()


func show_info(table: Table) -> void:
	if _current_table == table and visible:
		return

	_current_table = table
	_update_values()
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
