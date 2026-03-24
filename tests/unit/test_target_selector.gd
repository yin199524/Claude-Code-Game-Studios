# test_target_selector.gd - 目标选择 AI 系统单元测试
# 参考: design/gdd/target-selection-ai.md
# 运行: godot --headless --script res://tests/unit/test_target_selector.gd

extends SceneTree

func _init() -> void:
	print("=== 目标选择 AI 系统测试 ===")
	print("")

	# 测试 1: 基础目标选择
	test_basic_target_selection()

	# 测试 2: 攻击范围过滤
	test_attack_range_filter()

	# 测试 3: 距离计算
	test_distance_calculation()

	# 测试 4: 治疗单位目标选择
	test_healer_target_selection()

	# 测试 5: 目标切换
	test_target_switch()

	# 测试 6: 边界情况
	test_edge_cases()

	print("")
	print("=== 测试完成 ===")
	quit()


## 测试基础目标选择
func test_basic_target_selection() -> void:
	print("测试 1: 基础目标选择")

	var attacker = _create_test_instance("attacker", Global.ClassType.WARRIOR, Vector2i(0, 0), 3)
	var enemies: Array[UnitInstance] = [
		_create_test_instance("enemy1", Global.ClassType.ARCHER, Vector2i(1, 0), 3),
		_create_test_instance("enemy2", Global.ClassType.MAGE, Vector2i(2, 0), 3),
		_create_test_instance("enemy3", Global.ClassType.KNIGHT, Vector2i(3, 0), 3)
	]

	var target = TargetSelector.select_target(attacker, enemies)
	assert(target != null, "应该选择到目标")
	assert(target.definition.id == "enemy1", "应该选择最近的敌人 enemy1")
	print("  ✓ 正确选择最近的敌人: %s (位置: %s)" % [target.definition.id, target.grid_position])


## 测试攻击范围过滤
func test_attack_range_filter() -> void:
	print("测试 2: 攻击范围过滤")

	# 攻击范围 1 的近战单位
	var melee_attacker = _create_test_instance("melee", Global.ClassType.WARRIOR, Vector2i(0, 0), 1)
	var enemies: Array[UnitInstance] = [
		_create_test_instance("near", Global.ClassType.ARCHER, Vector2i(1, 0), 3),
		_create_test_instance("far", Global.ClassType.MAGE, Vector2i(3, 0), 3)
	]

	var target = TargetSelector.select_target(melee_attacker, enemies)
	assert(target != null, "应该选择到目标")
	assert(target.definition.id == "near", "近战单位应该只能攻击相邻的敌人")
	print("  ✓ 近战单位(范围1)选择范围内敌人: %s" % target.definition.id)

	# 攻击范围 3 的远程单位
	var ranged_attacker = _create_test_instance("ranged", Global.ClassType.ARCHER, Vector2i(0, 0), 3)
	target = TargetSelector.select_target(ranged_attacker, enemies)
	assert(target != null, "应该选择到目标")
	print("  ✓ 远程单位(范围3)可以攻击更远的敌人: %s" % target.definition.id)

	# 攻击范围外无目标
	var out_of_range_enemies: Array[UnitInstance] = [
		_create_test_instance("far1", Global.ClassType.ARCHER, Vector2i(2, 0), 3),
		_create_test_instance("far2", Global.ClassType.MAGE, Vector2i(3, 0), 3)
	]
	target = TargetSelector.select_target(melee_attacker, out_of_range_enemies)
	assert(target == null, "攻击范围外应该返回 null")
	print("  ✓ 攻击范围外无目标")


## 测试距离计算
func test_distance_calculation() -> void:
	print("测试 3: 距离计算")

	# 曼哈顿距离
	var d1 = TargetSelector.get_manhattan_distance(Vector2i(0, 0), Vector2i(1, 1))
	assert(d1 == 2, "曼哈顿距离 (0,0) 到 (1,1) 应为 2")
	print("  ✓ 曼哈顿距离 (0,0)->(1,1): %d" % d1)

	var d2 = TargetSelector.get_manhattan_distance(Vector2i(0, 0), Vector2i(3, 2))
	assert(d2 == 5, "曼哈顿距离 (0,0) 到 (3,2) 应为 5")
	print("  ✓ 曼哈顿距离 (0,0)->(3,2): %d" % d2)

	# 欧几里得距离
	var d3 = TargetSelector.get_euclidean_distance(Vector2i(0, 0), Vector2i(3, 4))
	assert(absf(d3 - 5.0) < 0.01, "欧几里得距离 (0,0) 到 (3,4) 应为 5.0")
	print("  ✓ 欧几里得距离 (0,0)->(3,4): %.2f" % d3)


## 测试治疗单位目标选择
func test_healer_target_selection() -> void:
	print("测试 4: 治疗单位目标选择")

	var healer = _create_test_instance("healer", Global.ClassType.HEALER, Vector2i(1, 1), 2)

	# 创建友方单位（包括自己）
	var allies: Array[UnitInstance] = [
		healer,
		_create_test_instance("ally1", Global.ClassType.WARRIOR, Vector2i(0, 0), 3),
		_create_test_instance("ally2", Global.ClassType.ARCHER, Vector2i(2, 0), 3)
	]

	# 所有友方满血
	var target = TargetSelector.select_heal_target(healer, allies)
	assert(target == null, "所有友方满血时应返回 null")
	print("  ✓ 所有友方满血时无目标")

	# 一个友方受伤
	allies[1].current_hp = 50  # 50%
	allies[2].current_hp = 30  # 30%

	target = TargetSelector.select_heal_target(healer, allies)
	assert(target != null, "应该选择到治疗目标")
	assert(target.definition.id == "ally2", "应该选择血量百分比最低的友方")
	print("  ✓ 选择血量百分比最低的友方: %s (HP: %d/%d = %.0f%%)" % [
		target.definition.id,
		target.current_hp,
		target.get_max_hp(),
		target.get_hp_percent() * 100
	])


## 测试目标切换
func test_target_switch() -> void:
	print("测试 5: 目标切换")

	var attacker = _create_test_instance("attacker", Global.ClassType.WARRIOR, Vector2i(0, 0), 2)
	var current_target = _create_test_instance("current", Global.ClassType.ARCHER, Vector2i(1, 0), 3)
	var new_target = _create_test_instance("new", Global.ClassType.MAGE, Vector2i(1, 1), 3)

	attacker.current_target = current_target
	attacker.target_lock_timer = 0.0

	# 当前目标存活且在范围内，新目标距离相同
	var should_switch = TargetSelector.should_switch_target(attacker, new_target)
	assert(not should_switch, "目标距离相同，不应切换")
	print("  ✓ 目标距离相同时不切换")

	# 当前目标死亡
	current_target.is_alive = false
	should_switch = TargetSelector.should_switch_target(attacker, new_target)
	assert(should_switch, "当前目标死亡时应切换")
	print("  ✓ 当前目标死亡时切换")
	current_target.is_alive = true

	# 目标锁定时间内
	attacker.target_lock_timer = 0.5
	should_switch = TargetSelector.should_switch_target(attacker, new_target)
	assert(not should_switch, "目标锁定时间内不应切换")
	print("  ✓ 目标锁定时间内不切换")


## 测试边界情况
func test_edge_cases() -> void:
	print("测试 6: 边界情况")

	var attacker = _create_test_instance("attacker", Global.ClassType.WARRIOR, Vector2i(0, 0), 1)

	# 空敌人列表
	var target = TargetSelector.select_target(attacker, [])
	assert(target == null, "空敌人列表应返回 null")
	print("  ✓ 空敌人列表返回 null")

	# 所有敌人已死亡
	var enemies: Array[UnitInstance] = [
		_create_test_instance("dead1", Global.ClassType.ARCHER, Vector2i(1, 0), 3),
		_create_test_instance("dead2", Global.ClassType.MAGE, Vector2i(1, 1), 3)
	]
	enemies[0].is_alive = false
	enemies[1].is_alive = false

	target = TargetSelector.select_target(attacker, enemies)
	assert(target == null, "所有敌人死亡应返回 null")
	print("  ✓ 所有敌人死亡返回 null")

	# 多个等距目标
	enemies[0].is_alive = true
	enemies[1].is_alive = true
	enemies[0].grid_position = Vector2i(1, 0)
	enemies[1].grid_position = Vector2i(0, 1)  # 距离相同

	target = TargetSelector.select_target(attacker, enemies)
	assert(target != null, "应该选择到目标")
	print("  ✓ 多个等距目标选择第一个: %s" % target.definition.id)

	# 获取最近敌人
	var nearest = TargetSelector.get_nearest_enemy(attacker, enemies)
	assert(nearest != null, "应该找到最近敌人")
	print("  ✓ 获取最近敌人: %s" % nearest.definition.id)

	# 敌人数量在范围内
	var count = TargetSelector.get_enemies_in_range(attacker, enemies)
	assert(count == 2, "攻击范围内应该有 2 个敌人")
	print("  ✓ 攻击范围内敌人数量: %d" % count)


## 创建测试单位定义
func _create_test_definition(id: String, class_type: Global.ClassType) -> UnitDefinition:
	var unit = UnitDefinition.new()
	unit.id = id
	unit.display_name = id
	unit.class_type = class_type
	unit.rarity = Global.Rarity.COMMON
	unit.hp = 100
	unit.attack = 20
	unit.armor = 0
	unit.attack_speed = 1.0
	unit.attack_range = 1
	unit.move_speed = 1.0
	unit.base_price = 50
	return unit


## 创建测试单位实例
func _create_test_instance(id: String, class_type: Global.ClassType, position: Vector2i, attack_range: int) -> UnitInstance:
	var def = _create_test_definition(id, class_type)
	def.attack_range = attack_range
	var instance = UnitInstance.create(def, position, true)
	return instance


## 简单断言
func assert(condition: bool, message: String) -> void:
	if not condition:
		print("  ✗ 断言失败: " + message)
