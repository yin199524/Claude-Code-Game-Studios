# confirm_dialog.gd - 确认对话框组件
# 通用的确认/取消对话框，用于购买、升级、重置等操作

extends Control

## 信号

## 确认按钮点击
signal confirmed()

## 取消按钮点击
signal cancelled()

## 配置
## 对话框标题
@export var dialog_title: String = "确认"

## 对话框内容
@export var dialog_message: String = "确定要执行此操作吗？"

## 确认按钮文本
@export var confirm_text: String = "确认"

## 取消按钮文本
@export var cancel_text: String = "取消"

## 是否显示取消按钮
@export var show_cancel: bool = true

## 确认按钮是否为危险操作（红色）
@export var is_dangerous: bool = false

## 价格信息（可选）
@export var price_info: String = ""

## UI 节点引用
var _title_label: Label
var _message_label: Label
var _price_label: Label
var _confirm_button: Button
var _cancel_button: Button


func _ready() -> void:
	_setup_ui()


func _setup_ui() -> void:
	# 全屏背景遮罩
	var overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.gui_input.connect(_on_overlay_input)
	add_child(overlay)

	# 主面板
	var main_panel = PanelContainer.new()
	main_panel.name = "MainPanel"
	main_panel.anchors_preset = Control.PRESET_CENTER
	main_panel.offset_left = -200
	main_panel.offset_right = 200
	main_panel.offset_top = -120
	main_panel.offset_bottom = 80

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.14, 0.18, 0.98)
	panel_style.border_color = Color(0.35, 0.45, 0.6, 1)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	panel_style.shadow_size = 10
	panel_style.shadow_offset = Vector2(4, 4)
	main_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(main_panel)

	# 内容容器
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	main_panel.add_child(vbox)

	# 标题
	_title_label = Label.new()
	_title_label.text = dialog_title
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 20)
	_title_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1))
	vbox.add_child(_title_label)

	# 分隔线
	var separator = HSeparator.new()
	separator.add_theme_stylebox_override("separator", _create_separator_style())
	vbox.add_child(separator)

	# 消息内容
	_message_label = Label.new()
	_message_label.text = dialog_message
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", 16)
	_message_label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92, 1))
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message_label.custom_minimum_size.x = 350
	vbox.add_child(_message_label)

	# 价格信息（如果有的话）
	if price_info != "":
		_price_label = Label.new()
		_price_label.text = price_info
		_price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_price_label.add_theme_font_size_override("font_size", 18)
		_price_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
		vbox.add_child(_price_label)

	# 按钮容器
	var button_hbox = HBoxContainer.new()
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(button_hbox)

	# 取消按钮
	if show_cancel:
		_cancel_button = Button.new()
		_cancel_button.text = cancel_text
		_cancel_button.custom_minimum_size = Vector2(100, 40)
		_setup_button_style(_cancel_button, false)
		_cancel_button.pressed.connect(_on_cancel_pressed)
		button_hbox.add_child(_cancel_button)

	# 确认按钮
	_confirm_button = Button.new()
	_confirm_button.text = confirm_text
	_confirm_button.custom_minimum_size = Vector2(100, 40)
	_setup_button_style(_confirm_button, true, is_dangerous)
	_confirm_button.pressed.connect(_on_confirm_pressed)
	button_hbox.add_child(_confirm_button)

	# 底部间隔
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 8
	vbox.add_child(spacer)


func _create_separator_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.35, 0.45, 1)
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	return style


func _setup_button_style(button: Button, is_confirm: bool, is_danger: bool = false) -> void:
	if is_confirm:
		if is_danger:
			ButtonStyles.apply_danger(button)
		else:
			ButtonStyles.apply_success(button)
	else:
		ButtonStyles.apply_secondary(button)
	button.add_theme_font_size_override("font_size", 16)


func _on_overlay_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_cancel_pressed()


func _on_confirm_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	confirmed.emit()
	queue_free()


func _on_cancel_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	cancelled.emit()
	queue_free()


## 设置对话框内容
func setup(title: String, message: String, confirm_btn: String = "确认", cancel_btn: String = "取消", danger: bool = false, price: String = "") -> void:
	dialog_title = title
	dialog_message = message
	confirm_text = confirm_btn
	cancel_text = cancel_btn
	is_dangerous = danger
	price_info = price

	# 更新 UI
	if _title_label:
		_title_label.text = title
	if _message_label:
		_message_label.text = message
	if _confirm_button:
		_confirm_button.text = confirm_btn
		_setup_button_style(_confirm_button, true, danger)
	if _cancel_button:
		_cancel_button.text = cancel_btn
	if price != "" and _price_label:
		_price_label.text = price
		_price_label.visible = true


## 显示确认对话框（静态方法）
## 返回对话框实例，可通过 confirmed/cancelled 信号处理结果
static func show(parent: Node, title: String, message: String, confirm_text: String = "确认", cancel_text: String = "取消", is_dangerous: bool = false, price: String = "") -> Control:
	var dialog = preload("res://scenes/dialog/confirm_dialog.tscn").instantiate()
	dialog.dialog_title = title
	dialog.dialog_message = message
	dialog.confirm_text = confirm_text
	dialog.cancel_text = cancel_text
	dialog.is_dangerous = is_dangerous
	dialog.price_info = price
	parent.add_child(dialog)
	return dialog


## 显示购买确认对话框
static func show_purchase(parent: Node, item_name: String, price: int) -> Control:
	return show(
		parent,
		"购买确认",
		"确定要购买 %s 吗？" % item_name,
		"购买 (%d 金币)" % price,
		"取消",
		false,
		"💰 %d" % price
	)


## 显示升级确认对话框
static func show_upgrade(parent: Node, unit_name: String, cost: int, current_level: int, next_level: int) -> Control:
	return show(
		parent,
		"升级确认",
		"确定要将 %s 从 Lv.%d 升级到 Lv.%d 吗？" % [unit_name, current_level, next_level],
		"升级 (%d 金币)" % cost,
		"取消",
		false,
		"💰 %d" % cost
	)


## 显示重置确认对话框
static func show_reset(parent: Node) -> Control:
	return show(
		parent,
		"重置存档",
		"此操作将清除所有游戏数据，包括金币、单位和进度。\n此操作不可撤销！",
		"确认重置",
		"取消",
		true,
		""
	)


## 显示退出确认对话框
static func show_quit(parent: Node) -> Control:
	return show(
		parent,
		"退出游戏",
		"确定要退出游戏吗？",
		"退出",
		"取消",
		true,
		""
	)
