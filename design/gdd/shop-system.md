# 商店系统 (Shop System)

> **Status**: Designed (pending review)
> **Author**: user + game-designer + economy-designer
> **Last Updated**: 2026-03-24
> **Implements Pillar**: 收集满足（购买单位的满足感）

## Overview

商店系统允许玩家使用金币购买单位。MVP 阶段为直接购买（无抽卡），商店展示可购买的单位和价格。购买后单位添加到玩家拥有的单位列表。

## Player Fantasy

商店是收集体验的核心。玩家应该能够浏览可用单位，了解每个单位的特点，做出购买决策。购买应该带来期待和满足感。

## Detailed Design

### Core Rules

#### 1. 商店内容

```gdscript
class_name ShopDefinition extends Resource

@export var available_units: Array[String]  # UnitDefinition IDs
@export var rotation_enabled: bool = false  # 商品轮换（后期）
```

#### 2. 购买流程

```
1. 玩家选择单位
2. 检查金币余额
3. 扣除金币
4. 添加单位到玩家数据
5. 显示购买成功
```

#### 3. 价格规则

- 价格由 `UnitDefinition.price` 定义
- 价格受稀有度影响（见单位数据定义）
- MVP: 固定价格，无折扣

#### 4. 库存规则

- MVP: 无库存限制，可重复购买同一单位
- 后期: 可能有库存或限时商品

### Interactions with Other Systems

| 系统 | 接口 | 用途 |
|------|------|------|
| **单位数据定义** | UnitDefinition | 获取单位信息和价格 |
| **资源系统** | spend_gold() | 扣除金币 |
| **玩家数据** | owned_units | 添加单位 |

## Formulas

### 购买验证

```
can_purchase(unit) = player.gold >= unit.price
```

### 购买执行

```
player.gold -= unit.price
player.owned_units.append(OwnedUnit.new(unit.id))
```

## Edge Cases

| 情况 | 处理方式 |
|------|----------|
| 金币不足 | 拒绝购买，提示"金币不足" |
| 单位已在库存中 | MVP: 允许重复购买 |
| 单位不存在 | 商店不显示该单位 |

## Dependencies

| 系统 | 依赖内容 | 状态 |
|------|----------|------|
| **单位数据定义** | UnitDefinition | ✅ 已设计 |
| **资源系统** | 金币管理 | ✅ 已设计 |
| **玩家数据** | owned_units | ✅ 已设计 |

## Tuning Knobs

| 旋钮 | 说明 |
|------|------|
| 单位价格 | 见单位数据定义 |

## Acceptance Criteria

- [ ] **AC1**: 商店正确显示可购买单位
- [ ] **AC2**: 金币不足时拒绝购买
- [ ] **AC3**: 购买后单位添加到玩家数据
- [ ] **AC4**: 金币正确扣除

## Open Questions

| # | 问题 | 状态 |
|---|------|------|
| 1 | 是否需要抽卡系统？ | 后期功能 |
| 2 | 是否需要商品轮换？ | 后期功能 |
| 3 | 重复购买单位是否有用途？ | 待定 |
