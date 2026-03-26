# statistics_panel.gd - 统计数据面板
# 显示玩家的游戏统计数据

extends Control

## 信号

## 关闭面板
signal close_requested()

## 变量

## 统计项容器
var stats_container: VBoxContainer

## 统计项数据
var stats_config: Array[Dictionary] = [
	{"id": "play_time", "label": "游戏时长", "icon": "⏱"},
	{"id": "total_gold_earned", "label": "累计获得金币", "icon": "🪙"},
	{"id": "enemies_defeated", "label": "击败敌人", "icon": "⚔"},
	{"id": "synergies_triggered", "label": "触发协同", "icon": "✨"},
	{"id": "levels_completed", "label": "通关关卡", "icon": "🗺"},
	{"id": "total_stars", "label": "获得星级", "icon": "⭐"},
	{"id": "units_owned", "label": "拥有单位", "icon": "👥"},
	{"id": "achievements_unlocked", "label": "解锁成就", "icon": "🏆"},
	{"id": "max_win_streak", "label": "最高连胜", "icon": "🔥"},
]


func _ready() -> void:
	_setup_ui()
	_update_statistics()


func _setup_ui() -> void:
	# 全屏背景遮罩
	var overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0, 0, 0, 0.7)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.gui_input.connect(_on_overlay_input)
	add_child(overlay)

	# 主面板
	var main_panel = PanelContainer.new()
	main_panel.name = "MainPanel"
	main_panel.anchors_preset = Control.PRESET_CENTER
	main_panel.offset_left = -280
	main_panel.offset_right = 280
	main_panel.offset_top = -350
	main_panel.offset_bottom = 200

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.14, 0.18, 0.98)
	panel_style.border_color = Color(0.3, 0.4, 0.55, 1)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	main_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(main_panel)

	# 内容容器
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_panel.add_child(vbox)

	# 标题栏
	var title_bar = HBoxContainer.new()
	title_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(title_bar)

	var title_label = Label.new()
	title_label.text = "📊 游戏统计"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1))
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_bar.add_child(title_label)

	# 关闭按钮
	var close_btn = Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(36, 36)
	close_btn.pressed.connect(_on_close_pressed)
	_setup_close_button_style(close_btn)
	title_bar.add_child(close_btn)

	# 分隔线
	var separator = HSeparator.new()
	separator.add_theme_stylebox_override("separator", _create_separator_style())
	vbox.add_child(separator)

	# 统计项容器
	stats_container = VBoxContainer.new()
	stats_container.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_container.add_theme_constant_override("separation", 8)
	vbox.add_child(stats_container)

	# 底部间隔
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 10
	vbox.add_child(spacer)


func _setup_close_button_style(button: Button) -> void:
	ButtonStyles.apply_danger(button)
	button.custom_minimum_size = Vector2(36, 36)


func _create_separator_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.35, 0.4, 1)
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	return style


func _update_statistics() -> void:
	# 清空现有统计项
	for child in stats_container.get_children():
		child.queue_free()

	# 获取统计数据
	var stats = _get_player_statistics()

	# 创建统计项
	for config in stats_config:
		var stat_row = _create_stat_row(config, stats)
		stats_container.add_child(stat_row)


func _get_player_statistics() -> Dictionary:
	var player_data = SaveManager.player_data
	if player_data == null:
		return {}

	return player_data.get_statistics()


func _create_stat_row(config: Dictionary, stats: Dictionary) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)

	# 左侧边距
	var left_spacer = Control.new()
	left_spacer.custom_minimum_size.x = 20
	row.add_child(left_spacer)

	# 图标
	var icon_label = Label.new()
	icon_label.text = config.get("icon", "•")
	icon_label.add_theme_font_size_override("font_size", 20)
	icon_label.custom_minimum_size.x = 30
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(icon_label)

	# 标签
	var label = Label.new()
	label.text = config.get("label", "")
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.75, 0.78, 0.82, 1))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)

	# 值
	var value = stats.get(config.get("id", ""), 0)
	var value_label = Label.new()
	value_label.text = _format_value(config.get("id", ""), value)
	value_label.add_theme_font_size_override("font_size", 16)
	value_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.custom_minimum_size.x = 100
	row.add_child(value_label)

	# 右侧边距
	var right_spacer = Control.new()
	right_spacer.custom_minimum_size.x = 20
	row.add_child(right_spacer)

	return row


func _format_value(stat_id: String, value) -> String:
	match stat_id:
		"total_gold_earned", "enemies_defeated", "synergies_triggered":
			return str(value)
		"levels_completed":
			return "%d 关" % value
		"total_stars":
			return "⭐ %d" % value
		"units_owned":
			return "%d 个" % value
		"achievements_unlocked":
			return "%d 个" % value
		"max_win_streak":
			if value > 0:
				return "🔥 %d 连胜" % value
			else:
				return "—"
		_:
			return str(value)


func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_close_pressed()


func _on_close_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	close_requested.emit()
	queue_free()


## 显示统计面板（静态方法）
static func show(parent: Node) -> Control:
	var panel = preload("res://scenes/statistics/statistics_panel.tscn").instantiate()
	parent.add_child(panel)
	return panel
