extends Node
class_name UIManagerClass

const MessageBoxScene = preload("res://scenes/ui/message_box.tscn")
const ToastScene = preload("res://scenes/ui/toast.tscn")

var _message_box: MessageBox
var _toast: Toast


func _ready() -> void:
	_message_box = MessageBoxScene.instantiate()
	add_child(_message_box)

	_toast = ToastScene.instantiate()
	add_child(_toast)


func show_message(text: String, button_text: String = "OK") -> void:
	_message_box.show_message(text, button_text)


func show_toast(text: String, duration: float = 2.5) -> void:
	_toast.show_toast(text, duration)


func get_message_box() -> MessageBox:
	return _message_box


func get_toast() -> Toast:
	return _toast
