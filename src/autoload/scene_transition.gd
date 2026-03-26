# scene_transition.gd - 场景过渡管理器
# 提供场景切换的淡入淡出效果

extends CanvasLayer

## 单例引用
static var instance: CanvasLayer = null

## 过渡颜色层
var fade_rect: ColorRect = null

## 过渡持续时间
const FADE_DURATION: float = 0.3

## 是否正在过渡
var is_transitioning: bool = false


func _ready() -> void:
	instance = self
	layer = 100  # 最顶层

	# 创建全屏黑色遮罩
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.z_index = 1000
	add_child(fade_rect)


## 淡出当前场景
func fade_out(duration: float = FADE_DURATION) -> void:
	if is_transitioning:
		return

	is_transitioning = true
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration)
	await tween.finished


## 淡入新场景
func fade_in(duration: float = FADE_DURATION) -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, duration)
	await tween.finished

	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false


## 带过渡的场景切换
static func change_scene(scene_path: String, duration: float = FADE_DURATION) -> void:
	if instance == null:
		# 无过渡管理器，直接切换
		SceneTree.change_scene_to_file(scene_path)
		return

	# 显示加载指示器
	var tree = instance.get_tree()
	if tree and tree.root:
		show_loading(tree.root, "加载场景...")

	await instance.fade_out(duration)
	instance.get_tree().change_scene_to_file(scene_path)
	await instance.get_tree().create_timer(0.05).timeout
	await instance.fade_in(duration)

	# 隐藏加载指示器
	hide_loading()


## 静态方法：直接切换场景（兼容旧代码）
static func change_scene_to_file(scene_path: String) -> void:
	if instance and not instance.is_transitioning:
		change_scene(scene_path)
	else:
		SceneTree.change_scene_to_file(scene_path)


## 显示弹出动画
static func popup_animation(control: Control) -> void:
	if control == null:
		return

	control.scale = Vector2(0.5, 0.5)
	control.modulate.a = 0.0
	control.visible = true

	var tween = control.create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "modulate:a", 1.0, 0.2)


## 显示金币飘字动画
static func show_gold_floating_text(parent: Node, amount: int, position: Vector2) -> void:
	if parent == null:
		return

	var label = Label.new()
	label.text = "%+d" % amount
	label.position = position
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1) if amount > 0 else Color(0.9, 0.3, 0.3, 1))
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.1, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.z_index = 100
	parent.add_child(label)

	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", position.y - 60, 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.6).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)


## 显示关卡解锁动画
static func show_level_unlock_animation(parent: Node, level_name: String, position: Vector2) -> void:
	if parent == null:
		return

	# 创建解锁提示容器
	var container = Control.new()
	container.position = position
	container.z_index = 200
	parent.add_child(container)

	# 背景
	var bg = PanelContainer.new()
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.2, 0.35, 0.95)
	bg_style.border_color = Color(0.4, 0.6, 0.9, 1)
	bg_style.set_border_width_all(3)
	bg_style.set_corner_radius_all(12)
	bg_style.shadow_color = Color(0, 0, 0, 0.5)
	bg_style.shadow_size = 8
	bg.add_theme_stylebox_override("panel", bg_style)
	container.add_child(bg)

	# 内容容器
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	bg.add_child(vbox)

	# 图标
	var icon_label = Label.new()
	icon_label.text = "🔓"
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 36)
	vbox.add_child(icon_label)

	# 标题
	var title_label = Label.new()
	title_label.text = "新关卡解锁!"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0, 1))
	vbox.add_child(title_label)

	# 关卡名称
	var name_label = Label.new()
	name_label.text = level_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.7, 1))
	vbox.add_child(name_label)

	# 播放解锁音效
	SoundManager.play_sfx(SoundManager.SFX.LEVEL_UNLOCK)

	# 入场动画
	container.scale = Vector2(0.3, 0.3)
	container.modulate.a = 0.0

	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(container, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(container, "modulate:a", 1.0, 0.3)

	# 添加光晕效果
	var glow = Label.new()
	glow.text = "✨"
	glow.position = Vector2(-20, -10)
	glow.add_theme_font_size_override("font_size", 24)
	container.add_child(glow)

	var glow_tween = parent.create_tween()
	glow_tween.set_loops(3)
	glow_tween.tween_property(glow, "modulate:a", 0.3, 0.3)
	glow_tween.tween_property(glow, "modulate:a", 1.0, 0.3)

	# 消失动画
	await parent.get_tree().create_timer(2.0).timeout
	var fade_tween = parent.create_tween()
	fade_tween.set_parallel(true)
	fade_tween.tween_property(container, "scale", Vector2(1.2, 1.2), 0.3)
	fade_tween.tween_property(container, "modulate:a", 0.0, 0.3)
	fade_tween.chain().tween_callback(container.queue_free)


## 显示加载指示器
static var loading_indicator: Control = null

static func show_loading(parent: Node, message: String = "加载中...") -> void:
	if loading_indicator != null:
		return

	loading_indicator = preload("res://scenes/notification/loading_indicator.tscn").instantiate()
	loading_indicator.setup(message, false)
	parent.add_child(loading_indicator)
	loading_indicator.show_indicator()


## 隐藏加载指示器
static func hide_loading() -> void:
	if loading_indicator == null:
		return

	loading_indicator.hide_indicator()
	loading_indicator = null


## 显示带进度的加载指示器
static func show_loading_with_progress(parent: Node, message: String = "加载中...") -> Control:
	if loading_indicator != null:
		return loading_indicator

	loading_indicator = preload("res://scenes/notification/loading_indicator.tscn").instantiate()
	loading_indicator.setup(message, true)
	parent.add_child(loading_indicator)
	loading_indicator.show_indicator()
	return loading_indicator


## 更新加载进度
static func update_progress(progress: float) -> void:
	if loading_indicator != null and loading_indicator.has_method("set_progress"):
		loading_indicator.set_progress(progress)


## 显示确认对话框
## callback: 用户点击确认后调用的函数
static func show_confirm_dialog(parent: Node, title: String, message: String, callback: Callable) -> Control:
	var dialog = Control.new()
	dialog.set_anchors_preset(Control.PRESET_FULL_RECT)
	dialog.z_index = 400
	parent.add_child(dialog)

	# 半透明背景
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	dialog.add_child(bg)

	# 对话框容器
	var container = PanelContainer.new()
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.custom_minimum_size = Vector2(300, 150)
	container.position = Vector2(-150, -100)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.15, 0.2, 0.98)
	style.border_color = Color(0.4, 0.5, 0.7, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0, 0, 0, 0.6)
	style.shadow_size = 12
	container.add_theme_stylebox_override("panel", style)
	dialog.add_child(container)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	container.add_child(vbox)

	# 标题
	var title_label = Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1))
	vbox.add_child(title_label)

	# 消息
	var msg_label = Label.new()
	msg_label.text = message
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.add_theme_font_size_override("font_size", 14)
	msg_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8, 1))
	msg_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(msg_label)

	# 按钮行
	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)

	# 取消按钮
	var cancel_btn = Button.new()
	cancel_btn.text = "取消"
	cancel_btn.custom_minimum_size = Vector2(80, 35)
	cancel_btn.pressed.connect(func():
		SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
		dialog.queue_free()
	)
	btn_row.add_child(cancel_btn)

	# 确认按钮
	var confirm_btn = Button.new()
	confirm_btn.text = "确认"
	confirm_btn.custom_minimum_size = Vector2(80, 35)
	confirm_btn.pressed.connect(func():
		SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
		dialog.queue_free()
		if callback.is_valid():
			callback.call()
	)
	btn_row.add_child(confirm_btn)

	# 入场动画
	container.scale = Vector2(0.8, 0.8)
	container.modulate.a = 0.0

	var tween = parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(container, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(container, "modulate:a", 1.0, 0.15)

	return dialog
