extends Node
class_name UIManagerClass

const MessageBoxScene = preload("res://scenes/ui/message_box.tscn")
const ToastScene = preload("res://scenes/ui/toast.tscn")
const CountdownTimerScene = preload("res://scenes/ui/countdown_timer.tscn")
const PauseMenuScene = preload("res://scenes/ui/pause_menu.tscn")
const HelpScreenScene = preload("res://scenes/ui/help_screen.tscn")
const TableInfoScene = preload("res://scenes/ui/table_info.tscn")

var _message_box: MessageBox
var _toast: Toast
var _countdown_timer: CountdownTimer
var _pause_menu: PauseMenu
var _help_screen: HelpScreen
var _table_info: TableInfo


func _ready() -> void:
	_message_box = MessageBoxScene.instantiate()
	add_child(_message_box)

	_toast = ToastScene.instantiate()
	add_child(_toast)

	_countdown_timer = CountdownTimerScene.instantiate()
	add_child(_countdown_timer)

	_pause_menu = PauseMenuScene.instantiate()
	add_child(_pause_menu)

	_help_screen = HelpScreenScene.instantiate()
	add_child(_help_screen)

	_table_info = TableInfoScene.instantiate()
	add_child(_table_info)


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


func show_pause_menu() -> void:
	_pause_menu.show_pause()


func hide_pause_menu() -> void:
	_pause_menu._on_resume_pressed()


func is_paused() -> bool:
	return _pause_menu.visible


func get_pause_menu() -> PauseMenu:
	return _pause_menu


func show_help() -> void:
	_help_screen.show_help()


func hide_help() -> void:
	_help_screen._on_close_pressed()


func is_help_visible() -> bool:
	return _help_screen.visible


func get_help_screen() -> HelpScreen:
	return _help_screen


func show_table_info(table: Table) -> void:
	_table_info.show_info(table)


func hide_table_info() -> void:
	_table_info.hide_info()


func get_table_info() -> TableInfo:
	return _table_info
