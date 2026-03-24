# level_select.gd - 关卡选择场景脚本
# 显示关卡列表，处理关卡选择和解锁状态

extends Control

## 关卡按钮场景（动态创建）
var level_button_scene: PackedScene = null

## 当前选中的关卡
var selected_level_id: String = ""


func _ready() -> void:
	_connect_signals()
	_update_gold_display()
	_populate_level_list()


func _connect_signals() -> void:
	$VBoxContainer/Header/BackButton.pressed.connect(_on_back_pressed)
	$VBoxContainer/Footer/ShopButton.pressed.connect(_on_shop_pressed)


## 更新金币显示
func _update_gold_display() -> void:
	var label = $VBoxContainer/Header/GoldDisplay/GoldLabel
	label.text = "%d" % SaveManager.get_gold()


## 填充关卡列表
func _populate_level_list() -> void:
	var list = $VBoxContainer/LevelList/LevelListContent

	# 清空现有按钮
	for child in list.get_children():
		child.queue_free()

	# 等待子节点释放
	await get_tree().process_frame

	# 添加所有关卡
	var levels = LevelDatabase.get_all_levels()
	levels.sort_custom(func(a, b): return a.difficulty < b.difficulty)

	for level in levels:
		var btn = _create_level_button(level)
		list.add_child(btn)


## 创建关卡按钮
func _create_level_button(level: LevelDefinition) -> Control:
	# 外层容器（用于边框和阴影）
	var panel = PanelContainer.new()
	panel.custom_minimum_size.y = 100

	var is_unlocked = LevelDatabase.is_level_unlocked(level.id)
	var is_completed = LevelDatabase.is_level_completed(level.id)

	# 创建样式
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.22, 0.3, 1) if is_unlocked else Color(0.12, 0.14, 0.18, 1)
	style.border_color = Color(0.4, 0.5, 0.65, 1) if is_unlocked else Color(0.2, 0.25, 0.3, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)
	panel.add_theme_stylebox_override("panel", style)

	# 内层容器
	var container = HBoxContainer.new()
	panel.add_child(container)

	# 左侧：关卡编号
	var number_panel = PanelContainer.new()
	number_panel.custom_minimum_size.x = 60
	var number_style = StyleBoxFlat.new()
	number_style.bg_color = Color(0.25, 0.3, 0.4, 1) if is_unlocked else Color(0.15, 0.18, 0.22, 1)
	number_style.set_corner_radius_all(8)
	number_panel.add_theme_stylebox_override("panel", number_style)
	container.add_child(number_panel)

	var number_label = Label.new()
	number_label.text = str(level.difficulty)
	number_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	number_label.add_theme_font_size_override("font_size", 32)
	number_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1) if is_unlocked else Color(0.4, 0.45, 0.5, 1))
	number_panel.add_child(number_label)

	# 中间：关卡信息
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	container.add_child(info)

	# 关卡名称
	var name_label = Label.new()
	name_label.text = level.display_name
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1) if is_unlocked else Color(0.5, 0.55, 0.6, 1))
	info.add_child(name_label)

	# 关卡描述
	var desc_label = Label.new()
	desc_label.text = level.description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7, 1) if is_unlocked else Color(0.35, 0.4, 0.45, 1))
	info.add_child(desc_label)

	# 难度和奖励
	var stats_hbox = HBoxContainer.new()
	stats_hbox.add_theme_constant_override("separation", 15)
	info.add_child(stats_hbox)

	var enemy_stat = Label.new()
	enemy_stat.text = "敌人: %d" % level.get_enemy_count()
	enemy_stat.add_theme_font_size_override("font_size", 12)
	enemy_stat.add_theme_color_override("font_color", Color(0.9, 0.5, 0.5, 1) if is_unlocked else Color(0.4, 0.4, 0.45, 1))
	stats_hbox.add_child(enemy_stat)

	# 敌人类型图标预览
	var enemy_icons = HBoxContainer.new()
	enemy_icons.add_theme_constant_override("separation", 2)
	stats_hbox.add_child(enemy_icons)

	# 收集敌人类型
	var enemy_types: Dictionary = {}
	for spawn in level.enemy_spawns:
		var unit_def = UnitDatabase.get_unit(spawn.unit_id)
		if unit_def:
			if not enemy_types.has(spawn.unit_id):
				enemy_types[spawn.unit_id] = {"count": 0, "def": unit_def}
			enemy_types[spawn.unit_id]["count"] += 1

	# 显示敌人图标（最多显示3种）
	var type_count = 0
	for unit_id in enemy_types.keys():
		if type_count >= 3:
			break
		var enemy_data = enemy_types[unit_id]
		var icon_label = Label.new()
		icon_label.text = _get_unit_class_icon(enemy_data["def"].class_type)
		icon_label.add_theme_font_size_override("font_size", 14)
		if not is_unlocked:
			icon_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45, 1))
		enemy_icons.add_child(icon_label)
		type_count += 1

	var reward_stat = Label.new()
	reward_stat.text = "奖励: %d 金币" % level.gold_reward
	reward_stat.add_theme_font_size_override("font_size", 12)
	reward_stat.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1) if is_unlocked else Color(0.4, 0.4, 0.45, 1))
	stats_hbox.add_child(reward_stat)

	# 右侧：状态
	var status_container = VBoxContainer.new()
	status_container.alignment = BoxContainer.ALIGNMENT_CENTER
	status_container.custom_minimum_size.x = 90
	container.add_child(status_container)

	var status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)

	if is_completed:
		status_label.text = "✓ 已完成"
		status_label.add_theme_color_override("font_color", Color(0.2, 0.85, 0.3, 1))
	elif is_unlocked:
		status_label.text = "▶ 开始"
		status_label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.9, 1))
	else:
		status_label.text = "🔒 锁定"
		status_label.add_theme_color_override("font_color", Color(0.4, 0.45, 0.5, 1))

	status_container.add_child(status_label)

	# 点击事件
	if is_unlocked:
		panel.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_level_selected(level.id)
		)
		panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	return panel


## 关卡选中
func _on_level_selected(level_id: String) -> void:
	selected_level_id = level_id
	GameManager.current_level_id = level_id
	SceneTransition.change_scene("res://scenes/battle/battle_setup.tscn")


## 返回按钮
func _on_back_pressed() -> void:
	SceneTransition.change_scene("res://scenes/main_menu.tscn")


## 商店按钮
func _on_shop_pressed() -> void:
	GameManager.enter_shop()
	SceneTransition.change_scene("res://scenes/shop/shop_scene.tscn")


## 获取单位职业图标
func _get_unit_class_icon(class_type: Global.ClassType) -> String:
	match class_type:
		Global.ClassType.WARRIOR:
			return "🗡"
		Global.ClassType.ARCHER:
			return "🏹"
		Global.ClassType.MAGE:
			return "🔮"
		Global.ClassType.KNIGHT:
			return "🛡"
		Global.ClassType.HEALER:
			return "💚"
	return "?"
