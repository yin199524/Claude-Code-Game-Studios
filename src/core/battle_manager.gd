# BattleManager.gd - 自动战斗管理器
# 执行回合制自动战斗
# 参考: design/gdd/auto-battle-system.md

class_name BattleManager
extends RefCounted

## 信号
signal turn_completed(turn_number: int)
signal unit_attacked(attacker: UnitInstance, target: UnitInstance, damage: int, counter_status: int)
signal unit_died(unit: UnitInstance)
signal battle_ended(victory: bool, rewards: Dictionary)
signal synergies_activated(synergy_names: Array[String])

## 常量
const MAX_TURNS: int = 100
const MAX_TIME: float = 180.0

## 回合时长（秒）
var turn_duration: float = 1.0

## 当前回合数
var current_turn: int = 0

## 是否战斗中
var is_battling: bool = false

## 是否暂停
var is_paused: bool = false

## 战斗速度倍率
var battle_speed: float = 1.0

## 网格布局
var grid_layout: GridLayout = null

## 状态机
var state_machine: BattleStateMachine = null

## 协同管理器
var synergy_manager: SynergyManager = null

## 当前激活的协同
var active_synergies: Array = []

## 战斗开始时间
var battle_start_time: float = 0.0

## 累计时间
var accumulated_time: float = 0.0


## 初始化战斗管理器
func initialize(layout: GridLayout) -> void:
	grid_layout = layout
	state_machine = BattleStateMachine.new()
	state_machine.state_changed.connect(_on_state_changed)
	synergy_manager = SynergyManager.new()


## 开始战斗
func start_battle() -> void:
	if is_battling:
		return

	is_battling = true
	is_paused = false
	current_turn = 0
	accumulated_time = 0.0
	battle_start_time = Time.get_ticks_msec() / 1000.0

	state_machine.start_battle()

	# 初始化所有单位的攻击冷却
	for unit in grid_layout.get_all_units():
		unit.reset_attack_cooldown()
		unit.is_alive = true
		unit.current_target = null
		unit.target_lock_timer = 0.0

	# 检测并应用协同效果（仅玩家单位）
	_apply_synergies()


## 更新战斗（每帧调用）
## delta: 帧时间
func update(delta: float) -> void:
	if not is_battling or is_paused:
		return

	# 检查超时
	if _check_timeout():
		return

	# 累计时间
	accumulated_time += delta * battle_speed

	# 执行回合
	if accumulated_time >= turn_duration:
		accumulated_time -= turn_duration
		_execute_turn()


## 执行一个回合
func _execute_turn() -> void:
	current_turn += 1

	# 获取所有存活单位
	var all_units = grid_layout.get_all_units()
	var alive_units = all_units.filter(func(u): return u.is_alive)

	# 按位置排序（确定性顺序）
	alive_units.sort_custom(func(a, b): return _compare_unit_order(a, b))

	# 每个单位行动
	for unit in alive_units:
		if not unit.is_alive:
			continue
		_execute_unit_action(unit)

	# 检查战斗结束
	if _check_battle_end():
		return

	turn_completed.emit(current_turn)


## 执行单位行动
func _execute_unit_action(unit: UnitInstance) -> void:
	# 更新目标锁定计时
	if unit.target_lock_timer > 0:
		unit.target_lock_timer -= turn_duration

	# 获取敌人列表
	var enemies: Array[UnitInstance] = []
	if unit.is_player_unit:
		enemies = grid_layout.get_enemy_units()
	else:
		enemies = grid_layout.get_player_units()

	# 过滤存活敌人
	enemies = enemies.filter(func(e): return e.is_alive)

	# 选择目标
	var target = _select_target(unit, enemies)

	if target == null:
		# 无目标，待机
		return

	# 更新当前目标
	var previous_target = unit.current_target
	unit.current_target = target

	# 检查距离
	var distance = TargetSelector.get_manhattan_distance(unit.grid_position, target.grid_position)

	if distance > unit.get_attack_range():
		# 目标不在范围内，移动
		_move_towards_target(unit, target)
	else:
		# 目标在范围内，攻击
		_execute_attack(unit, target)


## 选择目标
func _select_target(unit: UnitInstance, enemies: Array[UnitInstance]) -> UnitInstance:
	if unit.get_class_type() == Global.ClassType.HEALER:
		# 治疗单位选择友方
		var allies: Array[UnitInstance] = []
		if unit.is_player_unit:
			allies = grid_layout.get_player_units()
		else:
			allies = grid_layout.get_enemy_units()
		allies = allies.filter(func(a): return a.is_alive)
		return TargetSelector.select_heal_target(unit, allies)
	else:
		# 攻击单位选择敌人
		return TargetSelector.select_target(unit, enemies)


## 移动向目标
func _move_towards_target(unit: UnitInstance, target: UnitInstance) -> void:
	if unit.get_move_speed() <= 0:
		return  # 单位不能移动

	var current_pos = unit.grid_position
	var target_pos = target.grid_position

	# 计算移动方向
	var dx = target_pos.x - current_pos.x
	var dy = target_pos.y - current_pos.y

	# 确定移动步数
	var move_steps = mini(ceil(unit.get_move_speed()), max(absi(dx), absi(dy)))

	# 尝试移动
	for _step in range(move_steps):
		var new_pos = _get_next_move_position(unit, target_pos)
		if new_pos != current_pos:
			# 执行移动
			grid_layout.remove_unit(current_pos)
			grid_layout.place_unit(unit, new_pos)
			current_pos = new_pos
		else:
			break  # 无法移动


## 获取下一个移动位置
func _get_next_move_position(unit: UnitInstance, target_pos: Vector2i) -> Vector2i:
	var current_pos = unit.grid_position
	var dx = target_pos.x - current_pos.x
	var dy = target_pos.y - current_pos.y

	# 优先移动主要方向
	var candidates: Array[Vector2i] = []

	if absi(dx) >= absi(dy):
		# 优先水平移动
		if dx > 0:
			candidates.append(Vector2i(current_pos.x + 1, current_pos.y))
		elif dx < 0:
			candidates.append(Vector2i(current_pos.x - 1, current_pos.y))
		if dy > 0:
			candidates.append(Vector2i(current_pos.x, current_pos.y + 1))
		elif dy < 0:
			candidates.append(Vector2i(current_pos.x, current_pos.y - 1))
	else:
		# 优先垂直移动
		if dy > 0:
			candidates.append(Vector2i(current_pos.x, current_pos.y + 1))
		elif dy < 0:
			candidates.append(Vector2i(current_pos.x, current_pos.y - 1))
		if dx > 0:
			candidates.append(Vector2i(current_pos.x + 1, current_pos.y))
		elif dx < 0:
			candidates.append(Vector2i(current_pos.x - 1, current_pos.y))

	# 尝试候选位置
	for pos in candidates:
		if grid_layout.is_valid_position(pos) and not grid_layout.has_unit_at(pos):
			return pos

	return current_pos  # 无法移动


## 执行攻击
func _execute_attack(attacker: UnitInstance, target: UnitInstance) -> void:
	# 治疗单位特殊处理
	if attacker.get_class_type() == Global.ClassType.HEALER:
		_heal_target(attacker, target)
		return

	# 计算伤害（应用等级加成）
	var result = DamageCalculator.calculate_from_instances(attacker, target, true)

	# 应用协同伤害加成
	var damage_bonus = attacker.get_synergy_damage_bonus()
	var final_damage = int(result.final_damage * (1.0 + damage_bonus))

	# 应用伤害
	var actual_damage = target.take_damage(final_damage)
	unit_attacked.emit(attacker, target, actual_damage, result.counter_status)

	# 检查死亡
	if not target.is_alive:
		unit_died.emit(target)


## 执行治疗
func _heal_target(healer: UnitInstance, target: UnitInstance) -> void:
	# 治疗量为攻击力的一定比例（应用等级加成和协同加成）
	# 平衡调整: 治疗系数 0.5 -> 0.7
	var base_heal = healer.definition.get_attack_at_level(healer.level) * 0.7
	var heal_bonus = healer.get_synergy_heal_bonus()
	var heal_amount = int(base_heal * (1.0 + heal_bonus))
	var actual_heal = target.heal(heal_amount)

	# 发送攻击信号用于 UI 显示（治疗也是"攻击"的一种，克制状态为 0）
	unit_attacked.emit(healer, target, actual_heal, 0)


## 检查战斗结束
func _check_battle_end() -> bool:
	var player_alive = grid_layout.get_player_units().filter(func(u): return u.is_alive).size()
	var enemy_alive = grid_layout.get_enemy_units().filter(func(u): return u.is_alive).size()

	if enemy_alive == 0:
		# 玩家胜利
		_end_battle(true)
		return true

	if player_alive == 0:
		# 玩家失败
		_end_battle(false)
		return true

	if current_turn >= MAX_TURNS:
		# 超过最大回合数，判失败
		_end_battle(false)
		return true

	return false


## 检查超时
func _check_timeout() -> bool:
	var elapsed = Time.get_ticks_msec() / 1000.0 - battle_start_time
	if elapsed > MAX_TIME:
		_end_battle(false)
		return true
	return false


## 结束战斗
func _end_battle(victory: bool) -> void:
	is_battling = false

	var rewards: Dictionary = {}
	if victory:
		# 计算奖励
		rewards = _calculate_rewards()

	state_machine.victory() if victory else state_machine.defeat()
	battle_ended.emit(victory, rewards)


## 计算奖励
func _calculate_rewards() -> Dictionary:
	var base_gold: int = 50
	var turn_bonus: int = maxi(0, 20 - current_turn)  # 回合越少，奖励越多
	return {
		"gold": base_gold + turn_bonus,
		"turns": current_turn
	}


## 暂停战斗
func pause_battle() -> void:
	if is_battling:
		is_paused = true


## 继续战斗
func resume_battle() -> void:
	if is_battling and is_paused:
		is_paused = false


## 设置战斗速度
func set_battle_speed(speed: float) -> void:
	battle_speed = clampf(speed, 0.5, 3.0)


## 获取战斗状态
func get_battle_state() -> Dictionary:
	return {
		"current_turn": current_turn,
		"is_battling": is_battling,
		"is_paused": is_paused,
		"battle_speed": battle_speed,
		"player_units_alive": grid_layout.get_player_units().filter(func(u): return u.is_alive).size(),
		"enemy_units_alive": grid_layout.get_enemy_units().filter(func(u): return u.is_alive).size(),
		"elapsed_time": Time.get_ticks_msec() / 1000.0 - battle_start_time if is_battling else 0.0
	}


## 状态变化回调
func _on_state_changed(old_state: BattleStateMachine.State, new_state: BattleStateMachine.State) -> void:
	pass


## 单位排序比较
func _compare_unit_order(a: UnitInstance, b: UnitInstance) -> bool:
	# 按位置排序：从左到右，从上到下
	if a.grid_position.y != b.grid_position.y:
		return a.grid_position.y < b.grid_position.y
	return a.grid_position.x < b.grid_position.x


## 检测并应用协同效果
func _apply_synergies() -> void:
	var player_units = grid_layout.get_player_units()
	if player_units.is_empty():
		return

	# 检测激活的协同
	active_synergies = synergy_manager.detect_synergies(player_units, grid_layout)

	if active_synergies.is_empty():
		return

	# 收集协同名称用于 UI 显示
	var synergy_names: Array[String] = []
	for synergy in active_synergies:
		synergy_names.append(synergy.display_name)

	# 为每个玩家单位计算并应用协同加成
	for unit in player_units:
		var bonuses = synergy_manager.calculate_synergy_bonuses(unit, active_synergies)
		unit.set_synergy_bonuses(bonuses)

	# 发送协同激活信号
	synergies_activated.emit(synergy_names)
