# Global.gd - 全局枚举和常量定义
# 作为 Autoload 加载，提供全局访问

extends Node

## 职业类型枚举
enum ClassType {
	WARRIOR,   ## 战士 - 近战坦克
	ARCHER,    ## 弓手 - 远程输出
	MAGE,      ## 法师 - 法术输出
	KNIGHT,    ## 骑士 - 近战输出
	HEALER     ## 治疗 - 辅助
}

## 稀有度枚举
enum Rarity {
	COMMON,     ## 普通
	RARE,       ## 稀有
	EPIC,       ## 史诗
	LEGENDARY   ## 传说
}

## 稀有度属性乘数
## 参考: design/gdd/unit-data-definition.md
const RARITY_MULTIPLIERS: Dictionary = {
	Rarity.COMMON: 1.0,
	Rarity.RARE: 1.2,
	Rarity.EPIC: 1.5,
	Rarity.LEGENDARY: 2.0
}

## 稀有度价格倍率
const RARITY_PRICE_MULTIPLIERS: Dictionary = {
	Rarity.COMMON: 1,
	Rarity.RARE: 2,
	Rarity.EPIC: 4,
	Rarity.LEGENDARY: 10
}

## 属性范围约束
## 参考: design/gdd/unit-data-definition.md - 属性范围约束表
const MAX_HP: int = 9999
const MAX_ATTACK: int = 999
const MAX_ATTACK_SPEED: float = 5.0
const MIN_ATTACK_SPEED: float = 0.1
const MAX_ATTACK_RANGE: int = 10
const MAX_ARMOR: int = 100
const MAX_MOVE_SPEED: float = 5.0

## 获取稀有度名称（用于显示）
static func get_rarity_name(rarity: Rarity) -> String:
	match rarity:
		Rarity.COMMON:
			return "普通"
		Rarity.RARE:
			return "稀有"
		Rarity.EPIC:
			return "史诗"
		Rarity.LEGENDARY:
			return "传说"
	return "未知"

## 获取职业名称（用于显示）
static func get_class_name(class_type: ClassType) -> String:
	match class_type:
		ClassType.WARRIOR:
			return "战士"
		ClassType.ARCHER:
			return "弓手"
		ClassType.MAGE:
			return "法师"
		ClassType.KNIGHT:
			return "骑士"
		ClassType.HEALER:
			return "治疗"
	return "未知"
