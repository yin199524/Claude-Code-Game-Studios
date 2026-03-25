# AchievementDefinition.gd - 成就定义 Resource 类
# 定义游戏中所有成就的属性、条件和奖励
# 参考: design/gdd/achievement-system.md

class_name AchievementDefinition
extends Resource

## 成就类别枚举（在 Global 中定义）
## PROGRESS - 进度类
## COLLECTION - 收集类
## COMBAT - 战斗类
## UPGRADE - 升级类
## SYNERGY - 协同类
## SPECIAL - 特殊类

## 唯一标识符
@export var id: String = ""

## 显示名称
@export var display_name: String = ""

## 成就描述
@export_multiline var description: String = ""

## 成就类别
@export var category: int = 0  # AchievementCategory

## 目标值（需要达到的数量）
@export var target_value: int = 1

## 奖励金币
@export var reward_gold: int = 100

## 关联的检测事件类型
## 用于触发进度更新的事件名称
@export var trigger_event: String = ""

## 关联的参数（用于特定成就的条件判断）
## 例如: {"level_id": "level_005"} 表示通关第五关
@export var condition_params: Dictionary = {}


## 获取进度描述文本
func get_progress_text(current_value: int) -> String:
	if target_value <= 1:
		return ""
	return "%d / %d" % [current_value, target_value]


## 获取完成百分比
func get_progress_percent(current_value: int) -> float:
	if target_value <= 0:
		return 1.0
	return minf(float(current_value) / float(target_value), 1.0)


## 检查是否完成
func is_completed(current_value: int) -> bool:
	return current_value >= target_value


## 验证成就定义有效性
## 返回: [is_valid: bool, error_message: String]
func validate() -> Array:
	var errors: Array[String] = []

	if id.is_empty():
		errors.append("成就 ID 不能为空")

	if display_name.is_empty():
		errors.append("成就名称不能为空")

	if target_value <= 0:
		errors.append("目标值必须大于 0")

	if reward_gold < 0:
		errors.append("奖励金币不能为负数")

	if errors.is_empty():
		return [true, ""]
	else:
		return [false, "\n".join(errors)]
