# battle_tutorial.gd - 战斗教程组件
# 在战斗布局和战斗场景中显示引导提示

extends Control

## 信号

## 教程完成
signal tutorial_completed()

## 变量

## 教程阶段
enum Phase {
	NONE,
	UNIT_SELECT,      ## 选择单位
	UNIT_PLACE,       ## 放置单位
	START_BATTLE,     ## 开始战斗
	OBSERVE_BATTLE,   ## 观察战斗
	VICTORY,          ## 胜利结算
}

var current_phase: Phase = Phase.NONE

## 步骤数据
var phase_steps: Dictionary = {
	Phase.UNIT_SELECT: {
		"message": "选择一个单位准备放置到战场。\n点击下方的单位按钮。",
		"highlight_area": "unit_list",
	},
	Phase.UNIT_PLACE: {
		"message": "点击网格放置单位。\n单位只能放在下方蓝色区域。",
		"highlight_area": "grid_area",
	},
	Phase.START_BATTLE: {
		"message": "放置完成后，点击「开始战斗」按钮！",
		"highlight_area": "start_button",
	},
	Phase.OBSERVE_BATTLE: {
		"message": "战斗自动进行！\n观察你的单位与敌人战斗。",
		"highlight_area": "",
	},
	Phase.VICTORY: {
		"message": "恭喜胜利！获得金币奖励！\n继续挑战更多关卡！",
		"highlight_area": "result_panel",
	},
}

## UI 节点
var overlay: ColorRect
var message_panel: PanelContainer
var message_label: Label
var next_button: Button
var skip_button: Button

## 是否已初始化
var is_initialized: bool = false

## 是否在战斗场景
var is_in_battle: bool = false


func _ready() -> void:
	_setup_ui()
	is_initialized = true

	# 连接 TutorialManager 信号
	TutorialManager.tutorial_started.connect(_on_tutorial_started)
	TutorialManager.tutorial_step_changed.connect(_on_tutorial_step_changed)
	TutorialManager.tutorial_completed.connect(_on_tutorial_completed)


func _setup_ui() -> void:
	# 半透明遮罩
	overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0, 0, 0, 0.5)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.visible = false
	add_child(overlay)

	# 消息面板容器
	message_panel = PanelContainer.new()
	message_panel.name = "MessagePanel"
	message_panel.anchors_preset = Control.PRESET_CENTER_BOTTOM
	message_panel.offset_left = -260
	message_panel.offset_right = 260
	message_panel.offset_top = -180
	message_panel.offset_bottom = -20
	message_panel.visible = false

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.15, 0.2, 0.95)
	style.border_color = Color(0.4, 0.6, 0.8, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	message_panel.add_theme_stylebox_override("panel", style)
	add_child(message_panel)

	# 内容容器
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	message_panel.add_child(vbox)

	# 消息文本
	message_label = Label.new()
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	message_label.custom_minimum_size.x = 480
	vbox.add_child(message_label)

	# 间隔
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 15
	vbox.add_child(spacer)

	# 按钮容器
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 20)
	vbox.add_child(button_container)

	# 跳过按钮
	skip_button = Button.new()
	skip_button.text = "跳过教程"
	skip_button.custom_minimum_size = Vector2(100, 40)
	_setup_button_style(skip_button, Color(0.3, 0.3, 0.35, 1))
	skip_button.pressed.connect(_on_skip_pressed)
	button_container.add_child(skip_button)

	# 下一步按钮
	next_button = Button.new()
	next_button.text = "下一步"
	next_button.custom_minimum_size = Vector2(120, 40)
	_setup_button_style(next_button, Color(0.2, 0.45, 0.55, 1))
	next_button.pressed.connect(_on_next_pressed)
	button_container.add_child(next_button)


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


## 显示教程提示
func show_tutorial_hint(phase: Phase) -> void:
	if not phase_steps.has(phase):
		return

	current_phase = phase
	var step_data = phase_steps[phase]

	message_label.text = step_data.get("message", "")
	message_panel.visible = true
	overlay.visible = true

	# 淡入动画
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)


## 隐藏教程提示
func hide_tutorial_hint() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		message_panel.visible = false
		overlay.visible = false
	)


## 开始战斗教程
func start_battle_tutorial() -> void:
	if TutorialManager.should_show_tutorial(TutorialManager.TutorialID.BATTLE):
		TutorialManager.start_tutorial(TutorialManager.TutorialID.BATTLE)
		await get_tree().create_timer(0.5).timeout
		show_tutorial_hint(Phase.UNIT_SELECT)


## 单位已选择 - 推进到放置阶段
func on_unit_selected() -> void:
	if current_phase == Phase.UNIT_SELECT:
		advance_phase()


## 单位已放置 - 检查是否可以开始战斗
func on_unit_placed() -> void:
	if current_phase == Phase.UNIT_PLACE:
		# 保持当前阶段，允许放置更多单位
		pass


## 开始战斗按钮可用 - 推进到开始战斗阶段
func on_can_start_battle() -> void:
	if current_phase == Phase.UNIT_PLACE:
		advance_phase()


## 战斗开始 - 推进到观察战斗阶段
func on_battle_started() -> void:
	if current_phase == Phase.START_BATTLE:
		advance_phase()
		is_in_battle = true


## 战斗结束 - 推进到胜利阶段
func on_battle_ended(victory: bool) -> void:
	if current_phase == Phase.OBSERVE_BATTLE:
		if victory:
			advance_phase()
		else:
			# 失败时完成教程但不显示胜利消息
			complete_tutorial()


## 推进到下一阶段
func advance_phase() -> void:
	hide_tutorial_hint()

	match current_phase:
		Phase.UNIT_SELECT:
			current_phase = Phase.UNIT_PLACE
		Phase.UNIT_PLACE:
			current_phase = Phase.START_BATTLE
		Phase.START_BATTLE:
			current_phase = Phase.OBSERVE_BATTLE
		Phase.OBSERVE_BATTLE:
			current_phase = Phase.VICTORY
		Phase.VICTORY:
			complete_tutorial()
			return

	await get_tree().create_timer(0.3).timeout
	show_tutorial_hint(current_phase)


## 完成教程
func complete_tutorial() -> void:
	hide_tutorial_hint()
	current_phase = Phase.NONE
	TutorialManager.complete_tutorial()


## 跳过按钮回调
func _on_skip_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	complete_tutorial()


## 下一步按钮回调
func _on_next_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	advance_phase()


## TutorialManager 信号回调
func _on_tutorial_started(tutorial_id: String) -> void:
	if tutorial_id == "BATTLE":
		await get_tree().create_timer(0.5).timeout
		show_tutorial_hint(Phase.UNIT_SELECT)


func _on_tutorial_step_changed(tutorial_id: String, step: int) -> void:
	# 战斗教程使用自己的阶段系统
	pass


func _on_tutorial_completed(tutorial_id: String) -> void:
	if tutorial_id == "BATTLE":
		hide_tutorial_hint()
		current_phase = Phase.NONE


## 创建战斗教程组件（静态方法）
static func create(parent: Node) -> Control:
	var tutorial = Control.new()
	tutorial.name = "BattleTutorial"
	tutorial.anchors_preset = Control.PRESET_FULL_RECT
	tutorial.set_script(preload("res://scenes/tutorial/battle_tutorial.gd"))
	parent.add_child(tutorial)
	return tutorial
