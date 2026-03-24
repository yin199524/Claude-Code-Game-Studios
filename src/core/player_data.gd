# PlayerData.gd - 玩家数据 Resource 类
# 存储玩家的金币、拥有的单位列表和游戏进度
# 参考: design/gdd/player-data.md

class_name PlayerData
extends Resource

## 玩家当前金币
@export var gold: int = 100:
	set(value):
		gold = maxi(value, 0)

## 已解锁关卡列表
@export var unlocked_levels: Array[String] = ["level_001"]

## 已完成的关卡列表
@export var completed_levels: Array[String] = []

## 玩家拥有的单位实例
## 每个实例包含: unit_id, level
@export var owned_units: Array[Dictionary] = []

## 当前选择的关卡
@export var current_level_id: String = ""

## 游戏设置
@export var settings: Dictionary = {
	"bgm_volume": 1.0,
	"sfx_volume": 1.0,
	"auto_battle_speed": 1.0
}


## 添加金币
func add_gold(amount: int) -> void:
	gold += amount


## 花费金币
## 返回: 是否成功花费
func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		return true
	return false


## 检查是否拥有足够金币
func can_afford(amount: int) -> bool:
	return gold >= amount


## 添加单位到拥有列表
## unit_id: 单位定义 ID
## level: 初始等级（默认为1）
func add_unit(unit_id: String, level: int = 1) -> void:
	owned_units.append({
		"unit_id": unit_id,
		"level": level
	})


## 检查是否拥有指定单位
func has_unit(unit_id: String) -> bool:
	for unit in owned_units:
		if unit.unit_id == unit_id:
			return true
	return false


## 获取单位的当前等级
## 如果不拥有该单位，返回 0
func get_unit_level(unit_id: String) -> int:
	for unit in owned_units:
		if unit.unit_id == unit_id:
			return unit.level
	return 0


## 升级单位
## 返回: 是否成功升级
func upgrade_unit(unit_id: String) -> bool:
	for i in range(owned_units.size()):
		if owned_units[i].unit_id == unit_id:
			owned_units[i].level += 1
			return true
	return false


## 解锁关卡
func unlock_level(level_id: String) -> void:
	if level_id not in unlocked_levels:
		unlocked_levels.append(level_id)


## 完成关卡
func complete_level(level_id: String) -> void:
	if level_id not in completed_levels:
		completed_levels.append(level_id)


## 检查关卡是否已解锁
func is_level_unlocked(level_id: String) -> bool:
	return level_id in unlocked_levels


## 检查关卡是否已完成
func is_level_completed(level_id: String) -> bool:
	return level_id in completed_levels


## 获取拥有的单位数量
func get_unit_count() -> int:
	return owned_units.size()


## 重置玩家数据（用于测试）
func reset() -> void:
	gold = 100
	unlocked_levels = ["level_001"]
	completed_levels = []
	owned_units = []
	current_level_id = ""
	settings = {
		"bgm_volume": 1.0,
		"sfx_volume": 1.0,
		"auto_battle_speed": 1.0
	}


## 创建默认玩家数据
static func create_default() -> PlayerData:
	var data = PlayerData.new()
	# 给玩家一些初始单位
	data.add_unit("unit_warrior", 1)
	return data
