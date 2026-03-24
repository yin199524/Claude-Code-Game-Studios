# GameManager.gd - 游戏状态管理单例
# 管理: 游戏状态、当前关卡、全局配置
# 参考: docs/architecture/adr-0001-game-architecture.md

extends Node

## 游戏状态枚举
enum GameState {
	MAIN_MENU,      ## 主菜单
	LEVEL_SELECT,   ## 关卡选择
	BATTLE_SETUP,   ## 布局阶段
	BATTLE,         ## 战斗中
	SHOP,           ## 商店
	SETTINGS        ## 设置
}

## 当前游戏状态
var current_state: GameState = GameState.MAIN_MENU

## 当前关卡 ID
var current_level_id: String = ""

## 当前战斗速度倍率
var battle_speed: float = 1.0

## 状态变化信号
signal state_changed(old_state: GameState, new_state: GameState)

## 关卡开始信号
signal level_started(level_id: String)

## 战斗结束信号
signal battle_ended(victory: bool, rewards: Dictionary)


## 切换游戏状态
func change_state(new_state: GameState) -> void:
	var old_state = current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)


## 开始关卡
func start_level(level_id: String) -> void:
	current_level_id = level_id
	change_state(GameState.BATTLE_SETUP)
	level_started.emit(level_id)


## 开始战斗
func start_battle() -> void:
	change_state(GameState.BATTLE)


## 结束战斗
func end_battle(victory: bool, rewards: Dictionary = {}) -> void:
	battle_ended.emit(victory, rewards)

	if victory:
		# 胜利后进入商店或返回关卡选择
		if rewards.has("gold"):
			SaveManager.add_gold(rewards["gold"])
		change_state(GameState.SHOP)
	else:
		change_state(GameState.LEVEL_SELECT)


## 返回主菜单
func return_to_main_menu() -> void:
	current_level_id = ""
	change_state(GameState.MAIN_MENU)


## 进入关卡选择
func enter_level_select() -> void:
	change_state(GameState.LEVEL_SELECT)


## 进入商店
func enter_shop() -> void:
	change_state(GameState.SHOP)


## 进入设置
func enter_settings() -> void:
	change_state(GameState.SETTINGS)


## 获取状态名称（用于调试）
func get_state_name() -> String:
	match current_state:
		GameState.MAIN_MENU:
			return "主菜单"
		GameState.LEVEL_SELECT:
			return "关卡选择"
		GameState.BATTLE_SETUP:
			return "布局阶段"
		GameState.BATTLE:
			return "战斗中"
		GameState.SHOP:
			return "商店"
		GameState.SETTINGS:
			return "设置"
	return "未知"


## 设置战斗速度
func set_battle_speed(speed: float) -> void:
	battle_speed = clampf(speed, 0.5, 3.0)
