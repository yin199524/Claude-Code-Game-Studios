# SynergyManager.gd - 协同系统管理器
# 检测和应用队伍协同效果
# 参考: design/gdd/synergy-system.md

class_name SynergyManager
extends RefCounted

## 协同效果类型
enum SynergyType {
	CLASS,      ## 职业协同
	FORMATION,  ## 阵型协同
	MIXED       ## 混合协同
}

## 协同效果定义
class SynergyEffect:
	var id: String
	var display_name: String
	var description: String
	var synergy_type: SynergyType
	var bonus_type: String  # "attack", "defense", "damage", "heal", "hp"
	var bonus_value: float
	var condition: Dictionary  # 条件参数

	func _init(data: Dictionary) -> void:
		id = data.get("id", "")
		display_name = data.get("display_name", "")
		description = data.get("description", "")
		synergy_type = data.get("synergy_type", SynergyType.CLASS)
		bonus_type = data.get("bonus_type", "attack")
		bonus_value = data.get("bonus_value", 0.1)
		condition = data.get("condition", {})


## 所有协同定义
var _synergies: Array[SynergyEffect] = []

## 协同激活信号
signal synergies_activated(synergy_ids: Array[String])


func _init() -> void:
	_init_synergies()


## 初始化所有协同定义
func _init_synergies() -> void:
	# === 职业协同 ===
	_synergies.append(SynergyEffect.new({
		"id": "warrior_brothers",
		"display_name": "战士兄弟",
		"description": "战士们并肩作战，气势如虹",
		"synergy_type": SynergyType.CLASS,
		"bonus_type": "attack",
		"bonus_value": 0.1,
		"condition": {"class_type": Global.ClassType.WARRIOR, "count": 2}
	}))

	_synergies.append(SynergyEffect.new({
		"id": "magic_resonance",
		"display_name": "法术共鸣",
		"description": "法力相互增幅，威力大增",
		"synergy_type": SynergyType.CLASS,
		"bonus_type": "damage",
		"bonus_value": 0.15,
		"condition": {"class_type": Global.ClassType.MAGE, "count": 2}
	}))

	_synergies.append(SynergyEffect.new({
		"id": "knight_honor",
		"display_name": "骑士荣耀",
		"description": "骑士誓言守护，坚不可摧",
		"synergy_type": SynergyType.CLASS,
		"bonus_type": "defense",
		"bonus_value": 0.15,
		"condition": {"class_type": Global.ClassType.KNIGHT, "count": 2}
	}))

	_synergies.append(SynergyEffect.new({
		"id": "healing_light",
		"display_name": "治愈之光",
		"description": "双重祝福，生命之泉",
		"synergy_type": SynergyType.CLASS,
		"bonus_type": "heal",
		"bonus_value": 0.2,
		"condition": {"class_type": Global.ClassType.HEALER, "count": 2}
	}))

	_synergies.append(SynergyEffect.new({
		"id": "arrow_storm",
		"display_name": "箭雨风暴",
		"description": "箭如雨下，密不透风",
		"synergy_type": SynergyType.CLASS,
		"bonus_type": "attack_speed",
		"bonus_value": 0.1,
		"condition": {"class_type": Global.ClassType.ARCHER, "count": 2}
	}))

	# === 阵型协同 ===
	_synergies.append(SynergyEffect.new({
		"id": "front_guard",
		"display_name": "前排护卫",
		"description": "前排如墙，守护后方",
		"synergy_type": SynergyType.FORMATION,
		"bonus_type": "defense",
		"bonus_value": 0.2,
		"condition": {"formation": "front_row_melee"}
	}))

	_synergies.append(SynergyEffect.new({
		"id": "back_fire",
		"display_name": "后排输出",
		"description": "后排安全输出，火力全开",
		"synergy_type": SynergyType.FORMATION,
		"bonus_type": "damage",
		"bonus_value": 0.1,
		"condition": {"formation": "back_row_ranged"}
	}))

	# === 混合协同 ===
	_synergies.append(SynergyEffect.new({
		"id": "balance",
		"display_name": "攻守平衡",
		"description": "攻守兼备，持久作战",
		"synergy_type": SynergyType.MIXED,
		"bonus_type": "mixed",
		"bonus_value": 0.0,  # 复杂效果，特殊处理
		"condition": {"classes": [Global.ClassType.WARRIOR, Global.ClassType.HEALER]}
	}))

	_synergies.append(SynergyEffect.new({
		"id": "magic_martial",
		"display_name": "魔武双修",
		"description": "魔法与武力的完美结合",
		"synergy_type": SynergyType.MIXED,
		"bonus_type": "mixed",
		"bonus_value": 0.0,
		"condition": {"classes": [Global.ClassType.WARRIOR, Global.ClassType.MAGE]}
	}))


## 检测并返回激活的协同效果
## units: 玩家单位列表
## grid_layout: 网格布局（用于阵型检测）
## 返回: 激活的协同效果列表
func detect_synergies(units: Array[UnitInstance], grid_layout: GridLayout = null) -> Array[SynergyEffect]:
	var active_synergies: Array[SynergyEffect] = []

	for synergy in _synergies:
		if _check_synergy_condition(synergy, units, grid_layout):
			active_synergies.append(synergy)

	return active_synergies


## 检查单个协同条件是否满足
func _check_synergy_condition(synergy: SynergyEffect, units: Array[UnitInstance], grid_layout: GridLayout) -> bool:
	match synergy.synergy_type:
		SynergyType.CLASS:
			return _check_class_synergy(synergy, units)
		SynergyType.FORMATION:
			return _check_formation_synergy(synergy, units, grid_layout)
		SynergyType.MIXED:
			return _check_mixed_synergy(synergy, units)

	return false


## 检查职业协同
func _check_class_synergy(synergy: SynergyEffect, units: Array[UnitInstance]) -> bool:
	var required_class = synergy.condition.get("class_type")
	var required_count = synergy.condition.get("count", 2)

	var count = 0
	for unit in units:
		if unit.get_class_type() == required_class:
			count += 1

	return count >= required_count


## 检查阵型协同
func _check_formation_synergy(synergy: SynergyEffect, units: Array[UnitInstance], grid_layout: GridLayout) -> bool:
	if grid_layout == null:
		return false

	var formation = synergy.condition.get("formation", "")

	match formation:
		"front_row_melee":
			# 检查前排是否全为近战职业
			var melee_classes = [Global.ClassType.WARRIOR, Global.ClassType.KNIGHT]
			for unit in units:
				var y = unit.grid_position.y
				# 前排定义：y <= grid_layout.player_area_start
				if y <= grid_layout.player_area_start:
					if unit.get_class_type() not in melee_classes:
						return false
			return true

		"back_row_ranged":
			# 检查后排是否全为远程职业
			var ranged_classes = [Global.ClassType.ARCHER, Global.ClassType.MAGE, Global.ClassType.HEALER]
			for unit in units:
				var y = unit.grid_position.y
				# 后排定义：y > grid_layout.player_area_start
				if y > grid_layout.player_area_start:
					if unit.get_class_type() not in ranged_classes:
						return false
			return true

	return false


## 检查混合协同
func _check_mixed_synergy(synergy: SynergyEffect, units: Array[UnitInstance]) -> bool:
	var required_classes: Array = synergy.condition.get("classes", [])
	var found_classes: Dictionary = {}

	for unit in units:
		found_classes[unit.get_class_type()] = true

	for required_class in required_classes:
		if not found_classes.has(required_class):
			return false

	return true


## 计算单位获得的协同加成
## unit: 目标单位
## active_synergies: 激活的协同列表
## 返回: {attack_bonus, defense_bonus, damage_bonus, heal_bonus, hp_bonus}
func calculate_synergy_bonuses(unit: UnitInstance, active_synergies: Array[SynergyEffect]) -> Dictionary:
	var bonuses = {
		"attack": 0.0,
		"defense": 0.0,
		"damage": 0.0,
		"heal": 0.0,
		"hp": 0.0,
		"attack_speed": 0.0
	}

	for synergy in active_synergies:
		if _is_unit_affected_by_synergy(unit, synergy):
			_apply_synergy_bonus(bonuses, synergy, unit)

	return bonuses


## 检查单位是否受协同影响
func _is_unit_affected_by_synergy(unit: UnitInstance, synergy: SynergyEffect) -> bool:
	match synergy.synergy_type:
		SynergyType.CLASS:
			# 只有对应职业受影响
			return unit.get_class_type() == synergy.condition.get("class_type")

		SynergyType.FORMATION:
			# 根据阵型位置判断
			match synergy.condition.get("formation", ""):
				"front_row_melee":
					return unit.grid_position.y <= 1  # 前排
				"back_row_ranged":
					return unit.grid_position.y > 1   # 后排
			return false

		SynergyType.MIXED:
			# 混合协同影响所有参与单位
			return unit.get_class_type() in synergy.condition.get("classes", [])

	return false


## 应用协同加成
func _apply_synergy_bonus(bonuses: Dictionary, synergy: SynergyEffect, unit: UnitInstance) -> void:
	# 混合协同特殊处理
	if synergy.synergy_type == SynergyType.MIXED:
		match synergy.id:
			"balance":
				# 战士 +15% HP，治疗 +10% 治疗量
				if unit.get_class_type() == Global.ClassType.WARRIOR:
					bonuses["hp"] += 0.15
				elif unit.get_class_type() == Global.ClassType.HEALER:
					bonuses["heal"] += 0.1
			"magic_martial":
				# 法师 +10% 伤害，战士 +10% 攻击
				if unit.get_class_type() == Global.ClassType.MAGE:
					bonuses["damage"] += 0.1
				elif unit.get_class_type() == Global.ClassType.WARRIOR:
					bonuses["attack"] += 0.1
		return

	# 普通加成
	match synergy.bonus_type:
		"attack":
			bonuses["attack"] += synergy.bonus_value
		"defense":
			bonuses["defense"] += synergy.bonus_value
		"damage":
			bonuses["damage"] += synergy.bonus_value
		"heal":
			bonuses["heal"] += synergy.bonus_value
		"hp":
			bonuses["hp"] += synergy.bonus_value
		"attack_speed":
			bonuses["attack_speed"] += synergy.bonus_value


## 获取所有协同定义
func get_all_synergies() -> Array[SynergyEffect]:
	return _synergies


## 获取协同定义
func get_synergy(synergy_id: String) -> SynergyEffect:
	for synergy in _synergies:
		if synergy.id == synergy_id:
			return synergy
	return null
