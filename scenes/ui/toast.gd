extends CanvasLayer
class_name Toast

signal finished

@onready var panel: PanelContainer = $Panel
@onready var message_label: Label = $Panel/MarginContainer/MessageLabel

var _tween: Tween


func _ready() -> void:
	panel.modulate.a = 0.0
	hide()


func show_toast(text: String, duration: float = 2.5) -> void:
	message_label.text = text
	show()

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)

	panel.modulate.a = 0.0
	panel.position.y = 20

	_tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	_tween.parallel().tween_property(panel, "position:y", 0.0, 0.2)

	_tween.tween_interval(duration)

	_tween.tween_property(panel, "modulate:a", 0.0, 0.3)
	_tween.parallel().tween_property(panel, "position:y", -10.0, 0.3)

	_tween.tween_callback(_on_finished)


func _on_finished() -> void:
	hide()
	finished.emit()
