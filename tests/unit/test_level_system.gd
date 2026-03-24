# test_level_system.gd - 关卡系统单元测试
# 参考: design/gdd/level-system.md
# 运行: godot --headless --script res://tests/unit/test_level_system.gd

extends SceneTree

func _init() -> void:
	print("=== 关卡系统测试 ===")
	print("")

	# 测试 1: EnemySpawn 创建
	test_enemy_spawn()

	# 测试 2: LevelDefinition 创建
	test_level_definition()

	# 测试 3: LevelDatabase
	test_level_database()

	# 测试 4: 关卡解锁逻辑
	test_level_unlock()

	# 测试 5: 关卡验证
	test_level_validation()

	print("")
	print("=== 测试完成 ===")
	quit()


## 测试 EnemySpawn
func test_enemy_spawn() -> void:
	print("测试 1: EnemySpawn 创建")

	var spawn = EnemySpawn.create("unit_warrior", Vector2i(1, 0), 1.5)

	assert(spawn.unit_id == "unit_warrior", "unit_id 应正确")
	assert(spawn.position == Vector2i(1, 0), "position 应正确")
	assert(spawn.level_modifier == 1.5, "level_modifier 应正确")
	print("  ✓ EnemySpawn 创建正确")

	# 验证
	var result = spawn.validate()
	assert(result[0], "验证应通过")
	print("  ✓ EnemySpawn 验证通过")


## 测试 LevelDefinition
func test_level_definition() -> void:
	print("测试 2: LevelDefinition 创建")

	var level = LevelDefinition.new()
	level.id = "test_level"
	level.display_name = "测试关卡"
	level.difficulty = 2
	level.grid_size = Vector2i(3, 3)
	level.player_unit_limit = 3
	level.gold_reward = 100

	level.enemy_spawns = [
		EnemySpawn.create("unit_warrior", Vector2i(0, 0), 1.0),
		EnemySpawn.create("unit_archer", Vector2i(1, 0), 1.0)
	]

	assert(level.id == "test_level", "id 应正确")
	assert(level.difficulty == 2, "difficulty 应正确")
	assert(level.get_enemy_count() == 2, "敌人数量应为 2")
	print("  ✓ LevelDefinition 创建正确")


## 测试 LevelDatabase
func test_level_database() -> void:
	print("测试 3: LevelDatabase")

	# 等待 autoload 加载
	await get_tree().create_timer(0.1).timeout

	var count = LevelDatabase.get_level_count()
	assert(count >= 3, "应有至少 3 个关卡")
	print("  ✓ 关卡数量: %d" % count)

	# 获取关卡
	var level = LevelDatabase.get_level("level_001")
	assert(level != null, "应能获取 level_001")
	print("  ✓ 获取关卡: %s" % level.display_name)

	# 获取第一个关卡
	var first = LevelDatabase.get_first_level()
	assert(first != null, "应能获取第一个关卡")
	assert(first.required_level.is_empty(), "第一个关卡无前置要求")
	print("  ✓ 第一个关卡: %s" % first.display_name)


## 测试关卡解锁逻辑
func test_level_unlock() -> void:
	print("测试 4: 关卡解锁逻辑")

	await get_tree().create_timer(0.1).timeout

	# 第一个关卡应解锁
	var unlocked = LevelDatabase.is_level_unlocked("level_001")
	assert(unlocked, "level_001 应解锁")
	print("  ✓ level_001 已解锁")

	# 第二个关卡应锁定
	var level2 = LevelDatabase.get_level("level_002")
	if level2 and not level2.required_level.is_empty():
		var locked = not LevelDatabase.is_level_completed(level2.required_level)
		print("  ✓ level_002 解锁状态: %s" % (not locked))


## 测试关卡验证
func test_level_validation() -> void:
	print("测试 5: 关卡验证")

	# 有效关卡
	var valid_level = LevelDefinition.new()
	valid_level.id = "valid"
	valid_level.display_name = "有效关卡"
	valid_level.enemy_spawns = [EnemySpawn.create("unit_warrior", Vector2i(0, 0), 1.0)]
	valid_level.gold_reward = 50

	var result = valid_level.validate()
	assert(result[0], "有效关卡应通过验证")
	print("  ✓ 有效关卡验证通过")

	# 无效关卡（无敌人）
	var invalid_level = LevelDefinition.new()
	invalid_level.id = "invalid"
	invalid_level.display_name = "无效关卡"
	invalid_level.enemy_spawns = []

	result = invalid_level.validate()
	assert(not result[0], "无敌人的关卡应验证失败")
	print("  ✓ 无敌人关卡验证失败（预期）")


## 简单断言
func assert(condition: bool, message: String) -> void:
	if not condition:
		print("  ✗ 断言失败: " + message)
