# Global.gd - 全局枚举和常量定义
# 作为 Autoload 加载，提供全局访问

extends Node

## 职业类型枚举
enum ClassType {
	WARRIOR,   ## 战士 - 近战坦克
	ARCHER,    ## 弓手 - 远程输出
	MAGE,      ## 法师 - 法术输出
	KNIGHT,    ## 骑士 - 近战输出
	HEALER,    ## 治疗 - 辅助
	ROGUE      ## 刺客 - 暴击输出
}

## 稀有度枚举
enum Rarity {
	COMMON,     ## 普通
	RARE,       ## 稀有
	EPIC,       ## 史诗
	LEGENDARY   ## 传说
}

## 成就类别枚举
enum AchievementCategory {
	PROGRESS,   ## 进度类 - 通关相关
	COLLECTION, ## 收集类 - 单位收集
	COMBAT,     ## 战斗类 - 击杀敌人
	UPGRADE,    ## 升级类 - 单位升级
	SYNERGY,    ## 协同类 - 协同效果
	SPECIAL     ## 特殊类 - 特殊条件
}

## 每日任务类型枚举
enum DailyMissionType {
	WIN_LEVELS,     ## 通关关卡
	UPGRADE_UNITS,  ## 升级单位
	BUY_UNITS,      ## 购买单位
	DEFEAT_ENEMIES, ## 击败敌人
	TRIGGER_SYNERGY ## 触发协同
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

## 单位升级系统常量
## 参考: design/gdd/unit-upgrade-system.md
const MAX_UNIT_LEVEL: int = 10                    ## 等级上限
const ATTRIBUTE_BONUS_PER_LEVEL: float = 0.1     ## 每级属性增幅 (10%)
const UPGRADE_COST_MULTIPLIER: float = 0.5       ## 升级费用系数

## 克制系统常量
## 参考: design/gdd/counter-system.md
const COUNTER_MULTIPLIER: float = 1.3      ## 克制方伤害加成
const COUNTERED_MULTIPLIER: float = 0.8    ## 被克制方伤害减少

## 克制关系表
## key: 攻击方职业, value: 被其克制的职业列表
const COUNTER_RELATIONS: Dictionary = {
	ClassType.WARRIOR: [ClassType.KNIGHT],           ## 战士克制骑士
	ClassType.ARCHER: [ClassType.MAGE, ClassType.HEALER],  ## 弓手克制法师、治疗
	ClassType.MAGE: [ClassType.KNIGHT],              ## 法师克制骑士
	ClassType.KNIGHT: [ClassType.HEALER],            ## 骑士克制治疗
	ClassType.HEALER: [],                            ## 治疗不克制任何职业
	ClassType.ROGUE: [ClassType.MAGE, ClassType.ARCHER],    ## 刺客克制法师、弓手
}


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
		ClassType.ROGUE:
			return "刺客"
	return "未知"


## 检查攻击方是否克制目标方
## 返回: 1 = 克制, -1 = 被克制, 0 = 无克制
static func get_counter_status(attacker: ClassType, defender: ClassType) -> int:
	# 同职业无克制
	if attacker == defender:
		return 0

	# 检查攻击方是否克制防守方
	if COUNTER_RELATIONS.has(attacker):
		if defender in COUNTER_RELATIONS[attacker]:
			return 1  # 攻击方克制防守方

	# 检查防守方是否克制攻击方
	if COUNTER_RELATIONS.has(defender):
		if attacker in COUNTER_RELATIONS[defender]:
			return -1  # 攻击方被防守方克制

	return 0  # 无克制关系


## 获取克制伤害倍率
## 参考: design/gdd/counter-system.md
static func get_counter_multiplier(attacker: ClassType, defender: ClassType) -> float:
	var status = get_counter_status(attacker, defender)
	match status:
		1:
			return COUNTER_MULTIPLIER   # 克制方 +30%
		-1:
			return COUNTERED_MULTIPLIER # 被克制方 -20%
		_:
			return 1.0  # 无克制


## 获取克制状态描述（用于 UI 显示）
static func get_counter_status_text(attacker: ClassType, defender: ClassType) -> String:
	var status = get_counter_status(attacker, defender)
	match status:
		1:
			return "克制"
		-1:
			return "被克制"
		_:
			return ""
