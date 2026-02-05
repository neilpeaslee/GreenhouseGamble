extends CanvasLayer
class_name CountdownTimer

signal countdown_finished
signal countdown_tick(time_remaining: float)

@onready var panel: PanelContainer = $Panel
@onready var time_label: Label = $Panel/MarginContainer/TimeLabel

var _time_remaining: float = 0.0
var _is_running: bool = false


func _ready() -> void:
	hide()


func _process(delta: float) -> void:
	if not _is_running:
		return

	_time_remaining -= delta
	countdown_tick.emit(_time_remaining)

	if _time_remaining <= 0.0:
		_time_remaining = 0.0
		_update_display()
		stop()
		countdown_finished.emit()
	else:
		_update_display()


func start_countdown(duration: float, _message: String = "") -> void:
	_time_remaining = duration
	_is_running = true
	_update_display()
	show()


func update_time(time_remaining: float, _message: String = "") -> void:
	_time_remaining = time_remaining
	_update_display()
	if not visible:
		show()


func stop() -> void:
	_is_running = false
	hide()


func pause() -> void:
	_is_running = false


func resume() -> void:
	if _time_remaining > 0.0:
		_is_running = true
		show()


func get_time_remaining() -> float:
	return _time_remaining


func is_running() -> bool:
	return _is_running


func _update_display() -> void:
	time_label.text = "%d" % ceili(_time_remaining)
