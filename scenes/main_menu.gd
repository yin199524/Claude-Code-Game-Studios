# main_menu.gd - 主菜单场景脚本
extends Control

## 背景动画时间
var bg_time: float = 0.0

## 背景装饰节点
var decor_nodes: Array[Node] = []

## 金币标签
var gold_label: Label = null

## 成就通知
var achievement_notification: Control = null


func _ready() -> void:
	# 连接按钮信号
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

	# 创建背景装饰
	_create_background_decor()

	# 创建顶部信息栏
	_create_top_bar()

	# 创建成就通知
	_create_achievement_notification()

	# 创建引导提示组件
	_create_tutorial_hint()

	# 连接存档变化信号
	SaveManager.data_changed.connect(_update_gold_display)

	# 检查是否显示欢迎引导
	_check_welcome_tutorial()


func _process(delta: float) -> void:
	bg_time += delta
	_animate_decor(delta)


## 创建背景装饰
func _create_background_decor() -> void:
	# 创建浮动的光点效果
	for i in range(8):
		var decor = ColorRect.new()
		decor.color = Color(0.3, 0.5, 0.7, 0.08)
		decor.size = Vector2(randf_range(30, 80), randf_range(30, 80))
		decor.position = Vector2(randf_range(0, 720), randf_range(0, 1280))
		decor.rotation = randf_range(0, PI * 2)
		decor.z_index = -1
		add_child(decor)
		decor_nodes.append(decor)


## 动画装饰
func _animate_decor(delta: float) -> void:
	for i in range(decor_nodes.size()):
		var decor = decor_nodes[i]
		# 缓慢飘动
		var speed = 8.0 + i * 3.0
		var offset_y = sin(bg_time * 0.5 + i) * speed * delta
		var offset_x = cos(bg_time * 0.3 + i * 0.7) * speed * 0.5 * delta
		decor.position.y += offset_y
		decor.position.x += offset_x
		decor.rotation += sin(bg_time * 0.2 + i) * 0.005

		# 循环
		if decor.position.y > 1300:
			decor.position.y = -100
		if decor.position.x > 800:
			decor.position.x = -100
		elif decor.position.x < -100:
			decor.position.x = 800


## 创建顶部信息栏
func _create_top_bar() -> void:
	var top_bar = PanelContainer.new()
	top_bar.name = "TopBar"
	top_bar.custom_minimum_size.y = 50
	top_bar.anchors_preset = Control.PRESET_TOP_WIDE
	top_bar.offset_bottom = 50

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.18, 0.22, 0.9)
	style.border_color = Color(0.25, 0.3, 0.4, 1)
	style.set_border_width_all(0)
	style.border_width_bottom = 2
	top_bar.add_theme_stylebox_override("panel", style)
	add_child(top_bar)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	top_bar.add_child(hbox)

	# 左侧边距
	var left_spacer = Control.new()
	left_spacer.custom_minimum_size.x = 15
	hbox.add_child(left_spacer)

	# 金币显示
	var gold_container = HBoxContainer.new()
	gold_container.add_theme_constant_override("separation", 6)
	hbox.add_child(gold_container)

	var gold_icon = Label.new()
	gold_icon.text = "🪙"
	gold_icon.add_theme_font_size_override("font_size", 18)
	gold_container.add_child(gold_icon)

	gold_label = Label.new()
	gold_label.text = "%d" % SaveManager.get_gold()
	gold_label.add_theme_font_size_override("font_size", 16)
	gold_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	gold_container.add_child(gold_label)

	# 中间占位
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# 每日任务按钮
	var mission_btn = Button.new()
	mission_btn.text = "📋 任务"
	mission_btn.custom_minimum_size = Vector2(80, 36)
	ButtonStyles.apply_secondary(mission_btn)
	mission_btn.pressed.connect(_on_mission_pressed)
	hbox.add_child(mission_btn)

	# 成就按钮
	var achievement_btn = Button.new()
	achievement_btn.text = "🏆 成就"
	achievement_btn.custom_minimum_size = Vector2(80, 36)
	ButtonStyles.apply_secondary(achievement_btn)
	achievement_btn.pressed.connect(_on_achievement_pressed)
	hbox.add_child(achievement_btn)

	# 统计按钮
	var stats_btn = Button.new()
	stats_btn.text = "📊 统计"
	stats_btn.custom_minimum_size = Vector2(80, 36)
	ButtonStyles.apply_secondary(stats_btn)
	stats_btn.pressed.connect(_on_stats_pressed)
	hbox.add_child(stats_btn)

	# 右侧边距
	var right_spacer = Control.new()
	right_spacer.custom_minimum_size.x = 15
	hbox.add_child(right_spacer)


## 更新金币显示
func _update_gold_display() -> void:
	if gold_label:
		gold_label.text = "%d" % SaveManager.get_gold()


## 创建成就通知
func _create_achievement_notification() -> void:
	var notification_scene = preload("res://scenes/achievement/achievement_notification.gd")
	achievement_notification = Control.new()
	achievement_notification.set_script(notification_scene)
	achievement_notification.anchors_preset = Control.PRESET_CENTER_TOP
	achievement_notification.offset_left = -200
	achievement_notification.offset_right = 200
	achievement_notification.offset_top = 70
	achievement_notification.offset_bottom = 150
	add_child(achievement_notification)


func _on_start_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	GameManager.enter_level_select()
	SceneTransition.change_scene("res://scenes/level/level_select.tscn")


func _on_settings_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	GameManager.enter_settings()


func _on_quit_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	var dialog = preload("res://scenes/dialog/confirm_dialog.tscn").instantiate()
	dialog.dialog_title = "退出游戏"
	dialog.dialog_message = "确定要退出游戏吗？"
	dialog.confirm_text = "退出"
	dialog.cancel_text = "取消"
	dialog.is_dangerous = true
	dialog.confirmed.connect(_execute_quit)
	add_child(dialog)


func _execute_quit() -> void:
	get_tree().quit()


func _on_achievement_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	SceneTransition.change_scene("res://scenes/achievement/achievement_panel.tscn")


func _on_mission_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	SceneTransition.change_scene("res://scenes/daily_mission/daily_mission_panel.tscn")


func _on_stats_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	var panel = preload("res://scenes/statistics/statistics_panel.tscn").instantiate()
	panel.close_requested.connect(_on_stats_closed.bind(panel))
	add_child(panel)


func _on_stats_closed(panel: Control) -> void:
	panel.queue_free()


## 创建引导提示组件
func _create_tutorial_hint() -> void:
	var hint_scene = preload("res://scenes/tutorial/tutorial_hint.gd")
	var tutorial_hint = Control.new()
	tutorial_hint.set_script(hint_scene)
	tutorial_hint.name = "TutorialHint"
	tutorial_hint.anchors_preset = Control.PRESET_FULL_RECT
	add_child(tutorial_hint)


## 检查是否显示欢迎引导
func _check_welcome_tutorial() -> void:
	# 延迟一帧检查，确保 TutorialManager 已初始化
	await get_tree().process_frame

	if TutorialManager.should_show_tutorial(TutorialManager.TutorialID.WELCOME):
		_show_welcome_screen()


## 显示欢迎界面
func _show_welcome_screen() -> void:
	var welcome = preload("res://scenes/tutorial/welcome_screen.tscn").instantiate()
	welcome.welcome_completed.connect(_on_welcome_completed)
	add_child(welcome)


## 欢迎完成回调
func _on_welcome_completed() -> void:
	# 可以在这里执行欢迎完成后的操作
	pass
