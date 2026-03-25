# DailyMissionDefinition.gd - 每日任务定义 Resource 类
# 定义每日任务的属性、目标和奖励
# 参考: design/gdd/daily-mission-system.md

class_name DailyMissionDefinition
extends Resource

## 唯一标识符
@export var id: String = ""

## 显示名称
@export var display_name: String = ""

## 任务描述
@export_multiline var description: String = ""

## 任务类型
@export var mission_type: int = 0  # DailyMissionType

## 目标值
@export var target_value: int = 1

## 奖励金币
@export var reward_gold: int = 50


## 获取进度描述文本
func get_progress_text(current_value: int) -> String:
	return "%d / %d" % [current_value, target_value]


## 获取完成百分比
func get_progress_percent(current_value: int) -> float:
	if target_value <= 0:
		return 1.0
	return minf(float(current_value) / float(target_value), 1.0)


## 检查是否完成
func is_completed(current_value: int) -> bool:
	return current_value >= target_value


## 验证任务定义有效性
func validate() -> Array:
	var errors: Array[String] = []

	if id.is_empty():
		errors.append("任务 ID 不能为空")

	if display_name.is_empty():
		errors.append("任务名称不能为空")

	if target_value <= 0:
		errors.append("目标值必须大于 0")

	if reward_gold < 0:
		errors.append("奖励金币不能为负数")

	if errors.is_empty():
		return [true, ""]
	else:
		return [false, "\n".join(errors)]
