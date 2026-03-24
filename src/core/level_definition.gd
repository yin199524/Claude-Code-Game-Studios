# LevelDefinition.gd - 关卡定义
# 定义关卡的敌人配置、奖励和限制
# 参考: design/gdd/level-system.md

class_name LevelDefinition
extends Resource

## 关卡 ID
@export var id: String = ""

## 显示名称
@export var display_name: String = ""

## 描述
@export_multiline var description: String = ""

## 难度等级（1-5）
@export_range(1, 5) var difficulty: int = 1

## 网格大小
@export var grid_size: Vector2i = Vector2i(3, 3)

## 玩家单位上限
@export_range(1, 9) var player_unit_limit: int = 5

## 敌人生成配置列表
@export var enemy_spawns: Array[EnemySpawn] = []

## 金币奖励（基础值）
@export var gold_reward: int = 100

## 可能的单位奖励（ID 列表）
@export var possible_unit_rewards: Array[String] = []

## 前置关卡 ID（空表示无需解锁）
@export var required_level: String = ""

## 玩家区域起始行
@export var player_area_start: int = 2

## 敌人区域结束行
@export var enemy_area_end: int = 1


## 验证关卡定义
func validate() -> Array:
	var errors: Array[String] = []

	if id.is_empty():
		errors.append("关卡 ID 不能为空")

	if display_name.is_empty():
		errors.append("关卡名称不能为空")

	if enemy_spawns.is_empty():
		errors.append("关卡必须至少有一个敌人")

	if gold_reward < 0:
		errors.append("金币奖励不能为负数")

	if player_unit_limit < 1:
		errors.append("玩家单位上限必须至少为 1")

	if player_unit_limit > grid_size.x * grid_size.y:
		errors.append("玩家单位上限不能超过网格格子数")

	# 验证敌人位置
	for spawn in enemy_spawns:
		if not _is_valid_spawn_position(spawn.position):
			errors.append("敌人 %s 位置 %s 超出网格范围" % [spawn.unit_id, spawn.position])

	if errors.is_empty():
		return [true, ""]
	else:
		return [false, "\n".join(errors)]


## 检查位置是否在敌人区域
func _is_valid_spawn_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < enemy_area_end


## 获取敌人总数
func get_enemy_count() -> int:
	return enemy_spawns.size()


## 计算难度评分
func calculate_difficulty_score() -> float:
	var total_power: float = 0.0

	for spawn in enemy_spawns:
		var unit = UnitDatabase.get_unit(spawn.unit_id)
		if unit:
			var hp = unit.hp * spawn.level_modifier
			var attack = unit.attack * spawn.level_modifier
			total_power += hp * attack

	return total_power / float(player_unit_limit)


## 获取关卡信息字符串
func get_info_string() -> String:
	return "%s (难度 %d) - %d 敌人, 奖励 %d 金币" % [
		display_name,
		difficulty,
		get_enemy_count(),
		gold_reward
	]


## 创建简单的关卡定义
static func create_simple(id: String, name: String, enemies: Array[EnemySpawn], reward: int) -> LevelDefinition:
	var level = LevelDefinition.new()
	level.id = id
	level.display_name = name
	level.enemy_spawns = enemies
	level.gold_reward = reward
	return level
