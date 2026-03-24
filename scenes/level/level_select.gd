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
	var label = $VBoxContainer/Header/GoldLabel
	label.text = "💰 %d" % SaveManager.get_gold()


## 填充关卡列表
func _populate_level_list() -> void:
	var list = $VBoxContainer/LevelList

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
	var container = HBoxContainer.new()
	container.custom_minimum_size.y = 80

	# 背景
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0.25, 1)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(bg)

	# 关卡信息容器
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(info)

	# 关卡名称
	var name_label = Label.new()
	name_label.text = level.display_name
	name_label.add_theme_font_size_override("font_size", 18)
	info.add_child(name_label)

	# 关卡描述
	var desc_label = Label.new()
	desc_label.text = level.description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info.add_child(desc_label)

	# 难度和奖励
	var stats_label = Label.new()
	stats_label.text = "难度: %d | 敌人: %d | 奖励: %d 金币" % [
		level.difficulty,
		level.get_enemy_count(),
		level.gold_reward
	]
	stats_label.add_theme_font_size_override("font_size", 12)
	info.add_child(stats_label)

	# 状态标签
	var status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.custom_minimum_size.x = 80

	var is_unlocked = LevelDatabase.is_level_unlocked(level.id)
	var is_completed = LevelDatabase.is_level_completed(level.id)

	if is_completed:
		status_label.text = "✅ 完成"
		status_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	elif is_unlocked:
		status_label.text = "▶ 开始"
		status_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.2))
	else:
		status_label.text = "🔒 锁定"
		status_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

	container.add_child(status_label)

	# 点击事件
	if is_unlocked:
		container.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_on_level_selected(level.id)
		)

	return container


## 关卡选中
func _on_level_selected(level_id: String) -> void:
	selected_level_id = level_id
	GameManager.current_level_id = level_id
	get_tree().change_scene_to_file("res://scenes/battle/battle_setup.tscn")


## 返回按钮
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


## 商店按钮
func _on_shop_pressed() -> void:
	GameManager.enter_shop()
	get_tree().change_scene_to_file("res://scenes/shop/shop_scene.tscn")
