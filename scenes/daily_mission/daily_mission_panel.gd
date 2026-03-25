# daily_mission_panel.gd - 每日任务面板场景脚本
# 显示当前任务、进度和奖励领取

extends Control

## 任务列表容器
var mission_list: VBoxContainer = null

## 刷新倒计时标签
var refresh_timer_label: Label = null


func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_populate_missions()
	_start_refresh_timer()


func _setup_ui() -> void:
	# 背景
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.12, 0.14, 0.18, 1)
	bg.anchors_preset = Control.PRESET_FULL_RECT
	add_child(bg)

	# 主容器
	var main_vbox = VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.anchors_preset = Control.PRESET_FULL_RECT
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)

	# 顶部栏
	var header = _create_header()
	main_vbox.add_child(header)

	# 刷新倒计时
	var timer_bar = _create_timer_bar()
	main_vbox.add_child(timer_bar)

	# 滚动容器
	var scroll_container = ScrollContainer.new()
	scroll_container.name = "ScrollContainer"
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	main_vbox.add_child(scroll_container)

	# 任务列表
	mission_list = VBoxContainer.new()
	mission_list.name = "MissionList"
	mission_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mission_list.add_theme_constant_override("separation", 12)
	scroll_container.add_child(mission_list)


func _create_header() -> Control:
	var header = PanelContainer.new()
	header.name = "Header"
	header.custom_minimum_size.y = 60

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.18, 0.25, 1)
	style.border_color = Color(0.25, 0.3, 0.4, 1)
	style.set_border_width_all(0)
	style.border_width_bottom = 2
	header.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	header.add_child(hbox)

	# 返回按钮
	var back_button = Button.new()
	back_button.text = "← 返回"
	back_button.custom_minimum_size.x = 80
	back_button.pressed.connect(_on_back_pressed)
	hbox.add_child(back_button)

	# 标题
	var title = Label.new()
	title.text = "📋 每日任务"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(title)

	# 占位
	var spacer = Control.new()
	spacer.custom_minimum_size.x = 80
	hbox.add_child(spacer)

	return header


func _create_timer_bar() -> Control:
	var bar = PanelContainer.new()
	bar.name = "TimerBar"
	bar.custom_minimum_size.y = 36

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.16, 1)
	bar.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 8)
	bar.add_child(hbox)

	var icon = Label.new()
	icon.text = "⏰"
	icon.add_theme_font_size_override("font_size", 16)
	hbox.add_child(icon)

	refresh_timer_label = Label.new()
	refresh_timer_label.text = "距离刷新: --:--:--"
	refresh_timer_label.add_theme_font_size_override("font_size", 14)
	refresh_timer_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7, 1))
	hbox.add_child(refresh_timer_label)

	return bar


func _connect_signals() -> void:
	DailyMissionManager.mission_completed.connect(_on_mission_completed)
	DailyMissionManager.reward_claimed.connect(_on_reward_claimed)
	DailyMissionManager.mission_progress_updated.connect(_on_progress_updated)


func _populate_missions() -> void:
	# 清空列表
	for child in mission_list.get_children():
		child.queue_free()

	await get_tree().process_frame

	# 获取任务列表
	var missions = DailyMissionManager.get_active_missions()

	# 创建任务项
	for mission in missions:
		var item = _create_mission_item(mission)
		mission_list.add_child(item)

	# 添加底部的提示
	if missions.is_empty():
		var empty_label = Label.new()
		empty_label.text = "暂无任务，请稍后再来"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 16)
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6, 1))
		mission_list.add_child(empty_label)


func _create_mission_item(mission: DailyMissionDefinition) -> Control:
	var is_completed = DailyMissionManager.is_mission_completed(mission.id)
	var is_claimed = DailyMissionManager.is_mission_claimed(mission.id)
	var progress = DailyMissionManager.get_progress(mission.id)

	var panel = PanelContainer.new()
	panel.custom_minimum_size.y = 100

	var style = StyleBoxFlat.new()
	if is_claimed:
		style.bg_color = Color(0.12, 0.14, 0.16, 1)
		style.border_color = Color(0.3, 0.35, 0.4, 1)
	elif is_completed:
		style.bg_color = Color(0.18, 0.2, 0.15, 1)
		style.border_color = Color(0.5, 0.7, 0.3, 1)
	else:
		style.bg_color = Color(0.15, 0.18, 0.22, 1)
		style.border_color = Color(0.3, 0.35, 0.45, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	# 上排：名称和奖励
	var top_row = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 10)
	vbox.add_child(top_row)

	# 任务图标
	var icon_label = Label.new()
	icon_label.text = _get_mission_icon(mission.mission_type)
	icon_label.add_theme_font_size_override("font_size", 24)
	top_row.add_child(icon_label)

	# 任务名称
	var name_label = Label.new()
	name_label.text = mission.display_name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if is_claimed:
		name_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6, 1))
	else:
		name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	top_row.add_child(name_label)

	# 奖励显示
	var reward_hbox = HBoxContainer.new()
	reward_hbox.add_theme_constant_override("separation", 4)
	top_row.add_child(reward_hbox)

	var reward_icon = Label.new()
	reward_icon.text = "🪙"
	reward_icon.add_theme_font_size_override("font_size", 16)
	reward_hbox.add_child(reward_icon)

	var reward_label = Label.new()
	reward_label.text = "%d" % mission.reward_gold
	reward_label.add_theme_font_size_override("font_size", 14)
	if is_claimed:
		reward_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.5, 1))
	else:
		reward_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	reward_hbox.add_child(reward_label)

	# 描述
	var desc_label = Label.new()
	desc_label.text = mission.description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7, 1))
	vbox.add_child(desc_label)

	# 下排：进度条和按钮
	var bottom_row = HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 10)
	vbox.add_child(bottom_row)

	if is_claimed:
		# 已领取
		var claimed_label = Label.new()
		claimed_label.text = "✓ 已领取"
		claimed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		claimed_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		claimed_label.add_theme_font_size_override("font_size", 16)
		claimed_label.add_theme_color_override("font_color", Color(0.5, 0.6, 0.5, 1))
		bottom_row.add_child(claimed_label)
	else:
		# 进度条
		var progress_bar = ProgressBar.new()
		progress_bar.max_value = mission.target_value
		progress_bar.value = progress
		progress_bar.custom_minimum_size.y = 16
		progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		progress_bar.show_percentage = false
		bottom_row.add_child(progress_bar)

		# 进度文本
		var progress_text = Label.new()
		progress_text.text = "%d/%d" % [progress, mission.target_value]
		progress_text.custom_minimum_size.x = 60
		progress_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		progress_text.add_theme_font_size_override("font_size", 12)
		progress_text.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7, 1))
		bottom_row.add_child(progress_text)

		# 领取按钮
		if is_completed:
			var claim_button = Button.new()
			claim_button.text = "领取"
			claim_button.custom_minimum_size = Vector2(70, 32)
			claim_button.pressed.connect(_on_claim_pressed.bind(mission.id))
			bottom_row.add_child(claim_button)
		else:
			var status_label = Label.new()
			status_label.text = "进行中"
			status_label.custom_minimum_size.x = 70
			status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			status_label.add_theme_font_size_override("font_size", 12)
			status_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6, 1))
			bottom_row.add_child(status_label)

	return panel


func _get_mission_icon(mission_type: int) -> String:
	match mission_type:
		Global.DailyMissionType.WIN_LEVELS:
			return "🎯"
		Global.DailyMissionType.UPGRADE_UNITS:
			return "⬆"
		Global.DailyMissionType.BUY_UNITS:
			return "🛒"
		Global.DailyMissionType.DEFEAT_ENEMIES:
			return "⚔"
		Global.DailyMissionType.TRIGGER_SYNERGY:
			return "🔗"
	return "📋"


func _start_refresh_timer() -> void:
	_update_timer_display()


func _process(_delta: float) -> void:
	_update_timer_display()


func _update_timer_display() -> void:
	if refresh_timer_label == null:
		return

	var seconds = DailyMissionManager.get_time_until_refresh()
	var hours = seconds / 3600
	var minutes = (seconds % 3600) / 60
	var secs = seconds % 60

	refresh_timer_label.text = "距离刷新: %02d:%02d:%02d" % [hours, minutes, secs]


func _on_back_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	SceneTransition.change_scene("res://scenes/main_menu.tscn")


func _on_claim_pressed(mission_id: String) -> void:
	SoundManager.play_sfx(SoundManager.SFX.PURCHASE_SUCCESS)
	DailyMissionManager.claim_reward(mission_id)


func _on_mission_completed(_mission_id: String) -> void:
	_populate_missions()


func _on_reward_claimed(_mission_id: String, _gold: int) -> void:
	_populate_missions()


func _on_progress_updated(_mission_id: String, _current: int, _target: int) -> void:
	_populate_missions()
