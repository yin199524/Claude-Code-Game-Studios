# EnemySpawn.gd - 敌人生成配置
# 定义关卡中敌人的配置信息
# 参考: design/gdd/enemy-system.md

class_name EnemySpawn
extends Resource

## 单位定义 ID（引用 UnitDefinition）
@export var unit_id: String = ""

## 初始位置（网格坐标）
@export var position: Vector2i = Vector2i(0, 0)

## 属性加成倍率（1.0 = 无加成）
@export var level_modifier: float = 1.0

## 是否为精英单位（可选，后期功能）
@export var is_elite: bool = false


## 创建敌人生成配置
static func create(unit_id: String, position: Vector2i, modifier: float = 1.0) -> EnemySpawn:
	var spawn = EnemySpawn.new()
	spawn.unit_id = unit_id
	spawn.position = position
	spawn.level_modifier = modifier
	return spawn


## 验证配置有效性
func validate() -> Array:
	var errors: Array[String] = []

	if unit_id.is_empty():
		errors.append("unit_id 不能为空")

	if level_modifier <= 0:
		errors.append("level_modifier 必须大于 0")

	if errors.is_empty():
		return [true, ""]
	else:
		return [false, "\n".join(errors)]
