# WorldDatabase.gd - 世界数据库单例
# 管理: 所有世界定义数据的加载和查询
# 参考: design/gdd/world-map-system.md

extends Node

## 世界定义字典 {world_id: WorldDefinition}
var _worlds: Dictionary = {}

## 世界顺序列表
var _world_order: Array[String] = []

## 加载完成信号
signal database_loaded()

## 是否已加载
var is_loaded: bool = false


func _ready() -> void:
	load_worlds()


## 加载所有世界定义
func load_worlds() -> void:
	_worlds.clear()
	_world_order.clear()

	# 创建 Alpha 阶段的 5 个世界
	_create_alpha_worlds()

	is_loaded = true
	database_loaded.emit()


## 创建 Alpha 阶段的 5 个世界
func _create_alpha_worlds() -> void:
	# 世界 1: 翠绿森林
	var forest = WorldDefinition.new()
	forest.id = "world_forest"
	forest.display_name = "翠绿森林"
	forest.theme = WorldDefinition.WorldTheme.FOREST
	forest.level_ids = ["level_001", "level_002", "level_003", "level_004"]
	forest.unlock_world_id = ""  # 初始解锁
	forest.description = "宁静的森林，新手冒险的起点"
	forest.completion_gold = 200
	_register_world(forest)

	# 世界 2: 灼热沙漠
	var desert = WorldDefinition.new()
	desert.id = "world_desert"
	desert.display_name = "灼热沙漠"
	desert.theme = WorldDefinition.WorldTheme.DESERT
	desert.level_ids = ["level_005", "level_006", "level_007", "level_008"]
	desert.unlock_world_id = "world_forest"
	desert.description = "炎热的沙漠，高护甲敌人的领地"
	desert.completion_gold = 300
	_register_world(desert)

	# 世界 3: 寒冰冻土
	var ice = WorldDefinition.new()
	ice.id = "world_ice"
	ice.display_name = "寒冰冻土"
	ice.theme = WorldDefinition.WorldTheme.ICE
	ice.level_ids = ["level_009", "level_010", "level_011", "level_012"]
	ice.unlock_world_id = "world_desert"
	ice.description = "冰封的土地，减速效果的危险区域"
	ice.completion_gold = 400
	_register_world(ice)

	# 世界 4: 烈焰火山
	var volcano = WorldDefinition.new()
	volcano.id = "world_volcano"
	volcano.display_name = "烈焰火山"
	volcano.theme = WorldDefinition.WorldTheme.VOLCANO
	volcano.level_ids = ["level_013", "level_014", "level_015", "level_016"]
	volcano.unlock_world_id = "world_ice"
	volcano.description = "熔岩流淌，高伤害敌人的巢穴"
	volcano.completion_gold = 500
	_register_world(volcano)

	# 世界 5: 暗影深渊
	var shadow = WorldDefinition.new()
	shadow.id = "world_shadow"
	shadow.display_name = "暗影深渊"
	shadow.theme = WorldDefinition.WorldTheme.SHADOW
	shadow.level_ids = ["level_017", "level_018", "level_019", "level_020"]
	shadow.unlock_world_id = "world_volcano"
	shadow.description = "黑暗的深渊，最终 Boss 的领域"
	shadow.completion_gold = 1000
	_register_world(shadow)


## 注册世界
func _register_world(world: WorldDefinition) -> void:
	_worlds[world.id] = world
	_world_order.append(world.id)


## 通过 ID 获取世界定义
func get_world(world_id: String) -> WorldDefinition:
	if _worlds.has(world_id):
		return _worlds[world_id]
	return null


## 检查世界是否存在
func has_world(world_id: String) -> bool:
	return _worlds.has(world_id)


## 获取所有世界 ID 列表（按顺序）
func get_all_world_ids() -> Array[String]:
	return _world_order.duplicate()


## 获取所有世界定义列表（按顺序）
func get_all_worlds() -> Array[WorldDefinition]:
	var worlds: Array[WorldDefinition] = []
	for world_id in _world_order:
		worlds.append(_worlds[world_id])
	return worlds


## 获取世界数量
func get_world_count() -> int:
	return _worlds.size()


## 获取第一个世界（初始解锁）
func get_first_world() -> WorldDefinition:
	if _world_order.is_empty():
		return null
	return _worlds[_world_order[0]]


## 获取下一个世界
func get_next_world(current_world_id: String) -> WorldDefinition:
	var idx = _world_order.find(current_world_id)
	if idx >= 0 and idx < _world_order.size() - 1:
		return _worlds[_world_order[idx + 1]]
	return null


## 检查世界是否解锁
func is_world_unlocked(world_id: String) -> bool:
	var world = get_world(world_id)
	if world == null:
		return false

	# 初始世界默认解锁
	if world.unlock_world_id.is_empty():
		return true

	# 检查前置世界是否完成
	return is_world_completed(world.unlock_world_id)


## 检查世界是否完成（所有关卡至少 1 星）
func is_world_completed(world_id: String) -> bool:
	var world = get_world(world_id)
	if world == null:
		return false

	for level_id in world.level_ids:
		if SaveManager.get_level_stars(level_id) < 1:
			return false

	return true


## 获取世界完成进度
func get_world_progress(world_id: String) -> Dictionary:
	var world = get_world(world_id)
	if world == null:
		return {"completed": 0, "total": 0, "stars": 0}

	var completed = 0
	var total_stars = 0

	for level_id in world.level_ids:
		var stars = SaveManager.get_level_stars(level_id)
		if stars > 0:
			completed += 1
			total_stars += stars

	return {
		"completed": completed,
		"total": world.get_level_count(),
		"stars": total_stars,
		"max_stars": world.get_level_count() * 3
	}


## 获取关卡所属的世界
func get_world_for_level(level_id: String) -> WorldDefinition:
	for world_id in _world_order:
		var world = _worlds[world_id]
		if level_id in world.level_ids:
			return world
	return null


## 验证所有世界定义
func validate_all() -> Array:
	var all_valid: bool = true
	var errors: Array[String] = []

	for world_id in _world_order:
		var world = _worlds[world_id]
		var result = world.validate()
		if not result[0]:
			all_valid = false
			errors.append("世界 %s 验证失败: %s" % [world_id, result[1]])

	return [all_valid, "\n".join(errors)]
