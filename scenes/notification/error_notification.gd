# error_notification.gd - 错误通知弹窗
# 显示友好的错误提示和恢复选项

extends Control

## 显示时长（秒）
const DISPLAY_DURATION: float = 5.0

## 动画时长
const ANIM_DURATION: float = 0.4

## 当前错误信息
var _error_info: Resource = null

## 计时器
var _display_timer: float = 0.0

## 是否正在显示
var _is_showing: bool = false

## 主面板
var _panel: PanelContainer = null

## 按钮容器
var _button_container: HBoxContainer = null


func _ready() -> void:
	_setup_ui()
	hide()


func _setup_ui() -> void:
	# 设置锚点：底部居中
	anchors_preset = Control.PRESET_CENTER_BOTTOM
	offset_top = -120
	offset_left = -250
	offset_right = 250
	offset_bottom = -20

	# 主面板
	_panel = PanelContainer.new()
	_panel.anchors_preset = Control.PRESET_FULL_RECT
	add_child(_panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.12, 0.12, 0.95)
	style.border_color = Color(0.8, 0.3, 0.3, 1)
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, -4)
	_panel.add_theme_stylebox_override("panel", style)

	# 内容容器
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	_panel.add_child(vbox)

	# 顶部边距
	var top_padding = Control.new()
	top_padding.custom_minimum_size.y = 8
	vbox.add_child(top_padding)

	# 标题行
	var title_row = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 10)
	vbox.add_child(title_row)

	# 左侧边距
	var left_padding = Control.new()
	left_padding.custom_minimum_size.x = 15
	title_row.add_child(left_padding)

	# 图标
	var icon_label = Label.new()
	icon_label.name = "IconLabel"
	icon_label.text = "⚠"
	icon_label.add_theme_font_size_override("font_size", 24)
	title_row.add_child(icon_label)

	# 标题
	var title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "错误"
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color(1, 0.8, 0.8, 1))
	title_row.add_child(title_label)

	# 右侧边距
	var right_padding = Control.new()
	right_padding.custom_minimum_size.x = 15
	title_row.add_child(right_padding)

	# 消息
	var message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.text = ""
	message_label.add_theme_font_size_override("font_size", 14)
	message_label.add_theme_color_override("font_color", Color(0.9, 0.88, 0.85, 1))
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.custom_minimum_size.x = 450
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(message_label)

	# 按钮容器
	_button_container = HBoxContainer.new()
	_button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_button_container.add_theme_constant_override("separation", 15)
	vbox.add_child(_button_container)

	# 底部边距
	var bottom_padding = Control.new()
	bottom_padding.custom_minimum_size.y = 12
	vbox.add_child(bottom_padding)


func _process(delta: float) -> void:
	if _is_showing:
		_display_timer -= delta
		if _display_timer <= 0:
			_hide_notification()


## 设置错误信息
func setup(error_info: Resource) -> void:
	_error_info = error_info
	_update_content()


## 更新内容
func _update_content() -> void:
	if _error_info == null:
		return

	# 更新标题
	var title_label = _panel.get_node("TitleLabel") as Label
	if title_label:
		title_label.text = _error_info.title

	# 更新消息
	var message_label = _panel.get_node("MessageLabel") as Label
	if message_label:
		message_label.text = _error_info.message

	# 创建恢复按钮
	_create_recovery_buttons()


## 创建恢复按钮
func _create_recovery_buttons() -> void:
	# 清空现有按钮
	for child in _button_container.get_children():
		child.queue_free()

	if _error_info == null or _error_info.recovery_options.is_empty():
		# 创建关闭按钮
		var close_btn = Button.new()
		close_btn.text = "关闭"
		close_btn.custom_minimum_size = Vector2(80, 32)
		_setup_button_style(close_btn, false)
		close_btn.pressed.connect(_hide_notification)
		_button_container.add_child(close_btn)
		return

	# 根据恢复选项创建按钮
	for option in _error_info.recovery_options:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(90, 32)

		match option:
			ErrorManager.RecoveryOption.RETRY:
				btn.text = "重试"
				_setup_button_style(btn, true)
				btn.pressed.connect(_on_retry_pressed)
			ErrorManager.RecoveryOption.RESTORE_DEFAULT:
				btn.text = "恢复默认"
				_setup_button_style(btn, false)
				btn.pressed.connect(_on_restore_pressed)
			ErrorManager.RecoveryOption.IGNORE:
				btn.text = "忽略"
				_setup_button_style(btn, false)
				btn.pressed.connect(_on_ignore_pressed)
			ErrorManager.RecoveryOption.RESTART:
				btn.text = "重启游戏"
				_setup_button_style(btn, true)
				btn.pressed.connect(_on_restart_pressed)
			_:
				continue

		_button_container.add_child(btn)


func _setup_button_style(button: Button, is_primary: bool) -> void:
	if is_primary:
		ButtonStyles.apply_danger(button)
	else:
		ButtonStyles.apply_secondary(button)
	button.add_theme_font_size_override("font_size", 14)


## 显示通知
func show_notification() -> void:
	if _is_showing:
		_hide_notification()
		await get_tree().create_timer(0.2).timeout

	_is_showing = true
	_display_timer = DISPLAY_DURATION
	show()

	# 从底部滑入
	modulate.a = 0
	position.y = 50

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, ANIM_DURATION)
	tween.tween_property(self, "position:y", 0, ANIM_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## 隐藏通知
func _hide_notification() -> void:
	if not _is_showing:
		return

	_is_showing = false

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, ANIM_DURATION * 0.5)
	tween.tween_property(self, "position:y", 50, ANIM_DURATION * 0.5)

	await tween.finished
	queue_free()


## ==================== 按钮回调 ====================

func _on_retry_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	if _error_info and _error_info.recovery_callback.is_valid():
		_error_info.recovery_callback.call()
	_hide_notification()


func _on_restore_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	if _error_info and _error_info.recovery_callback.is_valid():
		_error_info.recovery_callback.call()
	_hide_notification()


func _on_ignore_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	_hide_notification()


func _on_restart_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	# 保存当前状态后重启
	get_tree().reload_current_scene()
