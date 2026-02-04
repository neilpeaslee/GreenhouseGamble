extends CanvasLayer
class_name PauseMenu

signal resumed
signal restart_game
signal quit_game

@onready var resume_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $CenterContainer/Panel/MarginContainer/VBoxContainer/QuitButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	hide()


func show_pause() -> void:
	get_tree().paused = true
	show()
	resume_button.grab_focus()


func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false
	resumed.emit()


func _on_restart_pressed() -> void:
	hide()
	get_tree().paused = false
	restart_game.emit()
	get_tree().reload_current_scene()


func _on_quit_pressed() -> void:
	hide()
	get_tree().paused = false
	quit_game.emit()
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_resume_pressed()
		get_viewport().set_input_as_handled()
