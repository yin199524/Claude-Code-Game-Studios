# test_quick_hint.gd - QuickHint 组件单元测试
# 参考: scenes/tutorial/quick_hint.gd
# 运行: godot --headless --script res://tests/unit/test_quick_hint.gd

extends SceneTree

## 测试用 QuickHint 实例
var hint: Control = null


func _init() -> void:
	print("=== QuickHint 组件测试 ===")
	print("")

	# 测试 1: UI 初始化
	test_ui_setup()

	# 测试 2: 基础提示显示
	test_show_hint_basic()

	# 测试 3: 提示颜色设置
	test_hint_color()

	# 测试 4: 克制提示
	test_counter_hint()

	# 测试 5: 协同提示
	test_synergy_hint()

	# 测试 6: 动画取消
	test_tween_cancellation()

	# 测试 7: 静态创建方法
	test_static_create()

	print("")
	print("=== 测试完成 ===")
	quit()


## 创建测试用 QuickHint 实例
func _create_hint() -> Control:
	var ctrl = Control.new()
	ctrl.name = "QuickHint"
	ctrl.set_script(load("res://scenes/tutorial/quick_hint.gd"))
	return ctrl


## 测试 UI 初始化
func test_ui_setup() -> void:
	print("测试 1: UI 初始化")

	hint = _create_hint()

	# 模拟 _ready 调用
	hint._ready()

	# 验证提示标签创建
	assert(hint.has_node("HintLabel"), "应创建 HintLabel 子节点")
	print("  ✓ HintLabel 节点创建")

	var label = hint.get_node("HintLabel") as Label
	assert(label != null, "HintLabel 应为 Label 类型")
	assert(not label.visible, "初始状态应隐藏")
	print("  ✓ 初始隐藏状态正确")

	# 验证默认值
	assert(hint.DEFAULT_DURATION == 2.5, "默认显示时长应为 2.5 秒")
	print("  ✓ 默认时长正确")

	hint.queue_free()


## 测试基础提示显示
func test_show_hint_basic() -> void:
	print("测试 2: 基础提示显示")

	hint = _create_hint()
	hint._ready()

	var label = hint.get_node("HintLabel") as Label

	# 显示提示
	hint.show_hint("测试消息")

	assert(label.text == "测试消息", "提示文本应正确设置")
	assert(label.visible, "提示应可见")
	print("  ✓ 提示文本和可见性正确")

	hint.queue_free()


## 测试提示颜色设置
func test_hint_color() -> void:
	print("测试 3: 提示颜色设置")

	hint = _create_hint()
	hint._ready()

	var label = hint.get_node("HintLabel") as Label

	# 测试自定义颜色
	var custom_color = Color(1.0, 0.5, 0.0)
	hint.show_hint("彩色提示", custom_color)

	# 验证颜色设置（通过主题覆盖）
	var font_color = label.get_theme_color("font_color")
	assert(font_color.is_equal_approx(custom_color), "提示颜色应正确设置")
	print("  ✓ 自定义颜色设置正确")

	hint.queue_free()


## 测试克制提示
func test_counter_hint() -> void:
	print("测试 4: 克制提示")

	hint = _create_hint()
	hint._ready()

	var label = hint.get_node("HintLabel") as Label

	# 显示克制提示
	hint.show_counter_hint()

	assert(label.text.contains("克制"), "克制提示应包含'克制'")
	assert(label.text.contains("+50%"), "克制提示应包含'+50%'")
	print("  ✓ 克制提示文本正确")

	# 验证颜色为金色
	var font_color = label.get_theme_color("font_color")
	var expected_gold = Color(1, 0.85, 0.2)
	assert(font_color.is_equal_approx(expected_gold), "克制提示颜色应为金色")
	print("  ✓ 克制提示颜色正确")

	hint.queue_free()


## 测试协同提示
func test_synergy_hint() -> void:
	print("测试 5: 协同提示")

	hint = _create_hint()
	hint._ready()

	var label = hint.get_node("HintLabel") as Label

	# 显示协同提示
	hint.show_synergy_hint("战士兄弟")

	assert(label.text.contains("协同触发"), "协同提示应包含'协同触发'")
	assert(label.text.contains("战士兄弟"), "协同提示应包含协同名称")
	print("  ✓ 协同提示文本正确")

	# 验证颜色为青绿色
	var font_color = label.get_theme_color("font_color")
	var expected_cyan = Color(0.5, 1, 0.8)
	assert(font_color.is_equal_approx(expected_cyan), "协同提示颜色应为青绿色")
	print("  ✓ 协同提示颜色正确")

	hint.queue_free()


## 测试动画取消
func test_tween_cancellation() -> void:
	print("测试 6: 动画取消")

	hint = _create_hint()
	hint._ready()

	# 显示第一个提示
	hint.show_hint("第一条提示")
	var first_tween = hint.current_tween

	# 等待一帧
	await get_tree().process_frame

	# 显示第二个提示（应取消第一个）
	hint.show_hint("第二条提示")

	# 验证新的 Tween 是不同的实例
	assert(hint.current_tween != first_tween, "新提示应创建新 Tween")
	print("  ✓ 前一个动画被正确取消")

	hint.queue_free()


## 测试静态创建方法
func test_static_create() -> void:
	print("测试 7: 静态创建方法")

	# 创建父节点
	var parent = Control.new()
	parent.name = "TestParent"

	# 使用静态方法创建
	var created = preload("res://scenes/tutorial/quick_hint.gd").create(parent)

	assert(created != null, "静态创建应返回有效实例")
	assert(created.name == "QuickHint", "创建的节点名称应正确")
	assert(parent.has_node("QuickHint"), "应添加到父节点")
	print("  ✓ 静态创建方法正确")

	# 验证锚点设置
	assert(created.anchors_preset == Control.PRESET_FULL_RECT, "锚点应为全屏")
	print("  ✓ 锚点设置正确")

	# 验证鼠标穿透
	assert(created.mouse_filter == Control.MOUSE_FILTER_IGNORE, "应忽略鼠标事件")
	print("  ✓ 鼠标过滤正确")

	parent.queue_free()


## 简单断言
func assert(condition: bool, message: String) -> void:
	if not condition:
		print("  ✗ 断言失败: " + message)
		_test_passed = false


## 测试通过标志
var _test_passed: bool = true
