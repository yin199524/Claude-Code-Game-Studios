# level_select.gd - 关卡选择场景脚本
# 显示关卡列表，处理关卡选择和解锁状态

extends Control

## 关卡按钮场景（动态创建）
var level_button_scene: PackedScene = null

## 当前选中的关卡
var selected_level_id: String = ""

## 预览弹窗
var preview_panel: Control = null


func _ready() -> void:
	_connect_signals()
	_update_gold_display()
	_create_preview_panel()
	_populate_level_list()


func _connect_signals() -> void:
	$VBoxContainer/Header/BackButton.pressed.connect(_on_back_pressed)
	$VBoxContainer/Footer/ShopButton.pressed.connect(_on_shop_pressed)


## 更新金币显示
func _update_gold_display() -> void:
	var label = $VBoxContainer/Header/GoldDisplay/GoldLabel
	label.text = "%d" % SaveManager.get_gold()


## 创建预览弹窗（初始隐藏）
func _create_preview_panel() -> void:
	preview_panel = Control.new()
	preview_panel.name = "LevelPreviewPanel"
	preview_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	preview_panel.z_index = 50
	preview_panel.visible = false
	add_child(preview_panel)

	# 半透明背景
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview_panel.add_child(bg)

	# 点击背景关闭
	bg.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			hide_preview()
	)

	# 弹窗容器
	var popup = PanelContainer.new()
	popup.name = "PopupContainer"
	popup.set_anchors_preset(Control.PRESET_CENTER)
	popup.custom_minimum_size = Vector2(500, 400)
	popup.position = Vector2(110, 440)  # 屏幕中心偏上

	var popup_style = StyleBoxFlat.new()
	popup_style.bg_color = Color(0.12, 0.15, 0.22, 0.98)
	popup_style.border_color = Color(0.4, 0.5, 0.7, 1)
	popup_style.set_border_width_all(3)
	popup_style.set_corner_radius_all(15)
	popup_style.shadow_color = Color(0, 0, 0, 0.5)
	popup_style.shadow_size = 10
	popup.add_theme_stylebox_override("panel", popup_style)
	preview_panel.add_child(popup)

	# 内容容器
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	popup.add_child(vbox)

	# 标题区域
	var title_hbox = HBoxContainer.new()
	vbox.add_child(title_hbox)

	var icon_label = Label.new()
	icon_label.name = "IconLabel"
	icon_label.text = "⚔"
	icon_label.add_theme_font_size_override("font_size", 28)
	title_hbox.add_child(icon_label)

	var title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "关卡预览"
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1))
	title_hbox.add_child(title_label)

	# 分隔线
	var sep = HSeparator.new()
	sep.add_theme_stylebox_override("separator", StyleBoxFlat.new())
	var sep_style = sep.get_theme_stylebox("separator") as StyleBoxFlat
	sep_style.color = Color(0.3, 0.35, 0.45, 1)
	vbox.add_child(sep)

	# 关卡信息区域
	var info_vbox = VBoxContainer.new()
	info_vbox.name = "InfoContainer"
	info_vbox.add_theme_constant_override("separation", 8)
	vbox.add_child(info_vbox)

	# 敌人列表区域
	var enemy_section = VBoxContainer.new()
	enemy_section.name = "EnemySection"
	enemy_section.add_theme_constant_override("separation", 6)
	vbox.add_child(enemy_section)

	# 克制提示区域
	var counter_section = VBoxContainer.new()
	counter_section.name = "CounterSection"
	counter_section.add_theme_constant_override("separation", 4)
	vbox.add_child(counter_section)

	# 奖励区域
	var reward_hbox = HBoxContainer.new()
	reward_hbox.name = "RewardContainer"
	vbox.add_child(reward_hbox)

	# 按钮区域
	var btn_hbox = HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_hbox)

	var cancel_btn = Button.new()
	cancel_btn.text = "返回"
	cancel_btn.custom_minimum_size = Vector2(100, 40)
	cancel_btn.pressed.connect(hide_preview)
	btn_hbox.add_child(cancel_btn)

	var start_btn = Button.new()
	start_btn.name = "StartButton"
	start_btn.text = "开始战斗"
	start_btn.custom_minimum_size = Vector2(140, 40)
	start_btn.pressed.connect(_on_start_battle_pressed)
	btn_hbox.add_child(start_btn)


## 显示关卡预览
func show_preview(level: LevelDefinition) -> void:
	selected_level_id = level.id

	var popup = preview_panel.get_node("PopupContainer")
	var info_container = popup.get_node("InfoContainer")
	var enemy_section = popup.get_node("EnemySection")
	var counter_section = popup.get_node("CounterSection")
	var reward_container = popup.get_node("RewardContainer")

	# 清空旧内容
	for child in info_container.get_children():
		child.queue_free()
	for child in enemy_section.get_children():
		child.queue_free()
	for child in counter_section.get_children():
		child.queue_free()
	for child in reward_container.get_children():
		child.queue_free()

	await get_tree().process_frame

	# 标题
	var title_label = popup.get_node("TitleLabel")
	title_label.text = level.display_name

	# 关卡信息
	var desc_label = Label.new()
	desc_label.text = level.description
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8, 1))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_container.add_child(desc_label)

	var stats_label = Label.new()
	stats_label.text = "难度: %d  |  单位上限: %d" % [level.difficulty, level.player_unit_limit]
	stats_label.add_theme_font_size_override("font_size", 12)
	stats_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7, 1))
	info_container.add_child(stats_label)

	# 敌人列表标题
	var enemy_title = Label.new()
	enemy_title.text = "—— 敌人阵容 ——"
	enemy_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_title.add_theme_font_size_override("font_size", 14)
	enemy_title.add_theme_color_override("font_color", Color(0.9, 0.5, 0.5, 1))
	enemy_section.add_child(enemy_title)

	# 收集敌人信息
	var enemy_types: Dictionary = {}
	for spawn in level.enemy_spawns:
		var unit_def = UnitDatabase.get_unit(spawn.unit_id)
		if unit_def:
			if not enemy_types.has(spawn.unit_id):
				enemy_types[spawn.unit_id] = {"count": 0, "def": unit_def}
			enemy_types[spawn.unit_id]["count"] += 1

	# 敌人列表
	var enemy_list = HBoxContainer.new()
	enemy_list.alignment = BoxContainer.ALIGNMENT_CENTER
	enemy_list.add_theme_constant_override("separation", 15)
	enemy_section.add_child(enemy_list)

	# 克制推荐收集
	var counter_recommendations: Array[String] = []

	for unit_id in enemy_types.keys():
		var enemy_data = enemy_types[unit_id]
		var enemy_vbox = VBoxContainer.new()
		enemy_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		enemy_list.add_child(enemy_vbox)

		# 敌人图标
		var icon = Label.new()
		icon.text = _get_unit_class_icon(enemy_data["def"].class_type)
		icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.add_theme_font_size_override("font_size", 28)
		enemy_vbox.add_child(icon)

		# 敌人名称和数量
		var name_label = Label.new()
		name_label.text = "%s ×%d" % [enemy_data["def"].display_name, enemy_data["count"]]
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1))
		enemy_vbox.add_child(name_label)

		# 克制提示
		var counter_text = _get_counter_recommendation(enemy_data["def"].class_type)
		if not counter_text.is_empty():
			counter_recommendations.append(counter_text)

	# 克制提示区域
	var counter_title = Label.new()
	counter_title.text = "—— 克制提示 ——"
	counter_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	counter_title.add_theme_font_size_override("font_size", 14)
	counter_title.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0, 1))
	counter_section.add_child(counter_title)

	if counter_recommendations.is_empty():
		var no_hint = Label.new()
		no_hint.text = "无特殊克制要求"
		no_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_hint.add_theme_font_size_override("font_size", 12)
		no_hint.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6, 1))
		counter_section.add_child(no_hint)
	else:
		for hint in counter_recommendations:
			var hint_label = Label.new()
			hint_label.text = hint
			hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hint_label.add_theme_font_size_override("font_size", 12)
			hint_label.add_theme_color_override("font_color", Color(0.6, 0.85, 0.6, 1))
			counter_section.add_child(hint_label)

	# 奖励区域
	var reward_icon = Label.new()
	reward_icon.text = "💰"
	reward_icon.add_theme_font_size_override("font_size", 20)
	reward_container.add_child(reward_icon)

	var reward_label = Label.new()
	reward_label.text = "通关奖励: %d 金币" % level.gold_reward
	reward_label.add_theme_font_size_override("font_size", 16)
	reward_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	reward_container.add_child(reward_label)

	# 显示弹窗
	preview_panel.visible = true
	SceneTransition.popup_animation(popup)


## 隐藏预览
func hide_preview() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	preview_panel.visible = false


## 获取克制推荐文本
func _get_counter_recommendation(enemy_class: Global.ClassType) -> String:
	# 查找克制该职业的单位
	match enemy_class:
		Global.ClassType.WARRIOR:
			return "弓手克制战士 (伤害 +30%)"
		Global.ClassType.ARCHER:
			return ""  # 无克制弓手的单位
		Global.ClassType.MAGE:
			return "弓手克制法师 (伤害 +30%)"
		Global.ClassType.KNIGHT:
			return "战士/法师克制骑士 (伤害 +30%)"
		Global.ClassType.HEALER:
			return "弓手/骑士克制治疗 (伤害 +30%)"
	return ""


## 开始战斗按钮
func _on_start_battle_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	GameManager.current_level_id = selected_level_id
	SceneTransition.change_scene("res://scenes/battle/battle_setup.tscn")


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
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	var level = LevelDatabase.get_level(level_id)
	if level:
		show_preview(level)


## 返回按钮
func _on_back_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	SceneTransition.change_scene("res://scenes/main_menu.tscn")


## 商店按钮
func _on_shop_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
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
