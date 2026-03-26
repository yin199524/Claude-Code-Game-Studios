# synergy_hint.gd - 协同效果提示组件
# 显示详细的协同效果信息

extends Control

## 显示时长
const DISPLAY_DURATION: float = 3.5

## 动画时长
const ANIM_DURATION: float = 0.4

## 主面板
var _panel: PanelContainer = null

## 是否正在显示
var _is_showing: bool = false

## 计时器
var _display_timer: float = 0.0


func _ready() -> void:
	_setup_ui()
	hide()


func _setup_ui() -> void:
	# 设置锚点：顶部居中
	anchors_preset = Control.PRESET_CENTER_TOP
	offset_top = 120
	offset_left = -200
	offset_right = 200
	offset_bottom = 220

	# 主面板
	_panel = PanelContainer.new()
	_panel.anchors_preset = Control.PRESET_FULL_RECT
	add_child(_panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.18, 0.2, 0.95)
	style.border_color = Color(0.3, 0.8, 0.7, 1)
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 4)
	_panel.add_theme_stylebox_override("panel", style)

	# 内容容器
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_panel.add_child(vbox)

	# 顶部边距
	var top_padding = Control.new()
	top_padding.custom_minimum_size.y = 8
	vbox.add_child(top_padding)

	# 标题行
	var title_row = HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 10)
	vbox.add_child(title_row)

	# 图标
	var icon_label = Label.new()
	icon_label.name = "IconLabel"
	icon_label.text = "✨"
	icon_label.add_theme_font_size_override("font_size", 24)
	title_row.add_child(icon_label)

	# 标题
	var title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "协同触发！"
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color(0.5, 1, 0.8, 1))
	title_row.add_child(title_label)

	# 协同名称
	var name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color(1, 0.95, 0.9, 1))
	vbox.add_child(name_label)

	# 分隔线
	var separator = HSeparator.new()
	var sep_style = StyleBoxFlat.new()
	sep_style.bg_color = Color(0.3, 0.5, 0.45, 0.5)
	separator.add_theme_stylebox_override("separator", sep_style)
	vbox.add_child(separator)

	# 效果描述
	var desc_label = Label.new()
	desc_label.name = "DescLabel"
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.85, 0.8, 1))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size.x = 350
	vbox.add_child(desc_label)

	# 加成信息容器
	var bonus_container = HBoxContainer.new()
	bonus_container.name = "BonusContainer"
	bonus_container.alignment = BoxContainer.ALIGNMENT_CENTER
	bonus_container.add_theme_constant_override("separation", 15)
	vbox.add_child(bonus_container)

	# 底部边距
	var bottom_padding = Control.new()
	bottom_padding.custom_minimum_size.y = 10
	vbox.add_child(bottom_padding)


func _process(delta: float) -> void:
	if _is_showing:
		_display_timer -= delta
		if _display_timer <= 0:
			_hide_notification()


## 显示协同提示
func show_synergy(synergy_name: String, synergy_effect = null, affected_count: int = 0) -> void:
	_is_showing = true
	_display_timer = DISPLAY_DURATION

	# 更新内容
	_update_content(synergy_name, synergy_effect, affected_count)

	# 显示动画
	show()

	modulate.a = 0
	position.y = -50

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, ANIM_DURATION)
	tween.tween_property(self, "position:y", 0, ANIM_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# 播放音效
	SoundManager.play_sfx(SoundManager.SFX.PURCHASE_SUCCESS)


## 更新内容
func _update_content(synergy_name: String, synergy_effect, affected_count: int) -> void:
	var name_label = _panel.get_node("NameLabel") as Label
	if name_label:
		name_label.text = synergy_name

	var desc_label = _panel.get_node("DescLabel") as Label
	var bonus_container = _panel.get_node("BonusContainer") as HBoxContainer

	# 清空现有加成项
	if bonus_container:
		for child in bonus_container.get_children():
			child.queue_free()

	# 如果有协同效果数据，显示详细信息
	if synergy_effect:
		# 描述
		if desc_label:
			desc_label.text = synergy_effect.description

		# 加成信息
		if bonus_container:
			_add_bonus_display(bonus_container, synergy_effect, affected_count)
	else:
		# 默认描述
		if desc_label:
			desc_label.text = "单位间的默契配合，激发额外力量！"


## 添加加成显示
func _add_bonus_display(container: HBoxContainer, synergy_effect, affected_count: int) -> void:
	# 获取加成类型和值
	var bonus_type = synergy_effect.bonus_type
	var bonus_value = synergy_effect.bonus_value

	# 处理混合协同
	if synergy_effect.synergy_type == 2:  # SynergyType.MIXED
		# 混合协同显示多个加成
		match synergy_effect.id:
			"balance":
				_add_bonus_item(container, "战士", "HP +15%", Color(0.9, 0.4, 0.4))
				_add_bonus_item(container, "治疗", "治愈 +10%", Color(0.4, 0.9, 0.5))
			"magic_martial":
				_add_bonus_item(container, "法师", "伤害 +10%", Color(0.6, 0.4, 0.9))
				_add_bonus_item(container, "战士", "攻击 +10%", Color(0.9, 0.7, 0.3))
		return

	# 普通加成
	if bonus_value > 0:
		var bonus_text = _get_bonus_text(bonus_type, bonus_value)
		var bonus_color = _get_bonus_color(bonus_type)
		_add_bonus_item(container, "", bonus_text, bonus_color)

	# 显示影响单位数
	if affected_count > 0:
		var count_label = Label.new()
		count_label.text = "👥 %d 单位" % affected_count
		count_label.add_theme_font_size_override("font_size", 12)
		count_label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8, 1))
		container.add_child(count_label)


## 添加单个加成项
func _add_bonus_item(container: HBoxContainer, prefix: String, text: String, color: Color) -> void:
	var item = VBoxContainer.new()
	item.alignment = BoxContainer.ALIGNMENT_CENTER
	item.add_theme_constant_override("separation", 2)

	if prefix != "":
		var prefix_label = Label.new()
		prefix_label.text = prefix
		prefix_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prefix_label.add_theme_font_size_override("font_size", 11)
		prefix_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8, 1))
		item.add_child(prefix_label)

	var value_label = Label.new()
	value_label.text = text
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 14)
	value_label.add_theme_color_override("font_color", color)
	item.add_child(value_label)

	container.add_child(item)


## 获取加成文本
func _get_bonus_text(bonus_type: String, value: float) -> String:
	var type_names = {
		"attack": "攻击",
		"defense": "防御",
		"damage": "伤害",
		"heal": "治愈",
		"hp": "生命",
		"attack_speed": "攻速"
	}
	var type_name = type_names.get(bonus_type, bonus_type)
	return "%s +%.0f%%" % [type_name, value * 100]


## 获取加成颜色
func _get_bonus_color(bonus_type: String) -> Color:
	match bonus_type:
		"attack":
			return Color(1, 0.7, 0.3)
		"defense":
			return Color(0.5, 0.7, 1)
		"damage":
			return Color(1, 0.5, 0.5)
		"heal":
			return Color(0.4, 0.9, 0.5)
		"hp":
			return Color(0.9, 0.4, 0.4)
		"attack_speed":
			return Color(0.9, 0.9, 0.3)
	return Color(1, 1, 1)


## 隐藏提示
func _hide_notification() -> void:
	_is_showing = false

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, ANIM_DURATION * 0.5)
	tween.tween_property(self, "position:y", -30, ANIM_DURATION * 0.5)

	await tween.finished
	hide()
	queue_free()


## ==================== 静态方法 ====================

## 显示协同提示
static func show(parent: Node, synergy_name: String, synergy_effect = null, affected_count: int = 0) -> Control:
	var hint = preload("res://scenes/notification/synergy_hint.tscn").instantiate()
	parent.add_child(hint)
	hint.show_synergy(synergy_name, synergy_effect, affected_count)
	return hint
