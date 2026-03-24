# UnitInstance.gd - 战斗中的单位实例
# 包含单位定义引用和运行时状态
# 参考: design/gdd/unit-data-definition.md

class_name UnitInstance
extends RefCounted

## 单位定义引用
var definition: UnitDefinition

## 单位等级 (1-10)
var level: int = 1

## 当前生命值
var current_hp: int

## 协同加成（战斗开始时计算）
var synergy_bonuses: Dictionary = {}

## 网格位置
var grid_position: Vector2i

## 所属阵营（true = 玩家方，false = 敌方）
var is_player_unit: bool = true

## 当前目标
var current_target: UnitInstance = null

## 是否存活
var is_alive: bool = true

## 攻击冷却计时
var attack_cooldown: float = 0.0

## 目标锁定时间
var target_lock_timer: float = 0.0


## 从单位定义创建实例
## unit_def: 单位定义
## position: 网格位置
## player_unit: 是否为玩家单位
## unit_level: 单位等级 (默认 1)
static func create(unit_def: UnitDefinition, position: Vector2i, player_unit: bool = true, unit_level: int = 1) -> UnitInstance:
	var instance = UnitInstance.new()
	instance.definition = unit_def
	instance.level = clampi(unit_level, 1, Global.MAX_UNIT_LEVEL)
	instance.current_hp = unit_def.get_hp_at_level(instance.level)
	instance.grid_position = position
	instance.is_player_unit = player_unit
	instance.attack_cooldown = 0.0
	return instance


## 获取攻击范围
func get_attack_range() -> int:
	return definition.attack_range


## 获取攻击速度
func get_attack_speed() -> float:
	return definition.attack_speed


## 获取攻击间隔
func get_attack_interval() -> float:
	return definition.get_attack_interval()


## 获取移动速度
func get_move_speed() -> float:
	return definition.move_speed


## 获取职业类型
func get_class_type() -> Global.ClassType:
	return definition.class_type


## 获取最大生命值（应用等级和协同加成）
func get_max_hp() -> int:
	var base_hp = definition.get_hp_at_level(level)
	var hp_bonus = synergy_bonuses.get("hp", 0.0)
	return int(base_hp * (1.0 + hp_bonus))


## 获取当前生命值百分比
func get_hp_percent() -> float:
	if get_max_hp() <= 0:
		return 0.0
	return float(current_hp) / float(get_max_hp())


## 受到伤害
## 返回: 实际受到的伤害
func take_damage(amount: int) -> int:
	var actual_damage = mini(amount, current_hp)
	current_hp -= actual_damage
	if current_hp <= 0:
		current_hp = 0
		is_alive = false
	return actual_damage


## 治疗
## 返回: 实际治疗量
func heal(amount: int) -> int:
	var max_hp = get_max_hp()
	var actual_heal = mini(amount, max_hp - current_hp)
	current_hp += actual_heal
	return actual_heal


## 重置攻击冷却
func reset_attack_cooldown() -> void:
	attack_cooldown = get_attack_interval()


## 更新攻击冷却
func update_cooldown(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)


## 检查是否可以攻击
func can_attack() -> bool:
	return is_alive and attack_cooldown <= 0.0 and current_target != null


## 获取单位信息字符串
func get_info_string() -> String:
	return "%s Lv.%d HP:%d/%d 位置:%s" % [
		definition.display_name,
		level,
		current_hp,
		get_max_hp(),
		grid_position
	]


## 设置协同加成
func set_synergy_bonuses(bonuses: Dictionary) -> void:
	synergy_bonuses = bonuses
	# 应用 HP 加成时需要更新当前 HP 比例
	if bonuses.has("hp") and bonuses["hp"] > 0:
		var old_max = get_max_hp()
		var hp_ratio = float(current_hp) / float(old_max) if old_max > 0 else 1.0
		# HP 加成会影响基础 HP，在 get_max_hp 中应用
		current_hp = int(get_max_hp() * hp_ratio)


## 获取协同加成后的攻击力
func get_synergy_attack() -> int:
	var base_attack = definition.get_attack_at_level(level)
	var bonus = synergy_bonuses.get("attack", 0.0)
	return int(base_attack * (1.0 + bonus))


## 获取协同加成后的护甲
func get_synergy_armor() -> int:
	var base_armor = definition.get_armor_at_level(level)
	var bonus = synergy_bonuses.get("defense", 0.0)
	return int(base_armor * (1.0 + bonus))


## 获取协同伤害加成
func get_synergy_damage_bonus() -> float:
	return synergy_bonuses.get("damage", 0.0)


## 获取协同治疗加成
func get_synergy_heal_bonus() -> float:
	return synergy_bonuses.get("heal", 0.0)


## 获取协同 HP 加成
func get_synergy_hp_bonus() -> float:
	return synergy_bonuses.get("hp", 0.0)
