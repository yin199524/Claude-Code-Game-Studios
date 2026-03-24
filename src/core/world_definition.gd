# WorldDefinition.gd - 世界定义 Resource 类
# 定义游戏世界的属性、主题和关卡列表
# 参考: design/gdd/world-map-system.md

class_name WorldDefinition
extends Resource

## 世界主题枚举
enum WorldTheme {
	FOREST,   ## 森林
	DESERT,   ## 沙漠
	ICE,      ## 冰原
	VOLCANO,  ## 火山
	SHADOW    ## 暗影
}

## 唯一标识符
@export var id: String = ""

## 显示名称
@export var display_name: String = ""

## 主题类型
@export var theme: WorldTheme = WorldTheme.FOREST

## 关卡 ID 列表
@export var level_ids: Array[String] = []

## 解锁条件（前一个世界 ID，空表示初始解锁）
@export var unlock_world_id: String = ""

## 世界描述
@export_multiline var description: String = ""

## 世界完成奖励（金币）
@export var completion_gold: int = 200


## 获取主题颜色
func get_theme_color() -> Color:
	match theme:
		WorldTheme.FOREST:
			return Color(0.2, 0.6, 0.3)
		WorldTheme.DESERT:
			return Color(0.9, 0.7, 0.3)
		WorldTheme.ICE:
			return Color(0.5, 0.8, 0.9)
		WorldTheme.VOLCANO:
			return Color(0.9, 0.3, 0.2)
		WorldTheme.SHADOW:
			return Color(0.4, 0.2, 0.5)
	return Color(0.5, 0.5, 0.5)


## 获取主题背景色
func get_background_color() -> Color:
	match theme:
		WorldTheme.FOREST:
			return Color(0.15, 0.25, 0.15)
		WorldTheme.DESERT:
			return Color(0.3, 0.25, 0.15)
		WorldTheme.ICE:
			return Color(0.2, 0.25, 0.3)
		WorldTheme.VOLCANO:
			return Color(0.25, 0.1, 0.1)
		WorldTheme.SHADOW:
			return Color(0.1, 0.08, 0.15)
	return Color(0.2, 0.2, 0.2)


## 获取主题图标
func get_theme_icon() -> String:
	match theme:
		WorldTheme.FOREST:
			return "🌲"
		WorldTheme.DESERT:
			return "🏜"
		WorldTheme.ICE:
			return "❄"
		WorldTheme.VOLCANO:
			return "🌋"
		WorldTheme.SHADOW:
			return "🌑"
	return "🌍"


## 获取关卡数量
func get_level_count() -> int:
	return level_ids.size()


## 验证世界定义有效性
func validate() -> Array:
	var errors: Array[String] = []

	if id.is_empty():
		errors.append("世界 ID 不能为空")

	if display_name.is_empty():
		errors.append("世界名称不能为空")

	if level_ids.is_empty():
		errors.append("世界必须包含至少一个关卡")

	if errors.is_empty():
		return [true, ""]
	else:
		return [false, "\n".join(errors)]
