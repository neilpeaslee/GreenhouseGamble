extends Node
class_name UIManagerClass

const MessageBoxScene = preload("res://scenes/ui/message_box.tscn")
const ToastScene = preload("res://scenes/ui/toast.tscn")
const CountdownTimerScene = preload("res://scenes/ui/countdown_timer.tscn")

var _message_box: MessageBox
var _toast: Toast
var _countdown_timer: CountdownTimer


func _ready() -> void:
	_message_box = MessageBoxScene.instantiate()
	add_child(_message_box)

	_toast = ToastScene.instantiate()
	add_child(_toast)

	_countdown_timer = CountdownTimerScene.instantiate()
	add_child(_countdown_timer)


func show_message(text: String, button_text: String = "OK") -> void:
	_message_box.show_message(text, button_text)


func show_toast(text: String, duration: float = 2.5) -> void:
	_toast.show_toast(text, duration)


func get_message_box() -> MessageBox:
	return _message_box


func get_toast() -> Toast:
	return _toast


func start_countdown(duration: float, message: String = "Next spawn in:") -> void:
	_countdown_timer.start_countdown(duration, message)


func stop_countdown() -> void:
	_countdown_timer.stop()


func update_countdown(time_remaining: float, message: String = "") -> void:
	_countdown_timer.update_time(time_remaining, message)


func get_countdown_timer() -> CountdownTimer:
	return _countdown_timer
