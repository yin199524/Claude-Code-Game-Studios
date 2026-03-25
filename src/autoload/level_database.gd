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

	# === 沙漠世界关卡 (world_desert) ===

	# 关卡 6：沙漠入口
	var level6 = LevelDefinition.new()
	level6.id = "level_006"
	level6.display_name = "第六关：沙漠入口"
	level6.description = "踏入灼热的沙漠，沙蝎潜伏在沙丘之下。"
	level6.difficulty = 6
	level6.grid_size = Vector2i(3, 3)
	level6.player_unit_limit = 5
	level6.player_area_start = 2
	level6.enemy_area_end = 1
	level6.gold_reward = 200
	level6.required_level = "level_005"
	level6.enemy_spawns = [
		EnemySpawn.create("enemy_scorpion", Vector2i(0, 0), 1.0),
		EnemySpawn.create("enemy_scorpion", Vector2i(2, 0), 1.0)
	]
	_levels[level6.id] = level6

	# 关卡 7：沙丘伏击
	var level7 = LevelDefinition.new()
	level7.id = "level_007"
	level7.display_name = "第七关：沙丘伏击"
	level7.description = "木乃伊从沙中苏醒，护甲坚硬如铁。"
	level7.difficulty = 7
	level7.grid_size = Vector2i(3, 3)
	level7.player_unit_limit = 5
	level7.player_area_start = 2
	level7.enemy_area_end = 1
	level7.gold_reward = 250
	level7.required_level = "level_006"
	level7.enemy_spawns = [
		EnemySpawn.create("enemy_mummy", Vector2i(0, 0), 0.95),      # 平衡调整: 1.0 -> 0.95
		EnemySpawn.create("enemy_scorpion", Vector2i(1, 0), 1.0),     # 平衡调整: 1.1 -> 1.0
		EnemySpawn.create("enemy_mummy", Vector2i(2, 0), 0.95)        # 平衡调整: 1.0 -> 0.95
	]
	_levels[level7.id] = level7

	# 关卡 8：绿洲守卫
	var level8 = LevelDefinition.new()
	level8.id = "level_008"
	level8.display_name = "第八关：绿洲守卫"
	level8.description = "沙漠守卫者阻止你前进。"
	level8.difficulty = 8
	level8.grid_size = Vector2i(3, 3)
	level8.player_unit_limit = 5
	level8.player_area_start = 2
	level8.enemy_area_end = 1
	level8.gold_reward = 300
	level8.required_level = "level_007"
	level8.enemy_spawns = [
		EnemySpawn.create("enemy_elite_warrior", Vector2i(0, 0), 1.0),  # 平衡调整: 1.1 -> 1.0
		EnemySpawn.create("enemy_mummy", Vector2i(1, 0), 1.05),         # 平衡调整: 1.2 -> 1.05
		EnemySpawn.create("enemy_scorpion", Vector2i(2, 0), 1.0)        # 平衡调整: 1.1 -> 1.0
	]
	_levels[level8.id] = level8

	# 关卡 9：沙漠深处
	var level9 = LevelDefinition.new()
	level9.id = "level_009"
	level9.display_name = "第九关：沙漠深处"
	level9.description = "沙漠最强守卫集结。"
	level9.difficulty = 9
	level9.grid_size = Vector2i(3, 3)
	level9.player_unit_limit = 5
	level9.player_area_start = 2
	level9.enemy_area_end = 1
	level9.gold_reward = 350
	level9.required_level = "level_008"
	level9.enemy_spawns = [
		EnemySpawn.create("enemy_mummy", Vector2i(0, 0), 1.1),      # 平衡调整: 1.3 -> 1.1
		EnemySpawn.create("enemy_shadow_mage", Vector2i(1, 0), 0.95), # 平衡调整: 1.0 -> 0.95
		EnemySpawn.create("enemy_mummy", Vector2i(2, 0), 1.1)       # 平衡调整: 1.3 -> 1.1
	]
	_levels[level9.id] = level9

	# === 冰原世界关卡 (world_ice) ===

	var level10 = LevelDefinition.new()
	level10.id = "level_010"
	level10.display_name = "第十关：冰原边界"
	level10.description = "冰狼在雪地中潜伏。"
	level10.difficulty = 10
	level10.grid_size = Vector2i(3, 3)
	level10.player_unit_limit = 5
	level10.player_area_start = 2
	level10.enemy_area_end = 1
	level10.gold_reward = 300
	level10.required_level = "level_009"
	level10.enemy_spawns = [
		EnemySpawn.create("enemy_frost_wolf", Vector2i(0, 0), 1.0),
		EnemySpawn.create("enemy_frost_wolf", Vector2i(2, 0), 1.0)
	]
	_levels[level10.id] = level10

	var level11 = LevelDefinition.new()
	level11.id = "level_011"
	level11.display_name = "第十一关：冰霜要塞"
	level11.description = "冰法师施放寒冰魔法。"
	level11.difficulty = 11
	level11.grid_size = Vector2i(3, 3)
	level11.player_unit_limit = 5
	level11.player_area_start = 2
	level11.enemy_area_end = 1
	level11.gold_reward = 350
	level11.required_level = "level_010"
	level11.enemy_spawns = [
		EnemySpawn.create("enemy_ice_mage", Vector2i(0, 0), 1.0),
		EnemySpawn.create("enemy_frost_wolf", Vector2i(1, 0), 1.1),
		EnemySpawn.create("enemy_ice_mage", Vector2i(2, 0), 1.0)
	]
	_levels[level11.id] = level11

	var level12 = LevelDefinition.new()
	level12.id = "level_012"
	level12.display_name = "第十二关：暴风雪"
	level12.description = "在暴风雪中战斗。"
	level12.difficulty = 12
	level12.grid_size = Vector2i(3, 3)
	level12.player_unit_limit = 5
	level12.player_area_start = 2
	level12.enemy_area_end = 1
	level12.gold_reward = 400
	level12.required_level = "level_011"
	level12.enemy_spawns = [
		EnemySpawn.create("enemy_frost_wolf", Vector2i(0, 0), 1.2),
		EnemySpawn.create("enemy_ice_mage", Vector2i(1, 0), 1.1),
		EnemySpawn.create("enemy_frost_wolf", Vector2i(2, 0), 1.2)
	]
	_levels[level12.id] = level12

	var level13 = LevelDefinition.new()
	level13.id = "level_013"
	level13.display_name = "第十三关：冰原深处"
	level13.description = "冰原最危险的敌人。"
	level13.difficulty = 13
	level13.grid_size = Vector2i(3, 3)
	level13.player_unit_limit = 5
	level13.player_area_start = 2
	level13.enemy_area_end = 1
	level13.gold_reward = 450
	level13.required_level = "level_012"
	level13.enemy_spawns = [
		EnemySpawn.create("enemy_mummy", Vector2i(0, 0), 1.2),
		EnemySpawn.create("enemy_ice_mage", Vector2i(1, 0), 1.2),
		EnemySpawn.create("enemy_mummy", Vector2i(2, 0), 1.2)
	]
	_levels[level13.id] = level13

	# === 火山世界关卡 (world_volcano) ===

	var level14 = LevelDefinition.new()
	level14.id = "level_014"
	level14.display_name = "第十四关：火山脚"
	level14.description = "火魔在熔岩旁等待。"
	level14.difficulty = 14
	level14.grid_size = Vector2i(3, 3)
	level14.player_unit_limit = 5
	level14.player_area_start = 2
	level14.enemy_area_end = 1
	level14.gold_reward = 400
	level14.required_level = "level_013"
	level14.enemy_spawns = [
		EnemySpawn.create("enemy_fire_imp", Vector2i(0, 0), 1.0),
		EnemySpawn.create("enemy_fire_imp", Vector2i(2, 0), 1.0)
	]
	_levels[level14.id] = level14

	var level15 = LevelDefinition.new()
	level15.id = "level_015"
	level15.display_name = "第十五关：熔岩之路"
	level15.description = "火焰与熔岩的双重威胁。"
	level15.difficulty = 15
	level15.grid_size = Vector2i(3, 3)
	level15.player_unit_limit = 5
	level15.player_area_start = 2
	level15.enemy_area_end = 1
	level15.gold_reward = 450
	level15.required_level = "level_014"
	level15.enemy_spawns = [
		EnemySpawn.create("enemy_fire_imp", Vector2i(0, 0), 1.1),
		EnemySpawn.create("enemy_shadow_mage", Vector2i(1, 0), 1.2),
		EnemySpawn.create("enemy_fire_imp", Vector2i(2, 0), 1.1)
	]
	_levels[level15.id] = level15

	var level16 = LevelDefinition.new()
	level16.id = "level_016"
	level16.display_name = "第十六关：火山口"
	level16.description = "火山的炽热中心。"
	level16.difficulty = 16
	level16.grid_size = Vector2i(3, 3)
	level16.player_unit_limit = 5
	level16.player_area_start = 2
	level16.enemy_area_end = 1
	level16.gold_reward = 500
	level16.required_level = "level_015"
	level16.enemy_spawns = [
		EnemySpawn.create("enemy_elite_warrior", Vector2i(0, 0), 1.3),
		EnemySpawn.create("enemy_fire_imp", Vector2i(1, 0), 1.3),
		EnemySpawn.create("enemy_elite_warrior", Vector2i(2, 0), 1.3)
	]
	_levels[level16.id] = level16

	var level17 = LevelDefinition.new()
	level17.id = "level_017"
	level17.display_name = "第十七关：火山巅峰"
	level17.description = "火山世界的最终挑战。"
	level17.difficulty = 17
	level17.grid_size = Vector2i(3, 3)
	level17.player_unit_limit = 5
	level17.player_area_start = 2
	level17.enemy_area_end = 1
	level17.gold_reward = 600
	level17.required_level = "level_016"
	level17.enemy_spawns = [
		EnemySpawn.create("enemy_fire_imp", Vector2i(0, 0), 1.5),
		EnemySpawn.create("enemy_shadow_knight", Vector2i(1, 0), 1.0),
		EnemySpawn.create("enemy_fire_imp", Vector2i(2, 0), 1.5)
	]
	_levels[level17.id] = level17

	# === 暗影世界关卡 (world_shadow) ===

	var level18 = LevelDefinition.new()
	level18.id = "level_018"
	level18.display_name = "第十八关：暗影入口"
	level18.description = "黑暗开始笼罩大地。"
	level18.difficulty = 18
	level18.grid_size = Vector2i(3, 3)
	level18.player_unit_limit = 5
	level18.player_area_start = 2
	level18.enemy_area_end = 1
	level18.gold_reward = 500
	level18.required_level = "level_017"
	level18.enemy_spawns = [
		EnemySpawn.create("enemy_shadow_knight", Vector2i(0, 0), 1.0),
		EnemySpawn.create("enemy_shadow_mage", Vector2i(2, 0), 1.0)
	]
	_levels[level18.id] = level18

	var level19 = LevelDefinition.new()
	level19.id = "level_019"
	level19.display_name = "第十九关：黑暗走廊"
	level19.description = "暗影中隐藏着强大的敌人。"
	level19.difficulty = 19
	level19.grid_size = Vector2i(3, 3)
	level19.player_unit_limit = 5
	level19.player_area_start = 2
	level19.enemy_area_end = 1
	level19.gold_reward = 600
	level19.required_level = "level_018"
	level19.enemy_spawns = [
		EnemySpawn.create("enemy_shadow_knight", Vector2i(0, 0), 1.1),
		EnemySpawn.create("enemy_shadow_mage", Vector2i(1, 0), 1.3),
		EnemySpawn.create("enemy_shadow_knight", Vector2i(2, 0), 1.1)
	]
	_levels[level19.id] = level19

	var level20 = LevelDefinition.new()
	level20.id = "level_020"
	level20.display_name = "第二十关：暗影之心"
	level20.description = "面对最终的暗影军团。"
	level20.difficulty = 20
	level20.grid_size = Vector2i(3, 3)
	level20.player_unit_limit = 5
	level20.player_area_start = 2
	level20.enemy_area_end = 1
	level20.gold_reward = 800
	level20.required_level = "level_019"
	level20.enemy_spawns = [
		EnemySpawn.create("enemy_shadow_knight", Vector2i(0, 0), 1.3),
		EnemySpawn.create("enemy_shadow_knight", Vector2i(1, 0), 1.3),
		EnemySpawn.create("enemy_shadow_mage", Vector2i(2, 0), 1.5)
	]
	_levels[level20.id] = level20

	var level21 = LevelDefinition.new()
	level21.id = "level_021"
	level21.display_name = "最终决战：暗影之王"
	level21.description = "最终 Boss 战！击败暗影之王！"
	level21.difficulty = 21
	level21.grid_size = Vector2i(3, 3)
	level21.player_unit_limit = 5
	level21.player_area_start = 2
	level21.enemy_area_end = 1
	level21.gold_reward = 1000
	level21.required_level = "level_020"
	level21.enemy_spawns = [
		EnemySpawn.create("enemy_shadow_knight", Vector2i(0, 0), 1.5),
		EnemySpawn.create("enemy_shadow_knight", Vector2i(1, 0), 1.8),
		EnemySpawn.create("enemy_shadow_knight", Vector2i(2, 0), 1.5)
	]
	_levels[level21.id] = level21


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
