# welcome_screen.gd - 欢迎界面
# 首次进入游戏时显示的引导界面

extends Control

## 信号

## 欢迎完成（开始游戏或跳过）
signal welcome_completed()

## 变量

## 当前步骤索引
var current_step: int = 0

## 步骤内容
var steps: Array[Dictionary] = [
	{
		"title": "欢迎来到禅意军团",
		"message": "你将成为一位指挥官，\n带领你的部队征服五大世界！",
		"show_next": true,
	},
	{
		"title": "你的目标",
		"message": "组建强大的队伍，\n击败敌人，征服所有世界！",
		"show_next": true,
	},
	{
		"title": "准备好了吗？",
		"message": "让我们开始你的冒险之旅！",
		"show_next": false,
	},
]

## UI 节点引用
var title_label: Label
var message_label: Label
var next_button: Button
var skip_button: Button
var start_button: Button
var step_indicator: HBoxContainer


func _ready() -> void:
	_setup_ui()
	_show_step(0)

	# 连接 TutorialManager 信号
	TutorialManager.show_hint.connect(_on_show_hint)
	TutorialManager.hide_hint.connect(_on_hide_hint)


func _setup_ui() -> void:
	# 全屏背景遮罩
	var overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0, 0, 0, 0.85)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	add_child(overlay)

	# 主容器
	var main_container = VBoxContainer.new()
	main_container.name = "MainContainer"
	main_container.anchors_preset = Control.PRESET_CENTER
	main_container.offset_left = -280
	main_container.offset_right = 280
	main_container.offset_top = -200
	main_container.offset_bottom = 200
	main_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(main_container)

	# 游戏标题/步骤标题
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1))
	title_label.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.15, 1))
	title_label.add_theme_constant_override("outline_size", 3)
	main_container.add_child(title_label)

	# 间隔
	var spacer1 = Control.new()
	spacer1.custom_minimum_size.y = 30
	main_container.add_child(spacer1)

	# 消息内容
	message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 20)
	message_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1))
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	message_label.custom_minimum_size.x = 500
	main_container.add_child(message_label)

	# 间隔
	var spacer2 = Control.new()
	spacer2.custom_minimum_size.y = 40
	main_container.add_child(spacer2)

	# 步骤指示器
	step_indicator = HBoxContainer.new()
	step_indicator.name = "StepIndicator"
	step_indicator.alignment = BoxContainer.ALIGNMENT_CENTER
	step_indicator.add_theme_constant_override("separation", 10)
	main_container.add_child(step_indicator)

	# 创建步骤点
	for i in range(steps.size()):
		var dot = _create_step_dot(i)
		step_indicator.add_child(dot)

	# 间隔
	var spacer3 = Control.new()
	spacer3.custom_minimum_size.y = 40
	main_container.add_child(spacer3)

	# 按钮容器
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 20)
	main_container.add_child(button_container)

	# 跳过按钮
	skip_button = Button.new()
	skip_button.name = "SkipButton"
	skip_button.text = "跳过"
	skip_button.custom_minimum_size = Vector2(100, 45)
	_setup_button_style(skip_button, Color(0.25, 0.28, 0.35, 1))
	skip_button.pressed.connect(_on_skip_pressed)
	button_container.add_child(skip_button)

	# 下一步按钮
	next_button = Button.new()
	next_button.name = "NextButton"
	next_button.text = "下一步"
	next_button.custom_minimum_size = Vector2(120, 45)
	_setup_button_style(next_button, Color(0.2, 0.35, 0.5, 1))
	next_button.pressed.connect(_on_next_pressed)
	button_container.add_child(next_button)

	# 开始按钮（最后一步显示）
	start_button = Button.new()
	start_button.name = "StartButton"
	start_button.text = "开始冒险"
	start_button.custom_minimum_size = Vector2(150, 50)
	_setup_button_style(start_button, Color(0.2, 0.5, 0.4, 1))
	start_button.pressed.connect(_on_start_pressed)
	start_button.visible = false
	button_container.add_child(start_button)


func _create_step_dot(index: int) -> Control:
	var dot = Control.new()
	dot.name = "Dot%d" % index
	dot.custom_minimum_size = Vector2(12, 12)

	var circle = ReferenceRect.new()
	circle.anchors_preset = Control.PRESET_FULL_RECT
	circle.editor_only = false
	circle.border_color = Color(0.4, 0.45, 0.5, 1)
	circle.border_width = 2
	dot.add_child(circle)

	return dot


func _setup_button_style(button: Button, bg_color: Color) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = bg_color.lightened(0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	button.add_theme_stylebox_override("normal", style)

	var hover_style = style.duplicate()
	hover_style.bg_color = bg_color.lightened(0.15)
	hover_style.border_color = bg_color.lightened(0.3)
	button.add_theme_stylebox_override("hover", hover_style)


func _show_step(index: int) -> void:
	if index < 0 or index >= steps.size():
		return

	current_step = index
	var step_data = steps[index]

	title_label.text = step_data.get("title", "")
	message_label.text = step_data.get("message", "")

	# 更新按钮可见性
	var is_last = index == steps.size() - 1
	next_button.visible = not is_last
	start_button.visible = is_last

	# 更新步骤指示器
	_update_step_indicator()

	# 更新 TutorialManager 进度
	if TutorialManager.is_active:
		TutorialManager.advance_step()


func _update_step_indicator() -> void:
	for i in range(step_indicator.get_child_count()):
		var dot = step_indicator.get_child(i)
		var circle = dot.get_child(0) as ReferenceRect
		if circle:
			if i == current_step:
				circle.border_color = Color(0.9, 0.85, 0.7, 1)
				circle.border_width = 3
			elif i < current_step:
				circle.border_color = Color(0.6, 0.7, 0.8, 1)
				circle.border_width = 2
			else:
				circle.border_color = Color(0.35, 0.4, 0.45, 1)
				circle.border_width = 2


func _on_next_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	if current_step < steps.size() - 1:
		_show_step(current_step + 1)


func _on_skip_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	TutorialManager.skip_tutorial()
	_complete_welcome()


func _on_start_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	TutorialManager.complete_tutorial()
	_complete_welcome()


func _complete_welcome() -> void:
	welcome_completed.emit()
	queue_free()


func _on_show_hint(message: String, highlight_path: NodePath) -> void:
	# 欢迎界面自己管理显示，忽略外部提示
	pass


func _on_hide_hint() -> void:
	# 忽略
	pass


## 显示欢迎界面（静态方法）
static func show(parent: Node) -> Control:
	var screen = preload("res://scenes/tutorial/welcome_screen.tscn").instantiate()
	parent.add_child(screen)
	return screen
