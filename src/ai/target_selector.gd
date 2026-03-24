# TargetSelector.gd - 目标选择 AI 系统
# 决定每个单位在战斗中选择攻击哪个敌人
# 参考: design/gdd/target-selection-ai.md

class_name TargetSelector
extends RefCounted

## 目标锁定时间（秒）
## 锁定期间不切换目标，避免频繁切换
const TARGET_LOCK_DURATION: float = 1.0

## 目标切换距离阈值
## 当新目标比当前目标近超过此值时才切换
const TARGET_SWITCH_THRESHOLD: int = 0


## 选择目标
## attacker: 攻击者单位实例
## enemies: 敌方单位列表
## 返回: 最优目标，或 null 表示无目标
static func select_target(attacker: UnitInstance, enemies: Array[UnitInstance]) -> UnitInstance:
	if enemies.is_empty():
		return null

	# 过滤有效目标
	var valid_targets: Array[UnitInstance] = []
	for enemy in enemies:
		if _is_valid_target(attacker, enemy):
			valid_targets.append(enemy)

	if valid_targets.is_empty():
		return null

	# 治疗单位特殊处理：选择血量百分比最低的友方
	# 注意：治疗的目标选择应该在更高层处理（传入友方列表）
	# 这里保持通用逻辑，治疗单位的特殊处理由调用方处理

	# 按距离排序（最近优先）
	valid_targets.sort_custom(
		func(a: UnitInstance, b: UnitInstance) -> bool:
			return get_manhattan_distance(attacker.grid_position, a.grid_position) < get_manhattan_distance(attacker.grid_position, b.grid_position)
	)

	# 返回最近的目标
	return valid_targets[0]


## 为治疗单位选择目标
## healer: 治疗单位实例
## allies: 友方单位列表（包括自己）
## 返回: 血量百分比最低的友方，或 null 表示无目标
static func select_heal_target(healer: UnitInstance, allies: Array[UnitInstance]) -> UnitInstance:
	if allies.is_empty():
		return null

	var valid_targets: Array[UnitInstance] = []
	for ally in allies:
		if ally.is_alive and ally.get_hp_percent() < 1.0:
			valid_targets.append(ally)

	if valid_targets.is_empty():
		return null

	# 按血量百分比排序（最低优先）
	valid_targets.sort_custom(
		func(a: UnitInstance, b: UnitInstance) -> bool:
			return a.get_hp_percent() < b.get_hp_percent()
	)

	return valid_targets[0]


## 检查目标是否有效
static func _is_valid_target(attacker: UnitInstance, target: UnitInstance) -> bool:
	# 目标必须存活
	if not target.is_alive:
		return false

	# 检查是否在攻击范围内
	var distance = get_manhattan_distance(attacker.grid_position, target.grid_position)
	return distance <= attacker.get_attack_range()


## 计算曼哈顿距离
## a, b: 网格坐标
## 返回: 曼哈顿距离
static func get_manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


## 计算欧几里得距离
## a, b: 网格坐标
## 返回: 欧几里得距离（浮点）
static func get_euclidean_distance(a: Vector2i, b: Vector2i) -> float:
	return sqrt(float((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)))


## 检查是否应该切换目标
## attacker: 攻击者
## new_target: 新候选目标
## 返回: 是否应该切换
static func should_switch_target(attacker: UnitInstance, new_target: UnitInstance) -> bool:
	# 没有当前目标，直接切换
	if attacker.current_target == null:
		return true

	# 当前目标已死亡，必须切换
	if not attacker.current_target.is_alive:
		return true

	# 当前目标移出范围，切换
	var current_distance = get_manhattan_distance(attacker.grid_position, attacker.current_target.grid_position)
	if current_distance > attacker.get_attack_range():
		return true

	# 目标锁定时间内不切换
	if attacker.target_lock_timer > 0:
		return false

	# 新目标比当前目标近超过阈值才切换
	if new_target == null:
		return false

	var new_distance = get_manhattan_distance(attacker.grid_position, new_target.grid_position)
	return (current_distance - new_distance) > TARGET_SWITCH_THRESHOLD


## 获取最近敌人
## attacker: 攻击者
## enemies: 敌方单位列表
## 返回: 最近的敌人（不考虑攻击范围），或 null
static func get_nearest_enemy(attacker: UnitInstance, enemies: Array[UnitInstance]) -> UnitInstance:
	if enemies.is_empty():
		return null

	var nearest: UnitInstance = null
	var nearest_distance: int = 999999

	for enemy in enemies:
		if enemy.is_alive:
			var distance = get_manhattan_distance(attacker.grid_position, enemy.grid_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest = enemy

	return nearest


## 获取攻击范围内的敌人数量
static func get_enemies_in_range(attacker: UnitInstance, enemies: Array[UnitInstance]) -> int:
	var count: int = 0
	for enemy in enemies:
		if _is_valid_target(attacker, enemy):
			count += 1
	return count
