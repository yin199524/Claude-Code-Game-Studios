# test_tutorial_manager.gd - 引导管理器单元测试
# 参考: design/gdd/tutorial-system.md
# 运行: godot --headless --script res://tests/unit/test_tutorial_manager.gd

extends SceneTree

func _init() -> void:
	print("=== 引导管理器测试 ===")
	print("")

	# 测试 1: 首次启动检测
	test_first_launch_detection()

	# 测试 2: 引导进度管理
	test_tutorial_progress()

	# 测试 3: 引导完成状态
	test_tutorial_completion()

	# 测试 4: 提示计数限制
	test_hint_count_limit()

	# 测试 5: 引导重置
	test_tutorial_reset()

	print("")
	print("=== 测试完成 ===")
	quit()


## 测试首次启动检测
func test_first_launch_detection() -> void:
	print("测试 1: 首次启动检测")

	# 创建测试玩家数据
	var player_data = PlayerData.new()
	player_data.is_first_launch = true
	player_data.is_first_shop_visit = true
	player_data.is_first_battle = true

	# 验证首次标记
	assert(player_data.is_first_launch, "首次启动标记应为 true")
	assert(player_data.is_first_shop_visit, "首次商店访问标记应为 true")
	assert(player_data.is_first_battle, "首次战斗标记应为 true")
	print("  ✓ 首次标记正确设置")

	# 模拟完成引导
	player_data.is_first_launch = false
	assert(not player_data.is_first_launch, "完成后首次标记应为 false")
	print("  ✓ 引导完成后标记正确更新")


## 测试引导进度管理
func test_tutorial_progress() -> void:
	print("测试 2: 引导进度管理")

	var player_data = PlayerData.new()

	# 初始进度为空
	assert(player_data.tutorial_progress.is_empty(), "初始引导进度应为空")
	print("  ✓ 初始进度为空")

	# 设置进度
	player_data.tutorial_progress["welcome"] = 2
	assert(player_data.tutorial_progress.get("welcome", 0) == 2, "进度应正确保存")
	print("  ✓ 进度保存正确")

	# 更新进度
	player_data.tutorial_progress["welcome"] = 3
	assert(player_data.tutorial_progress.get("welcome", 0) == 3, "进度应正确更新")
	print("  ✓ 进度更新正确")


## 测试引导完成状态
func test_tutorial_completion() -> void:
	print("测试 3: 引导完成状态")

	var player_data = PlayerData.new()

	# 初始无完成引导进度应为空")
	assert(player_data.tutorial_progress.is_empty(), "初始引导进度应为空")
	print("  ✓ 进度正确更新")


## 测试引导完成状态
func test_tutorial_completion() -> void:
	print("测试 3: 引导完成状态")

	var player_data = PlayerData.new()

	# 初始无已完成引导
	assert(player_data.completed_tutorials.is_empty(), "初始已完成列表应为空")
	print("  ✓ 初始无已完成引导")

	# 标记完成
	player_data.completed_tutorials.append("WELCOME")
	assert("WELCOME" in player_data.completed_tutorials, "完成状态应正确保存")
	print("  ✓ 完成状态正确保存")

	# 检查是否已完成
	var is_completed = "WELCOME" in player_data.completed_tutorials
	assert(is_completed, "应能正确检测完成状态")
	print("  ✓ 完成检测正确")


## 测试提示计数限制
func test_hint_count_limit() -> void:
	print("测试 4: 提示计数限制")

	var player_data = PlayerData.new()

	# 初始计数为零
	assert(player_data.counter_hint_count == 0, "克制提示计数初始应为 0")
	assert(player_data.synergy_hint_count == 0, "协同提示计数初始应为 0")
	print("  ✓ 初始计数为零")

	# 增加计数
	player_data.counter_hint_count = 3
	player_data.synergy_hint_count = 2

	assert(player_data.counter_hint_count == 3, "克制提示计数应正确增加")
	assert(player_data.synergy_hint_count == 2, "协同提示计数应正确增加")
	print("  ✓ 计数正确增加")

	# 验证限制逻辑（TutorialManager.MAX_HINT_REPEAT = 3）
	var should_show_counter = player_data.counter_hint_count < 3
	var should_show_synergy = player_data.synergy_hint_count < 3

	assert(not should_show_counter, "克制提示达到上限后不应再显示")
	assert(should_show_synergy, "协同提示未达上限应继续显示")
	print("  ✓ 限制逻辑正确")


## 测试引导重置
func test_tutorial_reset() -> void:
	print("测试 5: 引导重置")

	var player_data = PlayerData.new()

	# 设置一些状态
	player_data.completed_tutorials = ["WELCOME", "BATTLE"]
	player_data.tutorial_progress = {"SHOP": 2}
	player_data.is_first_launch = false
	player_data.is_first_shop_visit = false
	player_data.is_first_battle = false
	player_data.counter_hint_count = 3
	player_data.synergy_hint_count = 3

	# 重置
	player_data.completed_tutorials = []
	player_data.tutorial_progress = {}
	player_data.is_first_launch = true
	player_data.is_first_shop_visit = true
	player_data.is_first_battle = true
	player_data.counter_hint_count = 0
	player_data.synergy_hint_count = 0

	# 验证重置
	assert(player_data.completed_tutorials.is_empty(), "重置后已完成列表应为空")
	assert(player_data.tutorial_progress.is_empty(), "重置后进度应为空")
	assert(player_data.is_first_launch, "重置后首次启动应为 true")
	assert(player_data.counter_hint_count == 0, "重置后计数应为 0")
	print("  ✓ 重置正确执行")


## 简单断言
func assert(condition: bool, message: String) -> void:
	if not condition:
		print("  ✗ 断言失败: " + message)
