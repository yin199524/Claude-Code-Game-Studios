# main_menu.gd - 主菜单场景脚本
extends Control


func _ready() -> void:
	# 连接按钮信号
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)


func _on_start_pressed() -> void:
	# 直接进入战斗布局场景（测试用）
	get_tree().change_scene_to_file("res://scenes/battle/battle_setup.tscn")


func _on_settings_pressed() -> void:
	GameManager.enter_settings()


func _on_quit_pressed() -> void:
	get_tree().quit()
