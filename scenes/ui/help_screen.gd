extends CanvasLayer
class_name HelpScreen

signal closed

@onready var close_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/CloseButton


func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	hide()


func show_help() -> void:
	get_tree().paused = true
	show()
	close_button.grab_focus()


func _on_close_pressed() -> void:
	hide()
	get_tree().paused = false
	closed.emit()


func _input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("show_help")):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
