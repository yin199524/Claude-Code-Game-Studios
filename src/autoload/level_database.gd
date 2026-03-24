# LevelDatabase.gd - 关卡数据库单例
# 管理: 所有关卡定义的加载和查询
# 参考: design/gdd/level-system.md

extends Node

## 关卡定义字典 {level_id: LevelDefinition}
var _levels: Dictionary = {}

## 加载完成信号
signal database_loaded()

## 是否已加载
var is_loaded: bool = false


func _ready() -> void:
	load_levels()


## 加载所有关卡定义
func load_levels() -> void:
	_levels.clear()

	# 创建 Vertical Slice 阶段的 5 个关卡
	_create_levels()

	is_loaded = true
	database_loaded.emit()


## 创建 5 个关卡
func _create_levels() -> void:
	# 关卡 1：简单入门
	var level1 = LevelDefinition.new()
	level1.id = "level_001"
	level1.display_name = "第一关：初阵"
	level1.description = "击败这些弱小的敌人，熟悉战斗。"
	level1.difficulty = 1
	level1.grid_size = Vector2i(3, 3)
	level1.player_unit_limit = 3
	level1.player_area_start = 2
	level1.enemy_area_end = 1
	level1.gold_reward = 50
	level1.required_level = ""

	# 敌人配置：2 个弱小战士
	level1.enemy_spawns = [
		EnemySpawn.create("unit_warrior", Vector2i(0, 0), 0.8),
		EnemySpawn.create("unit_warrior", Vector2i(2, 0), 0.8)
	]
	_levels[level1.id] = level1

	# 关卡 2：中等难度
	var level2 = LevelDefinition.new()
	level2.id = "level_002"
	level2.display_name = "第二关：遭遇战"
	level2.description = "敌人更加多样，需要更好的布局策略。"
	level2.difficulty = 2
	level2.grid_size = Vector2i(3, 3)
	level2.player_unit_limit = 4
	level2.player_area_start = 2
	level2.enemy_area_end = 1
	level2.gold_reward = 100
	level2.required_level = "level_001"

	# 敌人配置：混合队伍（战士+弓手）
	level2.enemy_spawns = [
		EnemySpawn.create("unit_warrior", Vector2i(0, 0), 1.0),
		EnemySpawn.create("unit_archer", Vector2i(1, 0), 1.0),
		EnemySpawn.create("unit_warrior", Vector2i(2, 0), 1.0)
	]
	_levels[level2.id] = level2

	# 关卡 3：骑士挑战
	var level3 = LevelDefinition.new()
	level3.id = "level_003"
	level3.display_name = "第三关：钢铁之墙"
	level3.description = "强大的骑士冲锋！用战士克制他们。"
	level3.difficulty = 3
	level3.grid_size = Vector2i(3, 3)
	level3.player_unit_limit = 4
	level3.player_area_start = 2
	level3.enemy_area_end = 1
	level3.gold_reward = 150
	level3.required_level = "level_002"

	# 敌人配置：骑士为主（战士克制）
	level3.enemy_spawns = [
		EnemySpawn.create("unit_knight", Vector2i(0, 0), 1.0),
		EnemySpawn.create("unit_knight", Vector2i(2, 0), 1.0)
	]
	_levels[level3.id] = level3

	# 关卡 4：法师塔
	var level4 = LevelDefinition.new()
	level4.id = "level_004"
	level4.display_name = "第四关：魔法风暴"
	level4.description = "法师的攻击力惊人！弓手是他们的克星。"
	level4.difficulty = 4
	level4.grid_size = Vector2i(3, 3)
	level4.player_unit_limit = 5
	level4.player_area_start = 2
	level4.enemy_area_end = 1
	level4.gold_reward = 200
	level4.required_level = "level_003"

	# 敌人配置：法师为主 + 新敌人暗影法师
	level4.enemy_spawns = [
		EnemySpawn.create("enemy_shadow_mage", Vector2i(0, 0), 1.0),
		EnemySpawn.create("unit_mage", Vector2i(1, 0), 1.1),
		EnemySpawn.create("enemy_shadow_mage", Vector2i(2, 0), 1.0)
	]
	_levels[level4.id] = level4

	# 关卡 5：最终决战
	var level5 = LevelDefinition.new()
	level5.id = "level_005"
	level5.display_name = "第五关：终极试炼"
	level5.description = "完整的敌方阵容！运用所有克制知识取得胜利！"
	level5.difficulty = 5
	level5.grid_size = Vector2i(3, 3)
	level5.player_unit_limit = 5
	level5.player_area_start = 2
	level5.enemy_area_end = 1
	level5.gold_reward = 300
	level5.required_level = "level_004"

	# 敌人配置：精英战士 + 暗影法师 + 骑士
	level5.enemy_spawns = [
		EnemySpawn.create("enemy_elite_warrior", Vector2i(0, 0), 1.0),
		EnemySpawn.create("enemy_shadow_mage", Vector2i(1, 0), 1.0),
		EnemySpawn.create("unit_knight", Vector2i(2, 0), 1.2)
	]
	_levels[level5.id] = level5


## 通过 ID 获取关卡定义
func get_level(level_id: String) -> LevelDefinition:
	if _levels.has(level_id):
		return _levels[level_id]
	return null


## 检查关卡是否存在
func has_level(level_id: String) -> bool:
	return _levels.has(level_id)


## 获取所有关卡 ID 列表
func get_all_level_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in _levels.keys():
		ids.append(id)
	return ids


## 获取所有关卡定义列表
func get_all_levels() -> Array[LevelDefinition]:
	var levels: Array[LevelDefinition] = []
	for level in _levels.values():
		levels.append(level)
	return levels


## 获取关卡数量
func get_level_count() -> int:
	return _levels.size()


## 检查关卡是否解锁
func is_level_unlocked(level_id: String) -> bool:
	var level = get_level(level_id)
	if level == null:
		return false

	# 如果没有前置关卡要求，则已解锁
	if level.required_level.is_empty():
		return true

	# 检查前置关卡是否已完成
	return SaveManager.is_level_completed(level.required_level)


## 检查关卡是否已完成
func is_level_completed(level_id: String) -> bool:
	return SaveManager.is_level_completed(level_id)


## 解锁关卡（通常由完成前置关卡自动触发）
func unlock_level(level_id: String) -> void:
	SaveManager.unlock_level(level_id)


## 完成关卡
func complete_level(level_id: String) -> void:
	SaveManager.complete_level(level_id)


## 验证所有关卡定义
func validate_all() -> Array:
	var all_valid: bool = true
	var errors: Array[String] = []

	for level_id in _levels.keys():
		var level = _levels[level_id]
		var result = level.validate()
		if not result[0]:
			all_valid = false
			errors.append("关卡 %s 验证失败: %s" % [level_id, result[1]])

	return [all_valid, "\n".join(errors)]


## 获取下一个关卡（按难度排序）
func get_next_level(current_level_id: String) -> LevelDefinition:
	var current = get_level(current_level_id)
	if current == null:
		return null

	for level in _levels.values():
		if level.required_level == current_level_id:
			return level

	return null


## 获取第一个关卡
func get_first_level() -> LevelDefinition:
	for level in _levels.values():
		if level.required_level.is_empty():
			return level
	return null


## 获取已完成的关卡数量
func get_completed_count() -> int:
	var count = 0
	for level_id in _levels.keys():
		if is_level_completed(level_id):
			count += 1
	return count


## 获取总进度百分比 (0.0 - 1.0)
func get_progress() -> float:
	if _levels.is_empty():
		return 0.0
	return float(get_completed_count()) / float(_levels.size())
