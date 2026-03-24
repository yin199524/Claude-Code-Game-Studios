# shop_scene.gd - 商店场景脚本
# 显示可购买单位，处理购买逻辑

extends Control

## 购买成功信号
signal purchase_success(unit_id: String)

## 购买失败信号
signal purchase_failed(reason: String)


func _ready() -> void:
	_connect_signals()
	_update_gold_display()
	_update_owned_count()
	_populate_unit_list()


func _connect_signals() -> void:
	$VBoxContainer/Header/BackButton.pressed.connect(_on_back_pressed)


## 更新金币显示
func _update_gold_display() -> void:
	var label = $VBoxContainer/Header/GoldDisplay/GoldLabel
	label.text = "%d" % SaveManager.get_gold()


## 更新拥有单位数量
func _update_owned_count() -> void:
	var label = $VBoxContainer/Footer/OwnedLabel
	label.text = "📦 已拥有: %d 个单位" % SaveManager.get_unit_count()


## 填充单位列表
func _populate_unit_list() -> void:
	var list = $VBoxContainer/ScrollContainer/UnitList

	# 清空现有项目
	for child in list.get_children():
		child.queue_free()

	await get_tree().process_frame

	# 获取所有可购买单位
	var units = UnitDatabase.get_all_units()

	for unit in units:
		var item = _create_unit_item(unit)
		list.add_child(item)


## 创建单位购买项
func _create_unit_item(unit: UnitDefinition) -> Control:
	# 外层面板
	var panel = PanelContainer.new()
	panel.custom_minimum_size.y = 110

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.18, 0.25, 1)
	style.border_color = _get_rarity_color(unit.rarity)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)
	panel.add_theme_stylebox_override("panel", style)

	# 内层容器
	var container = HBoxContainer.new()
	panel.add_child(container)

	# 左侧：职业图标
	var icon_panel = PanelContainer.new()
	icon_panel.custom_minimum_size.x = 60
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = _get_class_color(unit.class_type)
	icon_style.set_corner_radius_all(8)
	icon_panel.add_theme_stylebox_override("panel", icon_style)
	container.add_child(icon_panel)

	var class_icon = Label.new()
	class_icon.text = _get_class_icon(unit.class_type)
	class_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	class_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	class_icon.add_theme_font_size_override("font_size", 28)
	icon_panel.add_child(class_icon)

	# 中间：单位信息
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	container.add_child(info)

	# 名称和稀有度
	var name_row = HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 8)
	info.add_child(name_row)

	var name_label = Label.new()
	name_label.text = unit.display_name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	name_row.add_child(name_label)

	var rarity_label = Label.new()
	rarity_label.text = Global.get_rarity_name(unit.rarity)
	rarity_label.add_theme_font_size_override("font_size", 12)
	rarity_label.add_theme_color_override("font_color", _get_rarity_color(unit.rarity))
	name_row.add_child(rarity_label)

	# 职业类型
	var class_label = Label.new()
	class_label.text = Global.get_class_name(unit.class_type)
	class_label.add_theme_font_size_override("font_size", 12)
	class_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7, 1))
	info.add_child(class_label)

	# 属性预览
	var stats_hbox = HBoxContainer.new()
	stats_hbox.add_theme_constant_override("separation", 15)
	info.add_child(stats_hbox)

	var hp_stat = Label.new()
	hp_stat.text = "❤ %d" % unit.get_effective_hp()
	hp_stat.add_theme_font_size_override("font_size", 12)
	hp_stat.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4, 1))
	stats_hbox.add_child(hp_stat)

	var atk_stat = Label.new()
	atk_stat.text = "⚔ %d" % unit.get_effective_attack()
	atk_stat.add_theme_font_size_override("font_size", 12)
	atk_stat.add_theme_color_override("font_color", Color(0.9, 0.7, 0.3, 1))
	stats_hbox.add_child(atk_stat)

	var range_stat = Label.new()
	range_stat.text = "📍 %d" % unit.attack_range
	range_stat.add_theme_font_size_override("font_size", 12)
	range_stat.add_theme_color_override("font_color", Color(0.5, 0.7, 0.9, 1))
	stats_hbox.add_child(range_stat)

	# 右侧：价格和购买按钮
	var price_container = VBoxContainer.new()
	price_container.alignment = BoxContainer.ALIGNMENT_CENTER
	price_container.custom_minimum_size.x = 90
	container.add_child(price_container)

	var price_label = Label.new()
	price_label.text = "%d" % unit.get_price()
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_font_size_override("font_size", 18)
	price_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	price_container.add_child(price_label)

	var price_icon = Label.new()
	price_icon.text = "金币"
	price_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_icon.add_theme_font_size_override("font_size", 10)
	price_icon.add_theme_color_override("font_color", Color(0.7, 0.65, 0.5, 1))
	price_container.add_child(price_icon)

	var buy_button = Button.new()
	buy_button.text = "购买"
	buy_button.custom_minimum_size = Vector2(75, 32)

	# 检查是否买得起
	var can_afford = SaveManager.can_afford(unit.get_price())
	if not can_afford:
		buy_button.disabled = true
		buy_button.text = "不足"

	buy_button.pressed.connect(_on_buy_pressed.bind(unit.id, unit.get_price()))
	price_container.add_child(buy_button)

	return panel


## 获取职业图标
func _get_class_icon(class_type: Global.ClassType) -> String:
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


## 获取职业颜色
func _get_class_color(class_type: Global.ClassType) -> Color:
	match class_type:
		Global.ClassType.WARRIOR:
			return Color(0.2, 0.5, 0.2, 1)
		Global.ClassType.ARCHER:
			return Color(0.2, 0.35, 0.6, 1)
		Global.ClassType.MAGE:
			return Color(0.5, 0.2, 0.6, 1)
		Global.ClassType.KNIGHT:
			return Color(0.6, 0.5, 0.2, 1)
		Global.ClassType.HEALER:
			return Color(0.2, 0.6, 0.6, 1)
	return Color(0.3, 0.3, 0.3, 1)


## 获取稀有度颜色
func _get_rarity_color(rarity: Global.Rarity) -> Color:
	match rarity:
		Global.Rarity.COMMON:
			return Color(0.7, 0.7, 0.7)
		Global.Rarity.RARE:
			return Color(0.2, 0.5, 1.0)
		Global.Rarity.EPIC:
			return Color(0.7, 0.2, 0.9)
		Global.Rarity.LEGENDARY:
			return Color(1.0, 0.7, 0.0)
	return Color(0.7, 0.7, 0.7)


## 购买按钮按下
func _on_buy_pressed(unit_id: String, price: int) -> void:
	# 再次检查余额
	if not SaveManager.can_afford(price):
		purchase_failed.emit("金币不足")
		return

	# 扣除金币
	var success = SaveManager.spend_gold(price)
	if not success:
		purchase_failed.emit("购买失败")
		return

	# 添加单位
	SaveManager.add_unit(unit_id, 1)

	# 刷新显示
	_update_gold_display()
	_update_owned_count()
	_populate_unit_list()

	purchase_success.emit(unit_id)
	print("购买成功: %s" % unit_id)


## 返回按钮
func _on_back_pressed() -> void:
	GameManager.enter_level_select()
	get_tree().change_scene_to_file("res://scenes/level/level_select.tscn")
