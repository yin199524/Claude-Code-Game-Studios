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
	# 世界 1: 翠绿森林 (包含当前所有可用关卡)
	var forest = WorldDefinition.new()
	forest.id = "world_forest"
	forest.display_name = "翠绿森林"
	forest.theme = WorldDefinition.WorldTheme.FOREST
	forest.level_ids = ["level_001", "level_002", "level_003", "level_004", "level_005"]
	forest.unlock_world_id = ""  # 初始解锁
	forest.description = "宁静的森林，新手冒险的起点"
	forest.completion_gold = 200
	_register_world(forest)

	# 世界 2-5: 预留 (内容扩展时填充)
	# 目前仅显示第一个世界，后续世界将在 Sprint 9 内容扩展时添加


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
