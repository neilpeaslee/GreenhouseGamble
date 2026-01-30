extends CanvasLayer
class_name MessageBox

signal dismissed

@onready var panel: PanelContainer = $CenterContainer/Panel
@onready var message_label: Label = $CenterContainer/Panel/MarginContainer/VBoxContainer/MessageLabel
@onready var ok_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/OKButton

var _previous_pause_state: bool = false


func _ready() -> void:
	ok_button.pressed.connect(_on_ok_pressed)
	hide()


func show_message(text: String, button_text: String = "OK") -> void:
	message_label.text = text
	ok_button.text = button_text

	_previous_pause_state = get_tree().paused
	get_tree().paused = true

	show()
	ok_button.grab_focus()


func _on_ok_pressed() -> void:
	hide()
	get_tree().paused = _previous_pause_state
	dismissed.emit()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_accept"):
		_on_ok_pressed()
		get_viewport().set_input_as_handled()
