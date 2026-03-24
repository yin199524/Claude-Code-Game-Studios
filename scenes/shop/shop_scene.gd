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
	var label = $VBoxContainer/Header/GoldLabel
	label.text = "💰 %d" % SaveManager.get_gold()


## 更新拥有单位数量
func _update_owned_count() -> void:
	var label = $VBoxContainer/Footer/OwnedLabel
	label.text = "已拥有: %d 个单位" % SaveManager.get_unit_count()


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
	var container = HBoxContainer.new()
	container.custom_minimum_size.y = 100

	# 背景
	var bg = PanelContainer.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(bg)

	# 单位信息容器
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(info)

	# 单位名称和稀有度
	var name_row = HBoxContainer.new()
	info.add_child(name_row)

	var name_label = Label.new()
	name_label.text = unit.display_name
	name_label.add_theme_font_size_override("font_size", 18)
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
	class_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	info.add_child(class_label)

	# 属性预览
	var stats_label = Label.new()
	stats_label.text = "HP: %d | 攻击: %d | 范围: %d" % [
		unit.get_effective_hp(),
		unit.get_effective_attack(),
		unit.attack_range
	]
	stats_label.add_theme_font_size_override("font_size", 12)
	info.add_child(stats_label)

	# 价格和购买按钮
	var price_container = VBoxContainer.new()
	price_container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_child(price_container)

	var price_label = Label.new()
	price_label.text = "%d 金币" % unit.get_price()
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_container.add_child(price_label)

	var buy_button = Button.new()
	buy_button.text = "购买"
	buy_button.custom_minimum_size = Vector2(80, 40)

	# 检查是否买得起
	var can_afford = SaveManager.can_afford(unit.get_price())
	if not can_afford:
		buy_button.disabled = true
		buy_button.text = "金币不足"

	buy_button.pressed.connect(_on_buy_pressed.bind(unit.id, unit.get_price()))
	price_container.add_child(buy_button)

	return container


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
