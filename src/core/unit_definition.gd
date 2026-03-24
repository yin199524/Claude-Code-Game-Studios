# UnitDefinition.gd - 单位定义 Resource 类
# 定义游戏中所有单位的属性、技能、职业和稀有度
# 参考: design/gdd/unit-data-definition.md

class_name UnitDefinition
extends Resource

## 唯一标识符
@export var id: String = ""

## 显示名称
@export var display_name: String = ""

## 职业类型
@export var class_type: Global.ClassType = Global.ClassType.WARRIOR

## 稀有度
@export var rarity: Global.Rarity = Global.Rarity.COMMON

## 基础生命值
## 范围: 1-9999
@export var hp: int = 100:
	set(value):
		hp = clampi(value, 1, Global.MAX_HP)

## 基础攻击力
## 范围: 0-999
@export var attack: int = 10:
	set(value):
		attack = clampi(value, 0, Global.MAX_ATTACK)

## 攻击速度（次/秒）
## 范围: 0.1-5.0
@export var attack_speed: float = 1.0:
	set(value):
		attack_speed = clampf(value, Global.MIN_ATTACK_SPEED, Global.MAX_ATTACK_SPEED)

## 攻击范围（格子数）
## 范围: 0-10，0表示近战必须贴身
@export var attack_range: int = 1:
	set(value):
		attack_range = clampi(value, 0, Global.MAX_ATTACK_RANGE)

## 护甲（减少伤害）
## 范围: 0-100
@export var armor: int = 0:
	set(value):
		armor = clampi(value, 0, Global.MAX_ARMOR)

## 移动速度（格/秒）
## 范围: 0-5.0，0表示不移动
@export var move_speed: float = 1.0:
	set(value):
		move_speed = clampf(value, 0.0, Global.MAX_MOVE_SPEED)

## 商店基础价格（金币）
@export var base_price: int = 50

## 单位描述
@export_multiline var description: String = ""

## 技能引用（暂时为空，技能系统后续实现）
## @export var skill: SkillDefinition
@export var skill_id: String = ""


## 获取有效生命值（应用稀有度加成）
## 公式: effective_hp = base_hp × RARITY_MULTIPLIER[rarity]
func get_effective_hp() -> int:
	return int(hp * Global.RARITY_MULTIPLIERS[rarity])


## 获取有效攻击力（应用稀有度加成）
## 公式: effective_attack = base_attack × RARITY_MULTIPLIER[rarity]
func get_effective_attack() -> int:
	return int(attack * Global.RARITY_MULTIPLIERS[rarity])


## 获取有效护甲（应用稀有度加成）
## 公式: effective_armor = base_armor × RARITY_MULTIPLIER[rarity]
func get_effective_armor() -> int:
	return int(armor * Global.RARITY_MULTIPLIERS[rarity])


## 获取商店价格（应用稀有度价格倍率）
## 公式: price = base_price × RARITY_PRICE_MULTIPLIER[rarity]
func get_price() -> int:
	return base_price * Global.RARITY_PRICE_MULTIPLIERS[rarity]


## 获取攻击间隔（秒）
## 公式: attack_interval = 1.0 / attack_speed
func get_attack_interval() -> float:
	return 1.0 / attack_speed


## 验证单位定义数据有效性
## 返回: [is_valid: bool, error_message: String]
func validate() -> Array:
	var errors: Array[String] = []

	# 检查必需字段
	if id.is_empty():
		errors.append("单位 ID 不能为空")

	if display_name.is_empty():
		errors.append("单位名称不能为空")

	# 检查属性范围
	if hp < 1:
		errors.append("HP 必须大于 0")

	if attack_speed <= 0:
		errors.append("攻击速度必须大于 0")

	# 检查价格
	if base_price < 0:
		errors.append("价格不能为负数")

	if errors.is_empty():
		return [true, ""]
	else:
		return [false, "\n".join(errors)]


## 获取单位信息摘要（用于调试和日志）
func get_info_string() -> String:
	return "%s [%s] - HP:%d ATK:%d 范围:%d 价格:%d" % [
		display_name,
		Global.get_rarity_name(rarity),
		get_effective_hp(),
		get_effective_attack(),
		attack_range,
		get_price()
	]
