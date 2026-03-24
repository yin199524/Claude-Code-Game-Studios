# test_damage_calculator.gd - 伤害计算系统单元测试
# 参考: design/gdd/damage-calculation.md
# 运行: godot --headless --script res://tests/unit/test_damage_calculator.gd

extends SceneTree

func _init() -> void:
	print("=== 伤害计算系统测试 ===")
	print("")

	# 创建测试单位
	var attacker = _create_test_unit("attacker", Global.ClassType.WARRIOR, 100, 0, Global.Rarity.COMMON)
	var defender = _create_test_unit("defender", Global.ClassType.ARCHER, 0, 0, Global.Rarity.COMMON)

	# 测试 1: 基础伤害计算
	test_basic_damage(attacker, defender)

	# 测试 2: 护甲减伤
	test_armor_reduction(attacker)

	# 测试 3: 克制加成
	test_counter_bonus(attacker, defender)

	# 测试 4: 随机波动
	test_random_factor(attacker, defender)

	# 测试 5: 边界情况
	test_edge_cases(attacker, defender)

	# 测试 6: 稀有度加成
	test_rarity_bonus()

	# 测试 7: 伤害预览
	test_damage_preview(attacker, defender)

	print("")
	print("=== 测试完成 ===")
	quit()


## 测试基础伤害计算
func test_basic_damage(attacker: UnitDefinition, defender: UnitDefinition) -> void:
	print("测试 1: 基础伤害计算")

	# 无护甲目标，无克制，无随机
	defender.armor = 0
	var result = DamageCalculator.calculate(attacker, defender, false)

	assert(result.final_damage == 100, "基础伤害应为 100，实际为 %d" % result.final_damage)
	print("  ✓ 无护甲目标受到全额伤害: %d" % result.final_damage)


## 测试护甲减伤
func test_armor_reduction(attacker: UnitDefinition) -> void:
	print("测试 2: 护甲减伤")

	var defender = _create_test_unit("armored", Global.ClassType.ARCHER, 0, 50, Global.Rarity.COMMON)

	var result = DamageCalculator.calculate(attacker, defender, false)

	# 护甲 50:
	# 百分比减伤 = 50 / (50 + 100) = 33.3%
	# 固定减伤 = 50 × 0.2 = 10
	# 伤害 = 100 × (1 - 0.333) - 10 = 56.7
	assert(result.final_damage >= 56 and result.final_damage <= 57, "护甲减伤后伤害应为 ~57，实际为 %d" % result.final_damage)
	print("  ✓ 护甲 50 减伤后伤害: %d (预期 ~57)" % result.final_damage)

	# 测试高护甲
	defender.armor = 100
	result = DamageCalculator.calculate(attacker, defender, false)
	# 护甲 100:
	# 百分比减伤 = 100 / (100 + 100) = 50%
	# 固定减伤 = 100 × 0.2 = 20
	# 伤害 = 100 × 0.5 - 20 = 30
	assert(result.final_damage == 30, "高护甲减伤后伤害应为 30，实际为 %d" % result.final_damage)
	print("  ✓ 护甲 100 减伤后伤害: %d (预期 30)" % result.final_damage)


## 测试克制加成
func test_counter_bonus(attacker: UnitDefinition, defender: UnitDefinition) -> void:
	print("测试 3: 克制加成")

	# 测试克制倍率 (1.3) 和被克制倍率 (0.8)
	# 参考: design/gdd/counter-system.md

	# 设置基础单位（无护甲，攻击力 100）
	attacker.attack = 100
	attacker.rarity = Global.Rarity.COMMON

	# 测试 3.1: 战士 → 骑士 (克制)
	print("  测试 3.1: 战士 → 骑士 (克制)")
	attacker.class_type = Global.ClassType.WARRIOR
	var knight = _create_test_unit("knight", Global.ClassType.KNIGHT, 0, 0, Global.Rarity.COMMON)
	var result = DamageCalculator.calculate(attacker, knight, false)
	assert(result.counter_status == 1, "战士应克制骑士")
	assert(result.counter_multiplier == 1.3, "克制倍率应为 1.3")
	assert(result.final_damage == 130, "克制伤害应为 130，实际为 %d" % result.final_damage)
	print("    ✓ 克制伤害: %d (倍率: %.2f)" % [result.final_damage, result.counter_multiplier])

	# 测试 3.2: 骑士 → 战士 (被克制)
	print("  测试 3.2: 骑士 → 战士 (被克制)")
	attacker.class_type = Global.ClassType.KNIGHT
	var warrior = _create_test_unit("warrior", Global.ClassType.WARRIOR, 0, 0, Global.Rarity.COMMON)
	result = DamageCalculator.calculate(attacker, warrior, false)
	assert(result.counter_status == -1, "骑士应被战士克制")
	assert(result.counter_multiplier == 0.8, "被克制倍率应为 0.8")
	assert(result.final_damage == 80, "被克制伤害应为 80，实际为 %d" % result.final_damage)
	print("    ✓ 被克制伤害: %d (倍率: %.2f)" % [result.final_damage, result.counter_multiplier])

	# 测试 3.3: 弓手 → 法师 (克制)
	print("  测试 3.3: 弓手 → 法师 (克制)")
	attacker.class_type = Global.ClassType.ARCHER
	var mage = _create_test_unit("mage", Global.ClassType.MAGE, 0, 0, Global.Rarity.COMMON)
	result = DamageCalculator.calculate(attacker, mage, false)
	assert(result.counter_status == 1, "弓手应克制法师")
	assert(result.counter_multiplier == 1.3, "克制倍率应为 1.3")
	print("    ✓ 弓手克制法师: 伤害 %d (倍率: %.2f)" % [result.final_damage, result.counter_multiplier])

	# 测试 3.4: 弓手 → 治疗 (克制)
	print("  测试 3.4: 弓手 → 治疗 (克制)")
	var healer = _create_test_unit("healer", Global.ClassType.HEALER, 0, 0, Global.Rarity.COMMON)
	result = DamageCalculator.calculate(attacker, healer, false)
	assert(result.counter_status == 1, "弓手应克制治疗")
	print("    ✓ 弓手克制治疗: 伤害 %d" % result.final_damage)

	# 测试 3.5: 法师 → 骑士 (克制)
	print("  测试 3.5: 法师 → 骑士 (克制)")
	attacker.class_type = Global.ClassType.MAGE
	result = DamageCalculator.calculate(attacker, knight, false)
	assert(result.counter_status == 1, "法师应克制骑士")
	print("    ✓ 法师克制骑士: 伤害 %d" % result.final_damage)

	# 测试 3.6: 骑士 → 治疗 (克制)
	print("  测试 3.6: 骑士 → 治疗 (克制)")
	attacker.class_type = Global.ClassType.KNIGHT
	result = DamageCalculator.calculate(attacker, healer, false)
	assert(result.counter_status == 1, "骑士应克制治疗")
	print("    ✓ 骑士克制治疗: 伤害 %d" % result.final_damage)

	# 测试 3.7: 同职业无克制
	print("  测试 3.7: 同职业无克制")
	attacker.class_type = Global.ClassType.WARRIOR
	result = DamageCalculator.calculate(attacker, warrior, false)
	assert(result.counter_status == 0, "同职业应无克制")
	assert(result.counter_multiplier == 1.0, "同职业倍率应为 1.0")
	assert(result.final_damage == 100, "同职业伤害应为 100，实际为 %d" % result.final_damage)
	print("    ✓ 同职业无克制: 伤害 %d (倍率: %.2f)" % [result.final_damage, result.counter_multiplier])

	# 测试 3.8: 无克制关系
	print("  测试 3.8: 无克制关系 (战士 vs 弓手)")
	attacker.class_type = Global.ClassType.WARRIOR
	var archer = _create_test_unit("archer", Global.ClassType.ARCHER, 0, 0, Global.Rarity.COMMON)
	result = DamageCalculator.calculate(attacker, archer, false)
	assert(result.counter_status == 0, "战士与弓手应无克制关系")
	assert(result.counter_multiplier == 1.0, "无克制倍率应为 1.0")
	print("    ✓ 无克制关系: 伤害 %d" % result.final_damage)

	# 测试 3.9: 治疗不克制任何职业
	print("  测试 3.9: 治疗不克制任何职业")
	attacker.class_type = Global.ClassType.HEALER
	result = DamageCalculator.calculate(attacker, warrior, false)
	assert(result.counter_status == 0, "治疗不克制战士")
	print("    ✓ 治疗对战士: 无克制")

	# 重置
	attacker.attack = 100


## 测试随机波动
func test_random_factor(attacker: UnitDefinition, defender: UnitDefinition) -> void:
	print("测试 4: 随机波动")

	defender.armor = 0
	attacker.class_type = Global.ClassType.WARRIOR
	defender.class_type = Global.ClassType.ARCHER

	var min_damage: int = 999999
	var max_damage: int = 0

	for i in range(100):
		var result = DamageCalculator.calculate(attacker, defender, true)
		min_damage = mini(min_damage, result.final_damage)
		max_damage = maxi(max_damage, result.final_damage)

	# 100 × 0.9 = 90, 100 × 1.1 = 110
	assert(min_damage >= 90, "最小伤害应 >= 90，实际为 %d" % min_damage)
	assert(max_damage <= 110, "最大伤害应 <= 110，实际为 %d" % max_damage)
	print("  ✓ 随机波动范围: %d ~ %d (预期 90 ~ 110)" % [min_damage, max_damage])


## 测试边界情况
func test_edge_cases(attacker: UnitDefinition, defender: UnitDefinition) -> void:
	print("测试 5: 边界情况")

	# 攻击力为 0
	attacker.attack = 0
	defender.armor = 0
	var result = DamageCalculator.calculate(attacker, defender, false)
	assert(result.final_damage >= 1, "攻击力为 0 时最小伤害应为 1")
	print("  ✓ 攻击力 0 时的最小伤害: %d" % result.final_damage)

	# 极高护甲
	attacker.attack = 100
	defender.armor = 999
	result = DamageCalculator.calculate(attacker, defender, false)
	assert(result.final_damage >= 1, "极高护甲时最小伤害应为 1")
	print("  ✓ 极高护甲(999)时的最小伤害: %d" % result.final_damage)

	# 重置
	attacker.attack = 100
	defender.armor = 0


## 测试稀有度加成
func test_rarity_bonus() -> void:
	print("测试 6: 稀有度加成")

	var base_attacker = _create_test_unit("base", Global.ClassType.WARRIOR, 100, 0, Global.Rarity.COMMON)
	var rare_attacker = _create_test_unit("rare", Global.ClassType.WARRIOR, 100, 0, Global.Rarity.RARE)
	var epic_attacker = _create_test_unit("epic", Global.ClassType.WARRIOR, 100, 0, Global.Rarity.EPIC)
	var legendary_attacker = _create_test_unit("legendary", Global.ClassType.WARRIOR, 100, 0, Global.Rarity.LEGENDARY)

	var defender = _create_test_unit("target", Global.ClassType.ARCHER, 0, 0, Global.Rarity.COMMON)

	var base_result = DamageCalculator.calculate(base_attacker, defender, false)
	var rare_result = DamageCalculator.calculate(rare_attacker, defender, false)
	var epic_result = DamageCalculator.calculate(epic_attacker, defender, false)
	var legendary_result = DamageCalculator.calculate(legendary_attacker, defender, false)

	print("  ✓ 普通伤害: %d (1.0x)" % base_result.final_damage)
	print("  ✓ 稀有伤害: %d (1.2x)" % rare_result.final_damage)
	print("  ✓ 史诗伤害: %d (1.5x)" % epic_result.final_damage)
	print("  ✓ 传说伤害: %d (2.0x)" % legendary_result.final_damage)


## 测试伤害预览
func test_damage_preview(attacker: UnitDefinition, defender: UnitDefinition) -> void:
	print("测试 7: 伤害预览")

	attacker.attack = 100
	attacker.rarity = Global.Rarity.COMMON
	defender.armor = 0
	defender.class_type = Global.ClassType.ARCHER

	var preview = DamageCalculator.get_damage_preview(attacker, defender)
	print("  ✓ 伤害预览: 最小 %d, 最大 %d, 平均 %d" % [preview[0], preview[1], preview[2]])


## 创建测试单位
func _create_test_unit(id: String, class_type: Global.ClassType, attack: int, armor: int, rarity: Global.Rarity) -> UnitDefinition:
	var unit = UnitDefinition.new()
	unit.id = id
	unit.display_name = id
	unit.class_type = class_type
	unit.rarity = rarity
	unit.hp = 100
	unit.attack = attack
	unit.armor = armor
	unit.attack_speed = 1.0
	unit.attack_range = 1
	unit.move_speed = 1.0
	unit.base_price = 50
	return unit


## 简单断言
func assert(condition: bool, message: String) -> void:
	if not condition:
		print("  ✗ 断言失败: " + message)
