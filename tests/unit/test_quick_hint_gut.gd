# test_quick_hint_gut.gd - QuickHint 组件单元测试 (GUT 版本)
# 参考: scenes/tutorial/quick_hint.gd
# 运行: 在 Godot 编辑器中按 F6 运行，或使用 GUT 命令行

extends GutTest


## 测试 UI 初始化
func test_ui_setup_creates_hint_label() -> void:
	var hint = _create_hint()

	assert_not_null(hint.hint_label, "应创建 hint_label 成员")
	assert_eq(hint.hint_label.name, "HintLabel", "标签名称应为 HintLabel")
	assert_false(hint.hint_label.visible, "初始状态应隐藏")


## 测试默认显示时长
func test_default_duration() -> void:
	var hint = _create_hint()

	assert_eq(hint.DEFAULT_DURATION, 2.5, "默认显示时长应为 2.5 秒")


## 测试基础提示显示
func test_show_hint_sets_text() -> void:
	var hint = _create_hint()

	hint.show_hint("测试消息")

	assert_eq(hint.hint_label.text, "测试消息", "提示文本应正确设置")
	assert_true(hint.hint_label.visible, "提示应可见")


## 测试提示颜色设置
func test_show_hint_sets_custom_color() -> void:
	var hint = _create_hint()

	var custom_color = Color(1.0, 0.5, 0.0)
	hint.show_hint("彩色提示", custom_color)

	var font_color = hint.hint_label.get_theme_color("font_color")
	assert_almost_eq(font_color.r, custom_color.r, 0.01, "红色通道应匹配")
	assert_almost_eq(font_color.g, custom_color.g, 0.01, "绿色通道应匹配")
	assert_almost_eq(font_color.b, custom_color.b, 0.01, "蓝色通道应匹配")


## 测试克制提示文本
func test_counter_hint_contains_correct_text() -> void:
	var hint = _create_hint()

	hint.show_counter_hint()

	assert_true(hint.hint_label.text.contains("克制"), "克制提示应包含'克制'")
	assert_true(hint.hint_label.text.contains("+50%"), "克制提示应包含'+50%'")


## 测试克制提示颜色
func test_counter_hint_uses_gold_color() -> void:
	var hint = _create_hint()

	hint.show_counter_hint()

	var font_color = hint.hint_label.get_theme_color("font_color")
	var expected_gold = Color(1, 0.85, 0.2)
	assert_almost_eq(font_color.r, expected_gold.r, 0.01, "克制提示应为金色 R")
	assert_almost_eq(font_color.g, expected_gold.g, 0.01, "克制提示应为金色 G")
	assert_almost_eq(font_color.b, expected_gold.b, 0.01, "克制提示应为金色 B")


## 测试协同提示文本
func test_synergy_hint_contains_correct_text() -> void:
	var hint = _create_hint()

	hint.show_synergy_hint("战士兄弟")

	assert_true(hint.hint_label.text.contains("协同触发"), "协同提示应包含'协同触发'")
	assert_true(hint.hint_label.text.contains("战士兄弟"), "协同提示应包含协同名称")


## 测试协同提示颜色
func test_synergy_hint_uses_cyan_color() -> void:
	var hint = _create_hint()

	hint.show_synergy_hint("测试协同")

	var font_color = hint.hint_label.get_theme_color("font_color")
	var expected_cyan = Color(0.5, 1, 0.8)
	assert_almost_eq(font_color.r, expected_cyan.r, 0.01, "协同提示应为青绿色 R")
	assert_almost_eq(font_color.g, expected_cyan.g, 0.01, "协同提示应为青绿色 G")
	assert_almost_eq(font_color.b, expected_cyan.b, 0.01, "协同提示应为青绿色 B")


## 测试动画取消
func test_new_hint_cancels_previous_tween() -> void:
	var hint = _create_hint()

	hint.show_hint("第一条提示")
	var first_tween = hint.current_tween

	await get_tree().process_frame

	hint.show_hint("第二条提示")

	assert_ne(hint.current_tween, first_tween, "新提示应创建新 Tween")


## 测试静态创建方法返回有效实例
func test_static_create_returns_valid_instance() -> void:
	var parent = Control.new()
	add_child_autofree(parent)

	var created = preload("res://scenes/tutorial/quick_hint.gd").create(parent)

	assert_not_null(created, "静态创建应返回有效实例")
	assert_eq(created.name, "QuickHint", "创建的节点名称应正确")


## 测试静态创建添加到父节点
func test_static_create_adds_to_parent() -> void:
	var parent = Control.new()
	add_child_autofree(parent)

	var created = preload("res://scenes/tutorial/quick_hint.gd").create(parent)

	assert_true(parent.has_node("QuickHint"), "应添加到父节点")


## 测试静态创建锚点设置
func test_static_create_sets_full_rect_anchors() -> void:
	var parent = Control.new()
	add_child_autofree(parent)

	var created = preload("res://scenes/tutorial/quick_hint.gd").create(parent)

	assert_eq(created.anchors_preset, Control.PRESET_FULL_RECT, "锚点应为全屏")


## 测试静态创建鼠标过滤
func test_static_create_ignores_mouse() -> void:
	var parent = Control.new()
	add_child_autofree(parent)

	var created = preload("res://scenes/tutorial/quick_hint.gd").create(parent)

	assert_eq(created.mouse_filter, Control.MOUSE_FILTER_IGNORE, "应忽略鼠标事件")


## 测试连续显示多个提示
func test_multiple_hints_in_sequence() -> void:
	var hint = _create_hint()

	hint.show_hint("提示1")
	assert_eq(hint.hint_label.text, "提示1", "第一条提示")

	await get_tree().process_frame

	hint.show_hint("提示2")
	assert_eq(hint.hint_label.text, "提示2", "第二条提示")

	await get_tree().process_frame

	hint.show_hint("提示3")
	assert_eq(hint.hint_label.text, "提示3", "第三条提示")


## 创建测试用 QuickHint 实例
func _create_hint() -> Control:
	var ctrl = Control.new()
	ctrl.name = "QuickHint"
	ctrl.set_script(load("res://scenes/tutorial/quick_hint.gd"))
	add_child_autofree(ctrl)
	ctrl._ready()
	return ctrl
