extends CanvasLayer
class_name TrayInfo

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/MarginContainer/HBox/TitleLabel
@onready var growth_bar: ProgressBar = $Panel/MarginContainer/HBox/GrowthRow/GrowthBar
@onready var stage_label: Label = $Panel/MarginContainer/HBox/StageLabel
@onready var efficiency_bar: ProgressBar = $Panel/MarginContainer/HBox/EfficiencyRow/EfficiencyBar

var _tween: Tween
var _current_tray: PlantTray


func _ready() -> void:
	panel.modulate.a = 0.0
	hide()


func _process(_delta: float) -> void:
	if visible and _current_tray:
		_update_values()


func show_info(tray: PlantTray) -> void:
	if _current_tray == tray and visible:
		_update_values()
		return

	_current_tray = tray
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
	if not _current_tray:
		return

	if _current_tray.is_fully_grown:
		title_label.text = "Tray (Mature)"
	else:
		title_label.text = "Tray"

	growth_bar.value = _current_tray.get_growth_percentage()
	stage_label.text = "Stage %d/%d" % [_current_tray.growth_stage, _current_tray.max_growth_stages]

	var efficiency = _current_tray.calculate_growth_modifier() * 100.0
	efficiency_bar.value = efficiency


func get_current_tray() -> PlantTray:
	return _current_tray
