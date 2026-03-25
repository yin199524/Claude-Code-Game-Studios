# quick_hint.gd - 快速提示组件
# 显示短暂的非阻塞提示（克制、协同等）

extends Control

## 变量

## 提示标签
var hint_label: Label

## 当前显示的提示
var current_tween: Tween = null

## 默认显示时长
const DEFAULT_DURATION: float = 2.5


func _ready() -> void:
	_setup_ui()


func _setup_ui() -> void:
	# 提示标签（屏幕中央偏上）
	hint_label = Label.new()
	hint_label.name = "HintLabel"
	hint_label.anchors_preset = Control.PRESET_CENTER_TOP
	hint_label.offset_left = -300
	hint_label.offset_right = 300
	hint_label.offset_top = 200
	hint_label.offset_bottom = 280
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 22)
	hint_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	hint_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	hint_label.add_theme_constant_override("outline_size", 3)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	hint_label.visible = false
	add_child(hint_label)


## 显示提示
func show_hint(message: String, color: Color = Color.WHITE, duration: float = DEFAULT_DURATION) -> void:
	# 取消之前的动画
	if current_tween != null and current_tween.is_valid():
		current_tween.kill()

	hint_label.text = message
	hint_label.add_theme_color_override("font_color", color)
	hint_label.modulate.a = 0.0
	hint_label.visible = true

	# 创建动画
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_OUT)

	# 淡入
	current_tween.tween_property(hint_label, "modulate:a", 1.0, 0.3)

	# 停留
	current_tween.tween_interval(duration - 0.6)

	# 淡出
	current_tween.tween_property(hint_label, "modulate:a", 0.0, 0.3)

	# 隐藏
	current_tween.tween_callback(func(): hint_label.visible = false)


## 显示克制提示
func show_counter_hint() -> void:
	show_hint("⚔️ 克制！伤害 +50%", Color(1, 0.85, 0.2), 2.0)


## 显示协同提示
func show_synergy_hint(synergy_name: String) -> void:
	show_hint("✨ 协同触发！%s" % synergy_name, Color(0.5, 1, 0.8), 2.5)


## 创建快速提示组件（静态方法）
static func create(parent: Node) -> Control:
	var hint = Control.new()
	hint.name = "QuickHint"
	hint.anchors_preset = Control.PRESET_FULL_RECT
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint.set_script(preload("res://scenes/tutorial/quick_hint.gd"))
	parent.add_child(hint)
	return hint
