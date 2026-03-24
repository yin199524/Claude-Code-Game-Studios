# main_menu.gd - 主菜单场景脚本
extends Control


func _ready() -> void:
	# 连接按钮信号
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _on_start_pressed() -> void:
	GameManager.enter_level_select()


func _on_settings_pressed() -> void:
	GameManager.enter_settings()


func _on_quit_pressed() -> void:
	get_tree().quit()
