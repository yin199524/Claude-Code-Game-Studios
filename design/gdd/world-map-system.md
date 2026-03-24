# 世界地图系统 (World Map System)

> **Status**: Designed
> **Author**: game-designer
> **Last Updated**: 2026-03-26
> **Implements Pillar**: 进度系统（关卡组织）

## Overview

世界地图系统将关卡按主题世界分组，每个世界有独特的视觉风格和敌人特点。玩家需要按顺序解锁世界，每个世界的最后一关为 Boss 战。

## Player Fantasy

玩家在关卡选择界面看到一个大地图——"我刚完成了森林世界的所有关卡，现在可以进入沙漠世界了！"这种进度感让游戏更有冒险的史诗感。

## Detailed Design

### Core Rules

1. **世界结构**: 5 个世界，每个世界 4 关卡
2. **解锁条件**: 完成前一个世界的所有关卡
3. **主题差异**: 每个世界有独特的敌人类型和视觉风格
4. **Boss 战**: 每个世界最后一关为 Boss 战

### 世界列表

| ID | 名称 | 主题 | 关卡数 | 敌人特点 | 解锁条件 |
|----|------|------|--------|----------|----------|
| world_forest | 翠绿森林 | 森林 | 4 | 基础敌人 | 初始解锁 |
| world_desert | 灼热沙漠 | 沙漠 | 4 | 高护甲敌人 | 完成森林 |
| world_ice | 寒冰冻土 | 冰原 | 4 | 减速效果 | 完成沙漠 |
| world_volcano | 烈焰火山 | 火山 | 4 | 高伤害敌人 | 完成冰原 |
| world_shadow | 暗影深渊 | 暗影 | 4 | Boss 战 | 完成火山 |

### 世界数据结构

```gdscript
class_name WorldDefinition
extends Resource

## 世界唯一标识符
@export var id: String

## 显示名称
@export var display_name: String

## 主题类型
@export var theme: WorldTheme

## 关卡 ID 列表
@export var level_ids: Array[String]

## 解锁条件（前一个世界 ID）
@export var unlock_world_id: String

## 主题颜色
@export var theme_color: Color

## 背景图片路径
@export var background_path: String

enum WorldTheme {
    FOREST,
    DESERT,
    ICE,
    VOLCANO,
    SHADOW
}
```

### 关卡解锁逻辑

```
玩家选择世界 → 检查世界是否解锁 → 显示关卡列表 → 选择关卡 → 进入战斗
```

### 世界完成条件

```
世界中所有关卡获得至少 1 星 → 世界完成 → 解锁下一世界
```

## Formulas

### 世界进度计算

```
world_progress = completed_levels / total_levels × 100%

其中:
- completed_levels: 已完成关卡数
- total_levels: 世界总关卡数
```

### 世界完成奖励

```
world_completion_gold = world_index × 200

其中:
- world_index: 世界序号 (1-5)
- 完成森林获得 200 金币，完成暗影深渊获得 1000 金币
```

## Edge Cases

### 1. 初始世界

| 情况 | 处理方式 |
|------|----------|
| 新玩家 | 森林世界默认解锁 |
| 无存档 | 森林世界默认解锁 |

### 2. 世界未解锁

| 情况 | 处理方式 |
|------|----------|
| 点击未解锁世界 | 显示"完成前置世界解锁"提示 |
| 解锁条件未满足 | 显示解锁进度 |

### 3. 世界完成

| 情况 | 处理方式 |
|------|----------|
| 所有世界完成 | 显示"恭喜通关" |
| 最后一个世界 | 无下一世界解锁 |

## Dependencies

### 上游依赖

| 系统 | 依赖内容 | 状态 |
|------|----------|------|
| **关卡系统** | 关卡定义 | ✅ 已实现 |
| **存档系统** | 完成进度 | ✅ 已实现 |
| **玩家数据** | 关卡解锁状态 | ✅ 已实现 |

### 下游依赖

| 系统 | 依赖内容 |
|------|----------|
| **关卡选择 UI** | 世界分组显示 |
| **敌人系统** | 主题相关敌人 |

## Tuning Knobs

| 旋钮 | 当前值 | 安全范围 | 影响 |
|------|--------|----------|------|
| `LEVELS_PER_WORLD` | 4 | 3-6 | 每个世界关卡数 |
| `WORLD_COMPLETION_BONUS` | 200 | 100-500 | 世界完成奖励基数 |

## Visual/Audio Requirements

### 视觉风格

| 世界 | 主色调 | 背景 |
|------|--------|------|
| 森林 | 绿色 | 树木、草地 |
| 沙漠 | 黄色 | 沙丘、仙人掌 |
| 冰原 | 蓝色 | 冰川、雪地 |
| 火山 | 红色 | 熔岩、火山 |
| 暗影 | 紫色 | 暗影、虚空 |

### UI 反馈

| 场景 | 效果 |
|------|------|
| 世界解锁 | 光芒特效 |
| 世界完成 | 烟花特效 |
| Boss 关卡 | 红色边框 |

## Acceptance Criteria

- [ ] 5 个世界正确定义
- [ ] 世界按解锁顺序显示
- [ ] 点击未解锁世界显示提示
- [ ] 完成世界解锁下一世界
- [ ] 世界主题有视觉区分
