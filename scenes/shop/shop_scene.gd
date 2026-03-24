# shop_scene.gd - 商店场景脚本
# 显示可购买单位，处理购买逻辑

extends Control

## 购买成功信号
signal purchase_success(unit_id: String)

## 购买失败信号
signal purchase_failed(reason: String)

## 悬停提示面板
var tooltip_panel: PanelContainer = null

## 当前显示提示的单位
var current_tooltip_unit: UnitDefinition = null


func _ready() -> void:
	_create_tooltip()
	_connect_signals()
	_update_gold_display()
	_update_owned_count()
	_populate_unit_list()


## 创建悬停提示面板
func _create_tooltip() -> void:
	tooltip_panel = PanelContainer.new()
	tooltip_panel.visible = false
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.z_index = 100

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.18, 0.95)
	style.border_color = Color(0.4, 0.5, 0.65, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 8
	style.shadow_offset = Vector2(3, 3)
	tooltip_panel.add_theme_stylebox_override("panel", style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	tooltip_panel.add_child(vbox)

	# 标题行
	var title_row = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	vbox.add_child(title_row)

	var name_label = Label.new()
	name_label.name = "UnitName"
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	title_row.add_child(name_label)

	var rarity_label = Label.new()
	rarity_label.name = "UnitRarity"
	rarity_label.add_theme_font_size_override("font_size", 12)
	title_row.add_child(rarity_label)

	# 分隔线
	var separator = HSeparator.new()
	separator.add_theme_stylebox_override("separator", StyleBoxEmpty.new())
	vbox.add_child(separator)

	# 属性容器
	var stats_vbox = VBoxContainer.new()
	stats_vbox.name = "StatsContainer"
	stats_vbox.add_theme_constant_override("separation", 4)
	vbox.add_child(stats_vbox)

	# 技能描述
	var skill_label = Label.new()
	skill_label.name = "SkillDesc"
	skill_label.add_theme_font_size_override("font_size", 12)
	skill_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8, 1))
	skill_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	skill_label.custom_minimum_size.x = 200
	vbox.add_child(skill_label)

	add_child(tooltip_panel)


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

	# 检查是否已拥有
	var is_owned = SaveManager.has_unit(unit.id)
	var unit_level = SaveManager.get_unit_level(unit.id) if is_owned else 0
	var is_max_level = unit_level >= Global.MAX_UNIT_LEVEL

	# 等级显示（仅已拥有单位）
	if is_owned:
		var level_label = Label.new()
		level_label.text = "Lv.%d%s" % [unit_level, " MAX" if is_max_level else ""]
		level_label.add_theme_font_size_override("font_size", 12)
		level_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1) if is_max_level else Color(0.7, 0.8, 0.9, 1))
		name_row.add_child(level_label)

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

	# 显示当前等级属性或基础属性
	var display_hp = unit.get_hp_at_level(maxi(unit_level, 1))
	var display_atk = unit.get_attack_at_level(maxi(unit_level, 1))

	var hp_stat = Label.new()
	hp_stat.text = "❤ %d" % display_hp
	hp_stat.add_theme_font_size_override("font_size", 12)
	hp_stat.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4, 1))
	stats_hbox.add_child(hp_stat)

	var atk_stat = Label.new()
	atk_stat.text = "⚔ %d" % display_atk
	atk_stat.add_theme_font_size_override("font_size", 12)
	atk_stat.add_theme_color_override("font_color", Color(0.9, 0.7, 0.3, 1))
	stats_hbox.add_child(atk_stat)

	var range_stat = Label.new()
	range_stat.text = "📍 %d" % unit.attack_range
	range_stat.add_theme_font_size_override("font_size", 12)
	range_stat.add_theme_color_override("font_color", Color(0.5, 0.7, 0.9, 1))
	stats_hbox.add_child(range_stat)

	# 右侧：价格和按钮
	var price_container = VBoxContainer.new()
	price_container.alignment = BoxContainer.ALIGNMENT_CENTER
	price_container.custom_minimum_size.x = 90
	container.add_child(price_container)

	if is_owned:
		# 已拥有单位：显示升级选项
		if is_max_level:
			# 已满级
			var max_label = Label.new()
			max_label.text = "已满级"
			max_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			max_label.add_theme_font_size_override("font_size", 14)
			max_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
			price_container.add_child(max_label)
		else:
			# 显示升级费用
			var upgrade_cost = unit.get_upgrade_cost(unit_level)
			var price_label = Label.new()
			price_label.text = "%d" % upgrade_cost
			price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			price_label.add_theme_font_size_override("font_size", 16)
			price_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
			price_container.add_child(price_label)

			var price_icon = Label.new()
			price_icon.text = "升级费用"
			price_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			price_icon.add_theme_font_size_override("font_size", 10)
			price_icon.add_theme_color_override("font_color", Color(0.7, 0.65, 0.5, 1))
			price_container.add_child(price_icon)

			var upgrade_button = Button.new()
			upgrade_button.text = "升级"
			upgrade_button.custom_minimum_size = Vector2(75, 32)

			# 检查是否买得起
			var can_afford = SaveManager.can_afford(upgrade_cost)
			if not can_afford:
				upgrade_button.disabled = true
				upgrade_button.text = "不足"

			upgrade_button.pressed.connect(_on_upgrade_pressed.bind(unit.id, upgrade_cost))
			price_container.add_child(upgrade_button)
	else:
		# 未拥有：显示购买选项
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

	# 添加悬停事件
	panel.mouse_entered.connect(_on_unit_hover_entered.bind(unit, panel))
	panel.mouse_exited.connect(_on_unit_hover_exited)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP

	return panel


## 单位悬停进入
func _on_unit_hover_entered(unit: UnitDefinition, panel: Control) -> void:
	current_tooltip_unit = unit
	_update_tooltip_content(unit)

	# 计算提示位置
	var panel_rect = panel.get_global_rect()
	var tooltip_pos = Vector2(panel_rect.position.x + panel_rect.size.x + 10, panel_rect.position.y)

	# 检查是否超出屏幕
	var screen_size = get_viewport().get_visible_rect().size
	if tooltip_pos.x + 220 > screen_size.x:
		tooltip_pos.x = panel_rect.position.x - 220

	tooltip_panel.position = tooltip_pos
	tooltip_panel.visible = true


## 单位悬停退出
func _on_unit_hover_exited() -> void:
	tooltip_panel.visible = false
	current_tooltip_unit = null


## 更新提示内容
func _update_tooltip_content(unit: UnitDefinition) -> void:
	if tooltip_panel == null:
		return

	# 更新名称和稀有度
	var name_label = tooltip_panel.get_node("VBoxContainer/UnitName") as Label
	var rarity_label = tooltip_panel.get_node("VBoxContainer/UnitRarity") as Label

	if name_label:
		name_label.text = unit.display_name
	if rarity_label:
		rarity_label.text = Global.get_rarity_name(unit.rarity)
		rarity_label.add_theme_color_override("font_color", _get_rarity_color(unit.rarity))

	# 更新属性
	var stats_container = tooltip_panel.get_node("VBoxContainer/StatsContainer") as VBoxContainer
	if stats_container:
		# 清空现有属性
		for child in stats_container.get_children():
			child.queue_free()

		# 检查是否已拥有
		var is_owned = SaveManager.has_unit(unit.id)
		var unit_level = SaveManager.get_unit_level(unit.id) if is_owned else 1

		# 添加详细属性（显示当前等级）
		_add_stat_row(stats_container, "职业", Global.get_class_name(unit.class_type), Color(0.6, 0.65, 0.7, 1))
		_add_stat_row(stats_container, "等级", "Lv.%d" % unit_level, Color(1, 0.85, 0.2, 1) if is_owned else Color(0.7, 0.7, 0.7, 1))
		_add_stat_row(stats_container, "生命值", "%d" % unit.get_hp_at_level(unit_level), Color(0.9, 0.4, 0.4, 1))
		_add_stat_row(stats_container, "攻击力", "%d" % unit.get_attack_at_level(unit_level), Color(0.9, 0.7, 0.3, 1))
		_add_stat_row(stats_container, "攻击速度", "%.1f" % unit.attack_speed, Color(0.5, 0.8, 0.5, 1))
		_add_stat_row(stats_container, "攻击范围", "%d 格" % unit.attack_range, Color(0.5, 0.7, 0.9, 1))
		_add_stat_row(stats_container, "护甲", "%d" % unit.get_armor_at_level(unit_level), Color(0.7, 0.7, 0.8, 1))

		# 如果已拥有且未满级，显示升级预览
		if is_owned and unit_level < Global.MAX_UNIT_LEVEL:
			var preview = unit.get_upgrade_preview(unit_level)
			_add_stat_row(stats_container, "", "", Color(0.5, 0.5, 0.5, 1))  # 空行
			_add_stat_row(stats_container, "升级后", "Lv.%d" % (unit_level + 1), Color(0.3, 0.9, 0.5, 1))
			_add_stat_row(stats_container, "生命值", "%d (+%d)" % [preview.hp, preview.hp - unit.get_hp_at_level(unit_level)], Color(0.5, 0.9, 0.5, 1))
			_add_stat_row(stats_container, "攻击力", "%d (+%d)" % [preview.attack, preview.attack - unit.get_attack_at_level(unit_level)], Color(0.5, 0.9, 0.5, 1))
			_add_stat_row(stats_container, "护甲", "%d (+%d)" % [preview.armor, preview.armor - unit.get_armor_at_level(unit_level)], Color(0.5, 0.9, 0.5, 1))
		elif is_owned and unit_level >= Global.MAX_UNIT_LEVEL:
			_add_stat_row(stats_container, "", "", Color(0.5, 0.5, 0.5, 1))  # 空行
			_add_stat_row(stats_container, "状态", "已达到最高等级", Color(1, 0.85, 0.2, 1))

	# 更新技能描述
	var skill_label = tooltip_panel.get_node("VBoxContainer/SkillDesc") as Label
	if skill_label:
		skill_label.text = unit.description if unit.description.length() > 0 else "无特殊技能"


## 添加属性行
func _add_stat_row(container: VBoxContainer, stat_name: String, value: String, color: Color) -> void:
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var name_label = Label.new()
	name_label.text = stat_name
	name_label.custom_minimum_size.x = 70
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7, 1))
	row.add_child(name_label)

	var value_label = Label.new()
	value_label.text = value
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.add_theme_font_size_override("font_size", 12)
	value_label.add_theme_color_override("font_color", color)
	row.add_child(value_label)

	container.add_child(row)


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
		SoundManager.play_sfx(SoundManager.SFX.PURCHASE_FAIL)
		purchase_failed.emit("金币不足")
		return

	# 扣除金币
	var success = SaveManager.spend_gold(price)
	if not success:
		SoundManager.play_sfx(SoundManager.SFX.PURCHASE_FAIL)
		purchase_failed.emit("购买失败")
		return

	# 播放购买成功音效
	SoundManager.play_sfx(SoundManager.SFX.PURCHASE_SUCCESS)

	# 显示金币飘字
	var gold_display = $VBoxContainer/Header/GoldDisplay
	var gold_pos = gold_display.get_global_rect().position + Vector2(30, 10)
	SceneTransition.show_gold_floating_text(self, -price, gold_pos)

	# 添加单位
	SaveManager.add_unit(unit_id, 1)

	# 刷新显示
	_update_gold_display()
	_update_owned_count()
	_populate_unit_list()

	purchase_success.emit(unit_id)
	print("购买成功: %s" % unit_id)


## 升级按钮按下
func _on_upgrade_pressed(unit_id: String, cost: int) -> void:
	# 执行升级
	var result = SaveManager.try_upgrade_unit(unit_id, cost)

	if not result[0]:
		SoundManager.play_sfx(SoundManager.SFX.PURCHASE_FAIL)
		purchase_failed.emit(result[1])
		return

	# 播放升级成功音效
	SoundManager.play_sfx(SoundManager.SFX.PURCHASE_SUCCESS)

	# 显示金币飘字
	var gold_display = $VBoxContainer/Header/GoldDisplay
	var gold_pos = gold_display.get_global_rect().position + Vector2(30, 10)
	SceneTransition.show_gold_floating_text(self, -cost, gold_pos)

	# 显示升级特效
	_show_upgrade_effect(unit_id)

	# 刷新显示
	_update_gold_display()
	_populate_unit_list()

	print("升级成功: %s" % unit_id)


## 显示升级特效
func _show_upgrade_effect(unit_id: String) -> void:
	# 创建升级闪光效果
	var flash = ColorRect.new()
	flash.color = Color(1, 0.9, 0.3, 0.5)
	flash.size = Vector2(400, 100)
	flash.position = Vector2(160, 400)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)

	# 淡出动画
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.5)
	tween.tween_callback(flash.queue_free)

	# 升级粒子效果
	var particle_pos = Vector2(360, 450)
	ParticleEffects.create_upgrade_particles(self, particle_pos)


## 返回按钮
func _on_back_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	GameManager.enter_level_select()
	SceneTransition.change_scene("res://scenes/level/level_select.tscn")
