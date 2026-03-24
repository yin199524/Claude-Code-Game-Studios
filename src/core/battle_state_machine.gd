# BattleStateMachine.gd - 战斗状态机
# 管理战斗的整体流程，从布局确认到战斗结束
# 参考: design/gdd/battle-state-machine.md

class_name BattleStateMachine
extends RefCounted

## 战斗状态枚举
enum State {
	SETUP,    ## 布局阶段
	READY,    ## 准备阶段（动画）
	FIGHTING, ## 战斗中
	VICTORY,  ## 胜利
	DEFEAT    ## 失败
}

## 当前状态
var current_state: State = State.SETUP

## 前一个状态
var previous_state: State = State.SETUP

## 战斗开始时间
var battle_start_time: float = 0.0

## 最大战斗时长（秒）
var max_battle_time: float = 180.0

## 准备动画时长（秒）
var ready_animation_duration: float = 1.5

## 状态变化信号
signal state_changed(old_state: State, new_state: State)

## 战斗开始信号
signal battle_started()

## 战斗结束信号
signal battle_ended(victory: bool, rewards: Dictionary)

## 准备阶段完成信号
signal ready_complete()


## 切换到指定状态
func change_state(new_state: State) -> bool:
	# 检查状态转换是否有效
	if not _is_valid_transition(current_state, new_state):
		return false

	previous_state = current_state
	current_state = new_state

	# 执行状态进入逻辑
	_on_enter_state(new_state)

	state_changed.emit(previous_state, new_state)
	return true


## 检查状态转换是否有效
func _is_valid_transition(from: State, to: State) -> bool:
	match from:
		State.SETUP:
			return to == State.READY
		State.READY:
			return to == State.FIGHTING
		State.FIGHTING:
			return to == State.VICTORY or to == State.DEFEAT
		State.VICTORY, State.DEFEAT:
			return to == State.SETUP  # 重新开始
	return false


## 状态进入逻辑
func _on_enter_state(state: State) -> void:
	match state:
		State.READY:
			# 准备阶段开始，设置定时器
			pass
		State.FIGHTING:
			battle_start_time = Time.get_ticks_msec() / 1000.0
			battle_started.emit()
		State.VICTORY:
			battle_ended.emit(true, {})
		State.DEFEAT:
			battle_ended.emit(false, {})


## 确认布局，进入准备阶段
func confirm_layout() -> bool:
	if current_state != State.SETUP:
		return false
	return change_state(State.READY)


## 开始战斗
func start_battle() -> bool:
	if current_state != State.READY:
		return false
	return change_state(State.FIGHTING)


## 战斗胜利
func victory() -> bool:
	if current_state != State.FIGHTING:
		return false
	return change_state(State.VICTORY)


## 战斗失败
func defeat() -> bool:
	if current_state != State.FIGHTING:
		return false
	return change_state(State.DEFEAT)


## 重置状态机
func reset() -> void:
	current_state = State.SETUP
	previous_state = State.SETUP
	battle_start_time = 0.0


## 检查是否在布局阶段
func is_setup() -> bool:
	return current_state == State.SETUP


## 检查是否在战斗中
func is_fighting() -> bool:
	return current_state == State.FIGHTING


## 检查战斗是否结束
func is_battle_ended() -> bool:
	return current_state == State.VICTORY or current_state == State.DEFEAT


## 检查是否胜利
func is_victory() -> bool:
	return current_state == State.VICTORY


## 获取已战斗时间
func get_elapsed_time() -> float:
	if current_state != State.FIGHTING:
		return 0.0
	return Time.get_ticks_msec() / 1000.0 - battle_start_time


## 检查是否超时
func is_timeout() -> bool:
	return get_elapsed_time() > max_battle_time


## 获取状态名称
func get_state_name() -> String:
	match current_state:
		State.SETUP:
			return "布局"
		State.READY:
			return "准备"
		State.FIGHTING:
			return "战斗中"
		State.VICTORY:
			return "胜利"
		State.DEFEAT:
			return "失败"
	return "未知"


## 获取状态名称（静态方法）
static func get_state_name_static(state: State) -> String:
	match state:
		State.SETUP:
			return "SETUP"
		State.READY:
			return "READY"
		State.FIGHTING:
			return "FIGHTING"
		State.VICTORY:
			return "VICTORY"
		State.DEFEAT:
			return "DEFEAT"
	return "UNKNOWN"
