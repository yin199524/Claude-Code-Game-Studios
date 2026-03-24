# 敌人系统 (Enemy System)

> **Status**: Designed (pending review)
> **Author**: user + game-designer
> **Last Updated**: 2026-03-24
> **Implements Pillar**: 策略深度（敌人提供挑战）

## Overview

敌人系统定义敌人的配置和行为。敌人使用与玩家单位相同的数据定义（UnitDefinition），但有额外的关卡配置：位置、数量、强化参数。

## Player Fantasy

敌人应该提供有意义的挑战，让玩家的策略有用武之地。不同关卡的敌人组合应该有不同的"解法"，鼓励玩家尝试不同的布局。

## Detailed Design

### Core Rules

#### 1. 敌人定义

敌人使用 `UnitDefinition`，与玩家单位共享数据结构。

#### 2. 敌人配置（关卡中）

```gdscript
class_name EnemySpawn extends Resource

@export var unit_id: String        # 引用 UnitDefinition
@export var position: Vector2i     # 初始位置
@export var level_modifier: float = 1.0  # 属性加成
```

#### 3. 敌人行为

- 使用相同的目标选择 AI
- 使用相同的伤害计算系统
- 目标优先级：最近的我方单位

#### 4. 敌人与玩家单位的区别

| 属性 | 玩家单位 | 敌人 |
|------|----------|------|
| 控制权 | 玩家布局 | 关卡预置 |
| 目标选择 | 自动（AI）| 自动（AI）|
| 可收集 | 是 | 否 |

### Interactions with Other Systems

| 系统 | 接口 | 用途 |
|------|------|------|
| **单位数据定义** | UnitDefinition | 共享单位定义 |
| **关卡系统** | EnemySpawn[] | 关卡配置敌人 |
| **自动战斗系统** | UnitInstance | 战斗实例 |

## Formulas

### 敌人属性强化

```
effective_hp = base_hp × level_modifier
effective_attack = base_attack × level_modifier
```

## Edge Cases

| 情况 | 处理方式 |
|------|----------|
| 敌人单位 ID 不存在 | 数据验证失败，关卡无法加载 |
| 敌人位置超出网格 | 数据验证警告，调整到有效位置 |

## Dependencies

| 系统 | 依赖内容 | 状态 |
|------|----------|------|
| **单位数据定义** | UnitDefinition | ✅ 已设计 |

## Acceptance Criteria

- [ ] **AC1**: 敌人正确使用单位定义
- [ ] **AC2**: 敌人正确放置在关卡中
- [ ] **AC3**: 敌人强化参数正确应用

## Open Questions

| # | 问题 | 状态 |
|---|------|------|
| 1 | 是否需要敌人 AI 行为差异？ | 待定 |
