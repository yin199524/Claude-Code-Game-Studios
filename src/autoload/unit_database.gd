# UnitDatabase.gd - 单位数据库单例
# 管理: 所有单位定义数据的加载和查询
# 参考: design/gdd/unit-data-definition.md

extends Node

## 单位定义字典 {unit_id: UnitDefinition}
var _units: Dictionary = {}

## 加载完成信号
signal database_loaded()

## 是否已加载
var is_loaded: bool = false


func _ready() -> void:
	load_units()


## 加载所有单位定义
func load_units() -> void:
	_units.clear()

	# 加载单位定义资源文件
	# 在生产环境中，这些应该从文件加载
	# 这里创建 MVP 阶段的 5 个基础单位
	_create_mvp_units()

	is_loaded = true
	database_loaded.emit()


## 创建 MVP 阶段的 5 个基础单位
func _create_mvp_units() -> void:
	# 战士 - 近战坦克
	var warrior = UnitDefinition.new()
	warrior.id = "unit_warrior"
	warrior.display_name = "战士"
	warrior.class_type = Global.ClassType.WARRIOR
	warrior.rarity = Global.Rarity.COMMON
	warrior.hp = 500
	warrior.attack = 40
	warrior.attack_speed = 0.8
	warrior.attack_range = 1
	warrior.armor = 30
	warrior.move_speed = 1.0
	warrior.base_price = 50
	_units[warrior.id] = warrior

	# 弓手 - 远程输出
	var archer = UnitDefinition.new()
	archer.id = "unit_archer"
	archer.display_name = "弓手"
	archer.class_type = Global.ClassType.ARCHER
	archer.rarity = Global.Rarity.COMMON
	archer.hp = 200
	archer.attack = 60
	archer.attack_speed = 1.2
	archer.attack_range = 3
	archer.armor = 5
	archer.move_speed = 1.5
	archer.base_price = 60
	_units[archer.id] = archer

	# 法师 - 法术输出
	var mage = UnitDefinition.new()
	mage.id = "unit_mage"
	mage.display_name = "法师"
	mage.class_type = Global.ClassType.MAGE
	mage.rarity = Global.Rarity.COMMON
	mage.hp = 180
	mage.attack = 80
	mage.attack_speed = 0.6
	mage.attack_range = 2
	mage.armor = 0
	mage.move_speed = 1.0
	mage.base_price = 70
	_units[mage.id] = mage

	# 骑士 - 近战输出
	var knight = UnitDefinition.new()
	knight.id = "unit_knight"
	knight.display_name = "骑士"
	knight.class_type = Global.ClassType.KNIGHT
	knight.rarity = Global.Rarity.COMMON
	knight.hp = 350
	knight.attack = 55
	knight.attack_speed = 1.0
	knight.attack_range = 1
	knight.armor = 20
	knight.move_speed = 2.0
	knight.base_price = 80
	_units[knight.id] = knight

	# 治疗 - 辅助
	var healer = UnitDefinition.new()
	healer.id = "unit_healer"
	healer.display_name = "治疗"
	healer.class_type = Global.ClassType.HEALER
	healer.rarity = Global.Rarity.COMMON
	healer.hp = 250
	healer.attack = 20
	healer.attack_speed = 1.0
	healer.attack_range = 2
	healer.armor = 5
	healer.move_speed = 1.0
	healer.base_price = 100
	_units[healer.id] = healer

	# === 敌人专用单位 (T11) ===

	# 精英战士 - 强化版战士（敌人专用）
	var elite_warrior = UnitDefinition.new()
	elite_warrior.id = "enemy_elite_warrior"
	elite_warrior.display_name = "精英战士"
	elite_warrior.class_type = Global.ClassType.WARRIOR
	elite_warrior.rarity = Global.Rarity.RARE
	elite_warrior.hp = 650
	elite_warrior.attack = 55
	elite_warrior.attack_speed = 0.9
	elite_warrior.attack_range = 1
	elite_warrior.armor = 40
	elite_warrior.move_speed = 1.2
	elite_warrior.base_price = 0  # 敌人不可购买
	_units[elite_warrior.id] = elite_warrior

	# 暗影法师 - 高伤害法师（敌人专用）
	var shadow_mage = UnitDefinition.new()
	shadow_mage.id = "enemy_shadow_mage"
	shadow_mage.display_name = "暗影法师"
	shadow_mage.class_type = Global.ClassType.MAGE
	shadow_mage.rarity = Global.Rarity.RARE
	shadow_mage.hp = 220
	shadow_mage.attack = 100
	shadow_mage.attack_speed = 0.5
	shadow_mage.attack_range = 3
	shadow_mage.armor = 0
	shadow_mage.move_speed = 0.8
	shadow_mage.base_price = 0  # 敌人不可购买
	_units[shadow_mage.id] = shadow_mage


## 通过 ID 获取单位定义
func get_unit(unit_id: String) -> UnitDefinition:
	if _units.has(unit_id):
		return _units[unit_id]
	return null


## 检查单位是否存在
func has_unit(unit_id: String) -> bool:
	return _units.has(unit_id)


## 获取所有单位 ID 列表
func get_all_unit_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in _units.keys():
		ids.append(id)
	return ids


## 获取所有单位定义列表
func get_all_units() -> Array[UnitDefinition]:
	var units: Array[UnitDefinition] = []
	for unit in _units.values():
		units.append(unit)
	return units


## 按职业获取单位列表
func get_units_by_class(class_type: Global.ClassType) -> Array[UnitDefinition]:
	var units: Array[UnitDefinition] = []
	for unit in _units.values():
		if unit.class_type == class_type:
			units.append(unit)
	return units


## 按稀有度获取单位列表
func get_units_by_rarity(rarity: Global.Rarity) -> Array[UnitDefinition]:
	var units: Array[UnitDefinition] = []
	for unit in _units.values():
		if unit.rarity == rarity:
			units.append(unit)
	return units


## 获取单位数量
func get_unit_count() -> int:
	return _units.size()


## 注册新单位定义（用于动态添加）
func register_unit(unit: UnitDefinition) -> bool:
	if unit.id.is_empty():
		return false

	if _units.has(unit.id):
		return false

	_units[unit.id] = unit
	return true


## 验证所有单位定义
## 返回: [is_valid, error_messages]
func validate_all() -> Array:
	var all_valid: bool = true
	var errors: Array[String] = []

	for unit_id in _units.keys():
		var unit = _units[unit_id]
		var result = unit.validate()
		if not result[0]:
			all_valid = false
			errors.append("单位 %s 验证失败: %s" % [unit_id, result[1]])

	return [all_valid, "\n".join(errors)]
