# tutorial_hint.gd - 引导提示组件
# 显示引导消息和可选的高亮效果

extends Control

## 变量

## 消息标签
var message_label: Label

## 高亮遮罩
var highlight_overlay: ColorRect

## 高亮目标
var highlight_target: Control

## 是否显示中
var is_showing: bool = false

## 动画时长
const ANIM_DURATION: float = 0.3


func _ready() -> void:
	_setup_ui()

	# 连接 TutorialManager 信号
	TutorialManager.show_hint.connect(_on_show_hint)
	TutorialManager.hide_hint.connect(_on_hide_hint)

	# 初始隐藏
	visible = false


func _setup_ui() -> void:
	# 全屏遮罩
	var overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

	# 消息容器（底部居中）
	var message_container = PanelContainer.new()
	message_container.name = "MessageContainer"
	message_container.anchors_preset = Control.PRESET_CENTER_BOTTOM
	message_container.offset_left = -250
	message_container.offset_right = 250
	message_container.offset_top = -150
	message_container.offset_bottom = -30
	message_container.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.18, 0.22, 0.95)
	style.border_color = Color(0.5, 0.6, 0.75, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	message_container.add_theme_stylebox_override("panel", style)
	add_child(message_container)

	# 内部容器
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	message_container.add_child(vbox)

	# 消息文本
	message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	message_label.custom_minimum_size.x = 450
	vbox.add_child(message_label)

	# 按钮容器
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 20)
	vbox.add_child(button_container)

	# 下一步按钮
	var next_button = Button.new()
	next_button.text = "下一步"
	next_button.custom_minimum_size = Vector2(100, 40)
	next_button.pressed.connect(_on_next_pressed)
	_setup_button_style(next_button, Color(0.2, 0.45, 0.55, 1))
	button_container.add_child(next_button)

	# 跳过按钮
	var skip_button = Button.new()
	skip_button.text = "跳过"
	skip_button.custom_minimum_size = Vector2(80, 40)
	skip_button.pressed.connect(_on_skip_pressed)
	_setup_button_style(skip_button, Color(0.3, 0.3, 0.35, 1))
	button_container.add_child(skip_button)


func _setup_button_style(button: Button, bg_color: Color) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = bg_color.lightened(0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	button.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = bg_color.lightened(0.15)
	button.add_theme_stylebox_override("hover", hover_style)


func _on_show_hint(message: String, highlight_path: NodePath) -> void:
	show_hint(message, highlight_path)


func _on_hide_hint() -> void:
	hide_hint()


func show_hint(message: String, highlight_path: NodePath = NodePath("")) -> void:
	message_label.text = message
	is_showing = true
	visible = true

	# TODO: 实现高亮效果
	# 如果有高亮路径，创建高亮遮罩效果

	# 播放淡入动画
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, ANIM_DURATION)


func hide_hint() -> void:
	if not is_showing:
		return

	is_showing = false

	# 播放淡出动画
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, ANIM_DURATION)
	tween.tween_callback(func(): visible = false)


func _on_next_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	TutorialManager.advance_step()


func _on_skip_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	TutorialManager.skip_tutorial()


## 创建引导提示组件（静态方法）
static func create(parent: Node) -> Control:
	var hint = Control.new()
	hint.name = "TutorialHint"
	hint.anchors_preset = Control.PRESET_FULL_RECT
	hint.set_script(preload("res://scenes/tutorial/tutorial_hint.gd"))
	parent.add_child(hint)
	return hint
