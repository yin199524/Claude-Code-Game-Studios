# test_target_selector_gut.gd - 目标选择 AI 系统单元测试 (GUT 版本)
# 参考: design/gdd/target-selection-ai.md
# 运行: 在 Godot 编辑器中按 F6 运行，或使用 GUT 命令行

extends GutTest


## 测试基础目标选择 - 选择最近敌人
func test_basic_target_selection() -> void:
	var attacker = _create_test_instance("attacker", Global.ClassType.WARRIOR, Vector2i(0, 0), 3)
	var enemies: Array[UnitInstance] = [
		_create_test_instance("enemy1", Global.ClassType.ARCHER, Vector2i(1, 0), 3),
		_create_test_instance("enemy2", Global.ClassType.MAGE, Vector2i(2, 0), 3),
		_create_test_instance("enemy3", Global.ClassType.KNIGHT, Vector2i(3, 0), 3)
	]

	var target = TargetSelector.select_target(attacker, enemies)

	assert_not_null(target, "应该选择到目标")
	assert_eq(target.definition.id, "enemy1", "应该选择最近的敌人")


## 测试攻击范围过滤 - 近战单位
func test_melee_range_filter() -> void:
	var melee_attacker = _create_test_instance("melee", Global.ClassType.WARRIOR, Vector2i(0, 0), 1)
	var enemies: Array[UnitInstance] = [
		_create_test_instance("near", Global.ClassType.ARCHER, Vector2i(1, 0), 3),
		_create_test_instance("far", Global.ClassType.MAGE, Vector2i(3, 0), 3)
	]

	var target = TargetSelector.select_target(melee_attacker, enemies)

	assert_not_null(target, "应该选择到目标")
	assert_eq(target.definition.id, "near", "近战单位应只能攻击相邻敌人")


## 测试攻击范围过滤 - 远程单位
func test_ranged_can_attack_farther() -> void:
	var ranged_attacker = _create_test_instance("ranged", Global.ClassType.ARCHER, Vector2i(0, 0), 3)
	var enemies: Array[UnitInstance] = [
		_create_test_instance("near", Global.ClassType.ARCHER, Vector2i(1, 0), 3),
		_create_test_instance("far", Global.ClassType.MAGE, Vector2i(3, 0), 3)
	]

	var target = TargetSelector.select_target(ranged_attacker, enemies)

	assert_not_null(target, "应该选择到目标")
	# 应该选择最近的
	assert_eq(target.definition.id, "near", "远程单位应选择最近敌人")


## 测试攻击范围外无目标
func test_no_target_out_of_range() -> void:
	var melee_attacker = _create_test_instance("melee", Global.ClassType.WARRIOR, Vector2i(0, 0), 1)
	var enemies: Array[UnitInstance] = [
		_create_test_instance("far1", Global.ClassType.ARCHER, Vector2i(2, 0), 3),
		_create_test_instance("far2", Global.ClassType.MAGE, Vector2i(3, 0), 3)
	]

	var target = TargetSelector.select_target(melee_attacker, enemies)

	assert_null(target, "攻击范围外应返回 null")


## 测试曼哈顿距离计算
func test_manhattan_distance() -> void:
	assert_eq(TargetSelector.get_manhattan_distance(Vector2i(0, 0), Vector2i(1, 1)), 2, "(0,0)->(1,1) 应为 2")
	assert_eq(TargetSelector.get_manhattan_distance(Vector2i(0, 0), Vector2i(3, 2)), 5, "(0,0)->(3,2) 应为 5")
	assert_eq(TargetSelector.get_manhattan_distance(Vector2i(2, 3), Vector2i(5, 1)), 5, "(2,3)->(5,1) 应为 5")


## 测试欧几里得距离计算
func test_euclidean_distance() -> void:
	assert_almost_eq(TargetSelector.get_euclidean_distance(Vector2i(0, 0), Vector2i(3, 4)), 5.0, 0.01, "(0,0)->(3,4) 应为 5.0")
	assert_almost_eq(TargetSelector.get_euclidean_distance(Vector2i(0, 0), Vector2i(1, 1)), 1.414, 0.01, "(0,0)->(1,1) 应为 √2")


## 测试治疗单位目标选择 - 所有友方满血
func test_healer_no_target_when_all_full() -> void:
	var healer = _create_test_instance("healer", Global.ClassType.HEALER, Vector2i(1, 1), 2)
	var allies: Array[UnitInstance] = [
		healer,
		_create_test_instance("ally1", Global.ClassType.WARRIOR, Vector2i(0, 0), 3),
		_create_test_instance("ally2", Global.ClassType.ARCHER, Vector2i(2, 0), 3)
	]

	var target = TargetSelector.select_heal_target(healer, allies)

	assert_null(target, "所有友方满血时应返回 null")


## 测试治疗单位目标选择 - 选择血量最低
func test_healer_selects_lowest_hp() -> void:
	var healer = _create_test_instance("healer", Global.ClassType.HEALER, Vector2i(1, 1), 2)
	var ally1 = _create_test_instance("ally1", Global.ClassType.WARRIOR, Vector2i(0, 0), 3)
	var ally2 = _create_test_instance("ally2", Global.ClassType.ARCHER, Vector2i(2, 0), 3)

	ally1.current_hp = 50  # 50%
	ally2.current_hp = 30  # 30%

	var allies: Array[UnitInstance] = [healer, ally1, ally2]

	var target = TargetSelector.select_heal_target(healer, allies)

	assert_not_null(target, "应该选择到治疗目标")
	assert_eq(target.definition.id, "ally2", "应选择血量百分比最低的友方")


## 测试目标切换 - 当前目标死亡
func test_switch_when_target_dead() -> void:
	var attacker = _create_test_instance("attacker", Global.ClassType.WARRIOR, Vector2i(0, 0), 2)
	var current_target = _create_test_instance("current", Global.ClassType.ARCHER, Vector2i(1, 0), 3)
	var new_target = _create_test_instance("new", Global.ClassType.MAGE, Vector2i(1, 1), 3)

	attacker.current_target = current_target
	attacker.target_lock_timer = 0.0

	# 当前目标死亡
	current_target.is_alive = false

	var should_switch = TargetSelector.should_switch_target(attacker, new_target)

	assert_true(should_switch, "当前目标死亡时应切换")


## 测试目标切换 - 目标锁定时间内不切换
func test_no_switch_during_lock() -> void:
	var attacker = _create_test_instance("attacker", Global.ClassType.WARRIOR, Vector2i(0, 0), 2)
	var current_target = _create_test_instance("current", Global.ClassType.ARCHER, Vector2i(1, 0), 3)
	var new_target = _create_test_instance("new", Global.ClassType.MAGE, Vector2i(1, 1), 3)

	attacker.current_target = current_target
	attacker.target_lock_timer = 0.5

	var should_switch = TargetSelector.should_switch_target(attacker, new_target)

	assert_false(should_switch, "目标锁定时间内不应切换")


## 测试空敌人列表
func test_empty_enemy_list() -> void:
	var attacker = _create_test_instance("attacker", Global.ClassType.WARRIOR, Vector2i(0, 0), 1)

	var target = TargetSelector.select_target(attacker, [])

	assert_null(target, "空敌人列表应返回 null")


## 测试所有敌人已死亡
func test_all_enemies_dead() -> void:
	var attacker = _create_test_instance("attacker", Global.ClassType.WARRIOR, Vector2i(0, 0), 1)
	var enemies: Array[UnitInstance] = [
		_create_test_instance("dead1", Global.ClassType.ARCHER, Vector2i(1, 0), 3),
		_create_test_instance("dead2", Global.ClassType.MAGE, Vector2i(1, 1), 3)
	]
	enemies[0].is_alive = false
	enemies[1].is_alive = false

	var target = TargetSelector.select_target(attacker, enemies)

	assert_null(target, "所有敌人死亡应返回 null")


## 测试获取最近敌人
func test_get_nearest_enemy() -> void:
	var attacker = _create_test_instance("attacker", Global.ClassType.WARRIOR, Vector2i(0, 0), 1)
	var enemies: Array[UnitInstance] = [
		_create_test_instance("enemy1", Global.ClassType.ARCHER, Vector2i(2, 0), 3),
		_create_test_instance("enemy2", Global.ClassType.MAGE, Vector2i(3, 0), 3)
	]

	var nearest = TargetSelector.get_nearest_enemy(attacker, enemies)

	assert_not_null(nearest, "应该找到最近敌人")
	assert_eq(nearest.definition.id, "enemy1", "应返回最近的敌人")


## 测试获取攻击范围内敌人数量
func test_enemies_in_range_count() -> void:
	var attacker = _create_test_instance("attacker", Global.ClassType.WARRIOR, Vector2i(0, 0), 1)
	var enemies: Array[UnitInstance] = [
		_create_test_instance("in1", Global.ClassType.ARCHER, Vector2i(1, 0), 3),
		_create_test_instance("in2", Global.ClassType.MAGE, Vector2i(0, 1), 3),
		_create_test_instance("out", Global.ClassType.KNIGHT, Vector2i(2, 0), 3)
	]

	var count = TargetSelector.get_enemies_in_range(attacker, enemies)

	assert_eq(count, 2, "攻击范围内应有 2 个敌人")


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
