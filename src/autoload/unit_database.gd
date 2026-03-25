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

	# === 新增玩家单位 (Sprint 9) ===

	# 长枪兵 - 战士变种
	var spearman = UnitDefinition.new()
	spearman.id = "unit_spearman"
	spearman.display_name = "长枪兵"
	spearman.class_type = Global.ClassType.WARRIOR
	spearman.rarity = Global.Rarity.COMMON
	spearman.hp = 400
	spearman.attack = 50
	spearman.attack_speed = 0.9
	spearman.attack_range = 2
	spearman.armor = 25
	spearman.move_speed = 1.2
	spearman.base_price = 70
	_units[spearman.id] = spearman

	# 猎人 - 弓手变种
	var hunter = UnitDefinition.new()
	hunter.id = "unit_hunter"
	hunter.display_name = "猎人"
	hunter.class_type = Global.ClassType.ARCHER
	hunter.rarity = Global.Rarity.COMMON
	hunter.hp = 180
	hunter.attack = 70
	hunter.attack_speed = 1.1
	hunter.attack_range = 4
	hunter.armor = 3
	hunter.move_speed = 1.8
	hunter.base_price = 75
	_units[hunter.id] = hunter

	# 牧师 - 群体治疗
	var priest = UnitDefinition.new()
	priest.id = "unit_priest"
	priest.display_name = "牧师"
	priest.class_type = Global.ClassType.HEALER
	priest.rarity = Global.Rarity.RARE
	priest.hp = 200
	priest.attack = 25
	priest.attack_speed = 0.8
	priest.attack_range = 3
	priest.armor = 8
	priest.move_speed = 1.0
	priest.base_price = 150
	_units[priest.id] = priest

	# 火法师 - 高伤害法师
	var pyromancer = UnitDefinition.new()
	pyromancer.id = "unit_pyromancer"
	pyromancer.display_name = "火法师"
	pyromancer.class_type = Global.ClassType.MAGE
	pyromancer.rarity = Global.Rarity.RARE
	pyromancer.hp = 150
	pyromancer.attack = 90
	pyromancer.attack_speed = 0.7
	pyromancer.attack_range = 3
	pyromancer.armor = 0
	pyromancer.move_speed = 1.0
	pyromancer.base_price = 180
	_units[pyromancer.id] = pyromancer

	# 圣骑士 - 攻守兼备
	var paladin = UnitDefinition.new()
	paladin.id = "unit_paladin"
	paladin.display_name = "圣骑士"
	paladin.class_type = Global.ClassType.KNIGHT
	paladin.rarity = Global.Rarity.EPIC
	paladin.hp = 450
	paladin.attack = 45
	paladin.attack_speed = 0.85
	paladin.attack_range = 1
	paladin.armor = 35
	paladin.move_speed = 1.5
	paladin.base_price = 300
	_units[paladin.id] = paladin

	# 刺客 - 暴击输出 (ROGUE职业)
	var assassin = UnitDefinition.new()
	assassin.id = "unit_assassin"
	assassin.display_name = "刺客"
	assassin.class_type = Global.ClassType.ROGUE
	assassin.rarity = Global.Rarity.EPIC
	assassin.hp = 280
	assassin.attack = 75
	assassin.attack_speed = 1.3
	assassin.attack_range = 1
	assassin.armor = 10
	assassin.move_speed = 2.5
	assassin.base_price = 280
	_units[assassin.id] = assassin

	# === 敌人专用单位 ===

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

	# === 新增敌人单位 (Sprint 9) ===

	# 沙蝎 - 沙漠敌人
	var scorpion = UnitDefinition.new()
	scorpion.id = "enemy_scorpion"
	scorpion.display_name = "沙蝎"
	scorpion.class_type = Global.ClassType.WARRIOR
	scorpion.rarity = Global.Rarity.COMMON
	scorpion.hp = 400
	scorpion.attack = 45
	scorpion.attack_speed = 1.0
	scorpion.attack_range = 1
	scorpion.armor = 35
	scorpion.move_speed = 1.3
	scorpion.base_price = 0
	_units[scorpion.id] = scorpion

	# 木乃伊 - 沙漠敌人（高护甲）
	var mummy = UnitDefinition.new()
	mummy.id = "enemy_mummy"
	mummy.display_name = "木乃伊"
	mummy.class_type = Global.ClassType.KNIGHT
	mummy.rarity = Global.Rarity.RARE
	mummy.hp = 550
	mummy.attack = 40
	mummy.attack_speed = 0.7
	mummy.attack_range = 1
	mummy.armor = 50
	mummy.move_speed = 0.8
	mummy.base_price = 0
	_units[mummy.id] = mummy

	# 冰狼 - 冰原敌人
	var frost_wolf = UnitDefinition.new()
	frost_wolf.id = "enemy_frost_wolf"
	frost_wolf.display_name = "冰狼"
	frost_wolf.class_type = Global.ClassType.WARRIOR
	frost_wolf.rarity = Global.Rarity.COMMON
	frost_wolf.hp = 350
	frost_wolf.attack = 50
	frost_wolf.attack_speed = 1.2
	frost_wolf.attack_range = 1
	frost_wolf.armor = 15
	frost_wolf.move_speed = 2.0
	frost_wolf.base_price = 0
	_units[frost_wolf.id] = frost_wolf

	# 冰法师 - 冰原敌人
	var ice_mage = UnitDefinition.new()
	ice_mage.id = "enemy_ice_mage"
	ice_mage.display_name = "冰法师"
	ice_mage.class_type = Global.ClassType.MAGE
	ice_mage.rarity = Global.Rarity.RARE
	ice_mage.hp = 200
	ice_mage.attack = 85
	ice_mage.attack_speed = 0.6
	ice_mage.attack_range = 3
	ice_mage.armor = 5
	ice_mage.move_speed = 0.9
	ice_mage.base_price = 0
	_units[ice_mage.id] = ice_mage

	# 火魔 - 火山敌人（高伤害）
	var fire_imp = UnitDefinition.new()
	fire_imp.id = "enemy_fire_imp"
	fire_imp.display_name = "火魔"
	fire_imp.class_type = Global.ClassType.MAGE
	fire_imp.rarity = Global.Rarity.RARE
	fire_imp.hp = 150
	fire_imp.attack = 100
	fire_imp.attack_speed = 0.8
	fire_imp.attack_range = 3
	fire_imp.armor = 0
	fire_imp.move_speed = 1.5
	fire_imp.base_price = 0
	_units[fire_imp.id] = fire_imp

	# 暗影骑士 - 暗影敌人
	var shadow_knight = UnitDefinition.new()
	shadow_knight.id = "enemy_shadow_knight"
	shadow_knight.display_name = "暗影骑士"
	shadow_knight.class_type = Global.ClassType.KNIGHT
	shadow_knight.rarity = Global.Rarity.EPIC
	shadow_knight.hp = 600
	shadow_knight.attack = 60
	shadow_knight.attack_speed = 0.9
	shadow_knight.attack_range = 1
	shadow_knight.armor = 45
	shadow_knight.move_speed = 1.5
	shadow_knight.base_price = 0
	_units[shadow_knight.id] = shadow_knight


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
