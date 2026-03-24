# 关卡系统 (Level System)

> **Status**: Designed (pending review)
> **Author**: user + game-designer + level-designer
> **Last Updated**: 2026-03-24
> **Implements Pillar**: 策略深度（关卡设计挑战）

## Overview

关卡系统定义战斗场景的配置，包括敌人配置、玩家单位上限、奖励和关卡元数据。关卡是玩家挑战的基本单位，每个关卡提供独特的敌人组合和战斗条件。

## Player Fantasy

关卡应该提供清晰的挑战目标和进度感。玩家应该能够看到关卡的难度预览，知道需要什么策略，胜利后获得满足感。

## Detailed Design

### Core Rules

#### 1. 关卡定义

```gdscript
class_name LevelDefinition extends Resource

# 元数据
@export var id: String
@export var display_name: String
@export var description: String
@export var difficulty: int = 1  # 1-5

# 战斗配置
@export var grid_size: Vector2i = Vector2i(3, 3)
@export var player_unit_limit: int = 5
@export var enemy_spawns: Array[EnemySpawn] = []

# 奖励
@export var gold_reward: int = 100
@export var possible_unit_rewards: Array[String] = []  # Unit IDs

# 解锁条件
@export var required_level: String = ""  # 前置关卡 ID
```

#### 2. 关卡列表

- MVP: 3 个关卡（难度递进）
- 关卡按顺序解锁
- 完成所有关卡 = 游戏通关（MVP）

#### 3. 关卡进度

存储在 `PlayerData.level_progress` 中：
- 是否完成
- 最佳时间
- 星级评价（如果需要）

### Interactions with Other Systems

| 系统 | 接口 | 用途 |
|------|------|------|
| **敌人系统** | EnemySpawn[] | 获取敌人配置 |
| **网格布局系统** | player_unit_limit | 限制单位数量 |
| **战斗状态机** | LevelDefinition | 开始战斗 |
| **资源系统** | gold_reward | 发放奖励 |
| **关卡解锁系统** | required_level | 解锁逻辑 |

## Formulas

### 关卡难度估算

```
difficulty_score = Σ(enemy.hp × enemy.attack) / player_unit_limit
```

## Edge Cases

| 情况 | 处理方式 |
|------|----------|
| 关卡无敌人 | 数据验证警告 |
| 关卡奖励为 0 | 允许，可能为教程关卡 |
| 前置关卡不存在 | 解锁条件忽略 |

## Dependencies

| 系统 | 依赖内容 | 状态 |
|------|----------|------|
| **敌人系统** | EnemySpawn | ✅ 已设计 |
| **自动战斗系统** | 战斗执行 | ✅ 已设计 |

## Tuning Knobs

| 旋钮 | 当前值 | 说明 |
|------|--------|------|
| `DEFAULT_GRID_SIZE` | 3×3 | 默认网格大小 |
| `DEFAULT_UNIT_LIMIT` | 5 | 默认单位上限 |

## Acceptance Criteria

- [ ] **AC1**: 关卡正确加载和显示
- [ ] **AC2**: 敌人正确放置
- [ ] **AC3**: 单位上限正确限制
- [ ] **AC4**: 奖励正确发放

## Open Questions

| # | 问题 | 状态 |
|---|------|------|
| 1 | 是否需要星级评价系统？ | 待定 |
| 2 | 是否需要关卡重玩奖励？ | 待定 |
