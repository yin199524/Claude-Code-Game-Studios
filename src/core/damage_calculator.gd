# DamageCalculator.gd - 伤害计算系统
# 计算战斗中单位之间的伤害输出
# 参考: design/gdd/damage-calculation.md, design/gdd/counter-system.md

class_name DamageCalculator
extends RefCounted

## 常量定义
## 参考: design/gdd/damage-calculation.md - 常量定义表

## 护甲百分比减伤缩放常数
const ARMOR_SCALING_CONSTANT: float = 100.0

## 护甲固定减伤比例
const ARMOR_FLAT_RATIO: float = 0.2

## 随机波动范围
const RANDOM_RANGE_MIN: float = 0.9
const RANDOM_RANGE_MAX: float = 1.1

## 最小伤害
const MIN_DAMAGE: int = 1


## 伤害计算结果
class DamageResult:
	var final_damage: int = 0
	var base_damage: float = 0.0
	var armor_reduction: float = 0.0
	var counter_multiplier: float = 1.0
	var random_factor: float = 1.0
	var counter_status: int = 0  ## 1=克制, -1=被克制, 0=无克制

	func _init() -> void:
		pass


## 计算伤害
## attacker: 攻击者的单位定义
## defender: 防御者的单位定义
## use_random: 是否应用随机波动（默认true，回放时设为false）
## random_seed: 随机种子（用于回放，可选）
## attacker_level: 攻击者等级（可选，默认0表示不应用等级加成）
## defender_level: 防御者等级（可选，默认0表示不应用等级加成）
## 返回: DamageResult 对象
static func calculate(attacker: UnitDefinition, defender: UnitDefinition, use_random: bool = true, random_seed: int = -1, attacker_level: int = 0, defender_level: int = 0) -> DamageResult:
	var result = DamageResult.new()

	# 1. 计算基础伤害（应用稀有度加成和等级加成）
	if attacker_level > 0:
		result.base_damage = float(attacker.get_attack_at_level(attacker_level))
	else:
		result.base_damage = float(attacker.get_effective_attack())

	# 2. 获取防御者护甲（应用等级加成）
	var defender_armor: float
	if defender_level > 0:
		defender_armor = float(defender.get_armor_at_level(defender_level))
	else:
		defender_armor = float(defender.get_effective_armor())

	# 3. 计算护甲减伤
	# 百分比减伤: armor / (armor + ARMOR_SCALING_CONSTANT)
	var armor_percent_reduction: float = defender_armor / (defender_armor + ARMOR_SCALING_CONSTANT)
	# 固定减伤: armor × ARMOR_FLAT_RATIO
	var armor_flat_reduction: float = defender_armor * ARMOR_FLAT_RATIO
	# 总减伤
	result.armor_reduction = armor_percent_reduction + armor_flat_reduction / result.base_damage if result.base_damage > 0 else 0.0

	# 4. 应用护甲减伤后的伤害
	var pre_random_damage: float = result.base_damage * (1.0 - armor_percent_reduction) - armor_flat_reduction

	# 5. 检查克制关系（使用 Global 中的克制系统）
	result.counter_status = Global.get_counter_status(attacker.class_type, defender.class_type)
	result.counter_multiplier = Global.get_counter_multiplier(attacker.class_type, defender.class_type)

	# 6. 应用克制加成
	var pre_random_total: float = pre_random_damage * result.counter_multiplier

	# 7. 应用随机波动
	if use_random:
		if random_seed >= 0:
			var rng = RandomNumberGenerator.new()
			rng.seed = random_seed
			result.random_factor = rng.randf_range(RANDOM_RANGE_MIN, RANDOM_RANGE_MAX)
		else:
			result.random_factor = randf_range(RANDOM_RANGE_MIN, RANDOM_RANGE_MAX)
	else:
		result.random_factor = 1.0

	# 8. 计算最终伤害（最小为1）
	var final_raw: float = pre_random_total * result.random_factor
	result.final_damage = maxi(floori(final_raw), MIN_DAMAGE)

	return result


## 快速计算伤害（仅返回最终伤害值）
static func calculate_damage(attacker: UnitDefinition, defender: UnitDefinition, use_random: bool = true) -> int:
	var result = calculate(attacker, defender, use_random)
	return result.final_damage


## 从 UnitInstance 计算伤害（自动应用等级）
## attacker: 攻击者单位实例
## defender: 防御者单位实例
## use_random: 是否应用随机波动
## 返回: DamageResult 对象
static func calculate_from_instances(attacker: UnitInstance, defender: UnitInstance, use_random: bool = true) -> DamageResult:
	return calculate(attacker.definition, defender.definition, use_random, -1, attacker.level, defender.level)


## 检查是否存在克制关系
## attacker_class: 攻击者职业
## defender_class: 防御者职业
## 返回: 1=克制, -1=被克制, 0=无克制
static func get_counter_status(attacker_class: Global.ClassType, defender_class: Global.ClassType) -> int:
	return Global.get_counter_status(attacker_class, defender_class)


## 检查攻击方是否克制防守方
static func has_counter(attacker_class: Global.ClassType, defender_class: Global.ClassType) -> bool:
	return Global.get_counter_status(attacker_class, defender_class) == 1


## 计算护甲减伤百分比
## armor: 护甲值
## 返回: 减伤百分比（0-1）
static func get_armor_reduction_percent(armor: int) -> float:
	return float(armor) / (float(armor) + ARMOR_SCALING_CONSTANT)


## 获取伤害预览（不含随机波动，用于UI显示）
## 返回: [最小伤害, 最大伤害, 平均伤害]
static func get_damage_preview(attacker: UnitDefinition, defender: UnitDefinition) -> Array[int]:
	var base: float = float(attacker.get_effective_attack())
	var armor: float = float(defender.get_effective_armor())

	var armor_percent: float = armor / (armor + ARMOR_SCALING_CONSTANT)
	var armor_flat: float = armor * ARMOR_FLAT_RATIO

	var pre_random: float = base * (1.0 - armor_percent) - armor_flat
	var counter_mult: float = Global.get_counter_multiplier(attacker.class_type, defender.class_type)

	var after_counter: float = pre_random * counter_mult

	var min_damage: int = maxi(floori(after_counter * RANDOM_RANGE_MIN), MIN_DAMAGE)
	var max_damage: int = maxi(floori(after_counter * RANDOM_RANGE_MAX), MIN_DAMAGE)
	var avg_damage: int = maxi(floori(after_counter), MIN_DAMAGE)

	return [min_damage, max_damage, avg_damage]
