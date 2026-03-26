# loading_indicator.gd - 加载状态指示器
# 显示加载进度和状态信息

extends Control

## 动画时长
const ANIM_DURATION: float = 0.25

## 当前加载消息
var _message: String = "加载中..."

## 进度值 (0.0 - 1.0)
var _progress: float = 0.0

## 是否显示进度条
var _show_progress: bool = false

## 是否正在显示
var _is_showing: bool = false

## UI 节点
var _panel: PanelContainer = null
var _message_label: Label = null
var _progress_bar: ProgressBar = null
var _spinner: Label = null
var _tween: Tween = null


func _ready() -> void:
	_setup_ui()
	hide()


func _setup_ui() -> void:
	# 全屏背景遮罩
	var overlay = ColorRect.new()
	overlay.name = "Overlay"
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.anchors_preset = Control.PRESET_FULL_RECT
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# 主面板
	_panel = PanelContainer.new()
	_panel.anchors_preset = Control.PRESET_CENTER
	_panel.offset_left = -160
	_panel.offset_right = 160
	_panel.offset_top = -60
	_panel.offset_bottom = 40

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.14, 0.18, 0.98)
	panel_style.border_color = Color(0.35, 0.45, 0.6, 1)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	panel_style.shadow_size = 10
	panel_style.shadow_offset = Vector2(4, 4)
	_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(_panel)

	# 内容容器
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	_panel.add_child(vbox)

	# 顶部边距
	var top_spacer = Control.new()
	top_spacer.custom_minimum_size.y = 8
	vbox.add_child(top_spacer)

	# 图标和消息容器
	var content_hbox = HBoxContainer.new()
	content_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	content_hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(content_hbox)

	# 加载动画图标
	_spinner = Label.new()
	_spinner.text = "⏳"
	_spinner.add_theme_font_size_override("font_size", 28)
	content_hbox.add_child(_spinner)

	# 消息文本
	_message_label = Label.new()
	_message_label.text = _message
	_message_label.add_theme_font_size_override("font_size", 18)
	_message_label.add_theme_color_override("font_color", Color(0.9, 0.88, 0.85, 1))
	content_hbox.add_child(_message_label)

	# 进度条容器
	var progress_container = VBoxContainer.new()
	progress_container.name = "ProgressContainer"
	vbox.add_child(progress_container)

	# 进度条
	_progress_bar = ProgressBar.new()
	_progress_bar.custom_minimum_size.y = 8
	_progress_bar.show_percentage = false
	_progress_bar.value = 0

	var progress_style = StyleBoxFlat.new()
	progress_style.bg_color = Color(0.2, 0.22, 0.28, 1)
	progress_style.set_corner_radius_all(4)
	_progress_bar.add_theme_stylebox_override("background", progress_style)

	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.3, 0.6, 0.8, 1)
	fill_style.set_corner_radius_all(4)
	_progress_bar.add_theme_stylebox_override("fill", fill_style)

	progress_container.add_child(_progress_bar)

	# 底部边距
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size.y = 8
	vbox.add_child(bottom_spacer)


func _process(delta: float) -> void:
	if _is_showing and _spinner:
		# 持续旋转动画
		_spinner.rotation += delta * 2.0


## 设置消息
func set_message(message: String) -> void:
	_message = message
	if _message_label:
		_message_label.text = message


## 设置进度
func set_progress(progress: float) -> void:
	_progress = clamp(progress, 0.0, 1.0)
	_show_progress = true

	if _progress_bar:
		_progress_bar.value = _progress * 100

	# 显示进度条
	var progress_container = get_node_or_null("Panel/VBoxContainer/ProgressContainer")
	if progress_container:
		progress_container.visible = true


## 显示加载指示器
func show_indicator() -> void:
	if _is_showing:
		return

	_is_showing = true
	show()

	# 淡入动画
	modulate.a = 0
	_panel.scale = Vector2(0.9, 0.9)

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, ANIM_DURATION)
	_tween.tween_property(_panel, "scale", Vector2(1.0, 1.0), ANIM_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## 隐藏加载指示器
func hide_indicator() -> void:
	if not _is_showing:
		return

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 0.0, ANIM_DURATION * 0.5)
	_tween.tween_property(_panel, "scale", Vector2(1.05, 1.05), ANIM_DURATION * 0.5)

	await _tween.finished

	_is_showing = false
	hide()
	queue_free()


## 设置并显示（便捷方法）
func setup(message: String, show_progress: bool = false) -> void:
	_message = message
	_show_progress = show_progress

	if _message_label:
		_message_label.text = message

	if _progress_bar:
		var progress_container = get_node_or_null("Panel/VBoxContainer/ProgressContainer")
		if progress_container:
			progress_container.visible = show_progress


## ==================== 静态方法 ====================

## 显示加载指示器
static func show_loading(parent: Node, message: String = "加载中...", show_progress: bool = false) -> Control:
	var indicator = preload("res://scenes/notification/loading_indicator.tscn").instantiate()
	indicator.setup(message, show_progress)
	parent.add_child(indicator)
	indicator.show_indicator()
	return indicator


## 隐藏加载指示器
static func hide_loading(indicator: Control) -> void:
	if indicator and indicator.has_method("hide_indicator"):
		indicator.hide_indicator()


## 场景切换时显示加载（带进度）
static func show_scene_loading(parent: Node, scene_name: String = "") -> Control:
	var message = "加载中..."
	if scene_name != "":
		message = "加载 %s..." % scene_name
	return show_loading(parent, message, false)


## 存档加载时显示
static func show_save_loading(parent: Node) -> Control:
	return show_loading(parent, "加载存档...", false)


## 资源加载时显示
static func show_resource_loading(parent: Node, resource_name: String = "") -> Control:
	var message = "加载资源..."
	if resource_name != "":
		message = "加载 %s..." % resource_name
	return show_loading(parent, message, true)
