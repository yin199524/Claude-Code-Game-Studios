# test_damage_calculator_gut.gd - 伤害计算系统单元测试 (GUT 版本)
# 参考: design/gdd/damage-calculation.md
# 运行: 在 Godot 编辑器中按 F6 运行，或使用 GUT 命令行

extends GutTest

var attacker: UnitDefinition
var defender: UnitDefinition


func before_each() -> void:
	# 每个测试前创建基础单位
	attacker = _create_test_unit("attacker", Global.ClassType.WARRIOR, 100, 0, Global.Rarity.COMMON)
	defender = _create_test_unit("defender", Global.ClassType.ARCHER, 0, 0, Global.Rarity.COMMON)


func after_each() -> void:
	attacker = null
	defender = null


## 测试基础伤害计算
func test_basic_damage() -> void:
	# 无护甲目标，无克制，无随机
	defender.armor = 0
	var result = DamageCalculator.calculate(attacker, defender, false)

	assert_eq(result.final_damage, 100, "无护甲目标应受到全额伤害 100")


## 测试护甲减伤 - 护甲 50
func test_armor_reduction_50() -> void:
	defender.armor = 50
	var result = DamageCalculator.calculate(attacker, defender, false)

	# 护甲 50: 百分比减伤 33.3%, 固定减伤 10, 伤害 ≈ 57
	assert_between(result.final_damage, 56, 58, "护甲 50 减伤后伤害应约为 57")


## 测试护甲减伤 - 护甲 100
func test_armor_reduction_100() -> void:
	defender.armor = 100
	var result = DamageCalculator.calculate(attacker, defender, false)

	# 护甲 100: 百分比减伤 50%, 固定减伤 20, 伤害 = 30
	assert_eq(result.final_damage, 30, "护甲 100 减伤后伤害应为 30")


## 测试克制加成
func test_counter_bonus() -> void:
	# 战士克制骑士
	var knight = _create_test_unit("knight", Global.ClassType.KNIGHT, 0, 0, Global.Rarity.COMMON)

	# 无克制
	defender.class_type = Global.ClassType.ARCHER
	defender.armor = 0
	var result_no_counter = DamageCalculator.calculate(attacker, defender, false)

	# 有克制
	knight.armor = 0
	var result_counter = DamageCalculator.calculate(attacker, knight, false)

	assert_eq(result_counter.final_damage, int(result_no_counter.final_damage * 1.2), "克制伤害应为 1.2 倍")


## 测试随机波动范围
func test_random_factor_range() -> void:
	defender.armor = 0
	attacker.class_type = Global.ClassType.WARRIOR
	defender.class_type = Global.ClassType.ARCHER

	var min_damage: int = 999999
	var max_damage: int = 0

	for i in range(100):
		var result = DamageCalculator.calculate(attacker, defender, true)
		min_damage = mini(min_damage, result.final_damage)
		max_damage = maxi(max_damage, result.final_damage)

	assert_between(min_damage, 90, 110, "最小伤害应在波动范围内")
	assert_between(max_damage, 90, 110, "最大伤害应在波动范围内")


## 测试攻击力为 0 的边界情况
func test_zero_attack_minimum_damage() -> void:
	attacker.attack = 0
	defender.armor = 0

	var result = DamageCalculator.calculate(attacker, defender, false)

	assert_eq(result.final_damage, 1, "攻击力为 0 时最小伤害应为 1")


## 测试极高护甲的边界情况
func test_extreme_armor_minimum_damage() -> void:
	attacker.attack = 100
	defender.armor = 999

	var result = DamageCalculator.calculate(attacker, defender, false)

	assert_eq(result.final_damage, 1, "极高护甲时最小伤害应为 1")


## 测试稀有度加成
func test_rarity_damage_multiplier() -> void:
	var base_attacker = _create_test_unit("base", Global.ClassType.WARRIOR, 100, 0, Global.Rarity.COMMON)
	var rare_attacker = _create_test_unit("rare", Global.ClassType.WARRIOR, 100, 0, Global.Rarity.RARE)
	var epic_attacker = _create_test_unit("epic", Global.ClassType.WARRIOR, 100, 0, Global.Rarity.EPIC)
	var legendary_attacker = _create_test_unit("legendary", Global.ClassType.WARRIOR, 100, 0, Global.Rarity.LEGENDARY)

	defender.armor = 0

	var base_result = DamageCalculator.calculate(base_attacker, defender, false)
	var rare_result = DamageCalculator.calculate(rare_attacker, defender, false)
	var epic_result = DamageCalculator.calculate(epic_attacker, defender, false)
	var legendary_result = DamageCalculator.calculate(legendary_attacker, defender, false)

	assert_eq(base_result.final_damage, 100, "普通伤害应为 100")
	assert_eq(rare_result.final_damage, 120, "稀有伤害应为 120 (1.2x)")
	assert_eq(epic_result.final_damage, 150, "史诗伤害应为 150 (1.5x)")
	assert_eq(legendary_result.final_damage, 200, "传说伤害应为 200 (2.0x)")


## 测试伤害预览
func test_damage_preview() -> void:
	attacker.attack = 100
	attacker.rarity = Global.Rarity.COMMON
	defender.armor = 0
	defender.class_type = Global.ClassType.ARCHER

	var preview = DamageCalculator.get_damage_preview(attacker, defender)

	assert_eq(preview[0], 90, "最小伤害预览应为 90")
	assert_eq(preview[1], 110, "最大伤害预览应为 110")
	assert_eq(preview[2], 100, "平均伤害预览应为 100")


## 测试护甲减伤百分比计算
func test_armor_reduction_percent() -> void:
	assert_almost_eq(DamageCalculator.get_armor_reduction_percent(0), 0.0, 0.01, "0 护甲减伤应为 0%")
	assert_almost_eq(DamageCalculator.get_armor_reduction_percent(50), 0.333, 0.01, "50 护甲减伤应约为 33.3%")
	assert_almost_eq(DamageCalculator.get_armor_reduction_percent(100), 0.5, 0.01, "100 护甲减伤应为 50%")
	assert_almost_eq(DamageCalculator.get_armor_reduction_percent(200), 0.667, 0.01, "200 护甲减伤应约为 66.7%")


## 创建测试单位定义
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
