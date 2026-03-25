# Systems Index: 禅意军团 (Zen Legion)

> **Status**: Draft
> **Created**: 2026-03-23
> **Last Updated**: 2026-03-23
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

禅意军团是一款放置自动战斗游戏，核心玩法是「布局 → 观战 → 收集奖励 → 购买」。游戏需要约 21 个系统，分为 Foundation（数据定义）、Core（玩法核心）、Feature（功能扩展）、Content（内容）、Meta（进度）、Presentation（UI）六个层级。核心支柱是「策略深度」和「收集满足」，因此布局系统和单位系统是设计重点。

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | 单位数据定义 | Foundation | MVP | Designed | design/gdd/unit-data-definition.md | — |
| 2 | 玩家数据 | Foundation | MVP | Designed | design/gdd/player-data.md | — |
| 3 | 存档系统 | Infrastructure | VS | Not Started | — | 玩家数据 |
| 4 | 伤害计算系统 | Core | MVP | Designed | design/gdd/damage-calculation.md | 单位数据定义 |
| 5 | 目标选择 AI | Core | MVP | Designed | design/gdd/target-selection-ai.md | 单位数据定义 |
| 6 | 网格布局系统 | Core | MVP | Designed | design/gdd/grid-layout-system.md | 单位数据定义 |
| 7 | 战斗状态机 | Core | MVP | Designed | design/gdd/battle-state-machine.md | 网格布局系统 |
| 8 | 自动战斗系统 | Core | MVP | Designed | design/gdd/auto-battle-system.md | 战斗状态机, 伤害计算系统, 目标选择 AI |
| 9 | 资源系统 | Core | MVP | Designed | design/gdd/resource-system.md | 玩家数据 |
| 10 | 克制系统 | Core | VS | Not Started | — | 单位数据定义 |
| 11 | 单位协同系统 | Core | Alpha | Not Started | — | 单位数据定义 |
| 12 | 商店系统 | Feature | MVP | Designed | design/gdd/shop-system.md | 单位数据定义, 资源系统 |
| 13 | 敌人系统 | Content | MVP | Designed | design/gdd/enemy-system.md | 单位数据定义 |
| 14 | 关卡系统 | Content | MVP | Designed | design/gdd/level-system.md | 自动战斗系统, 敌人系统 |
| 15 | 关卡解锁系统 | Meta | VS | Not Started | — | 关卡系统, 玩家数据 |
| 16 | 进度系统 | Meta | Alpha | ✅ Complete | — | 玩家数据, 存档系统, 关卡解锁系统 |
| 17 | 主菜单 UI | Presentation | Alpha | 🔄 In Progress | — | 存档系统, 进度系统 |
| 18 | 关卡选择 UI | Presentation | Alpha | ✅ Complete | — | 关卡系统, 关卡解锁系统, 世界地图系统 |
| 19 | 布局编辑 UI | Presentation | VS | ✅ Complete | — | 网格布局系统, 单位数据定义, 玩家数据 |
| 20 | 战斗 UI | Presentation | VS | ✅ Complete | — | 自动战斗系统, 战斗状态机, 伤害计算系统 |
| 21 | 商店 UI | Presentation | Alpha | 🔄 In Progress | — | 商店系统, 资源系统, 单位数据定义 |
| 22 | 世界地图系统 | Meta | Alpha | ✅ Complete | design/gdd/world-map-system.md | 关卡系统, 关卡解锁系统 |
| 23 | 单位升级系统 | Core | Alpha | ✅ Complete | design/gdd/unit-upgrade-system.md | 玩家数据, 单位数据定义 |
| 24 | 单位协同系统 | Core | Alpha | ✅ Complete | design/gdd/synergy-system.md | 单位数据定义 |
| 25 | 成就系统 | Meta | Alpha | 🔄 In Progress | design/gdd/achievement-system.md | 存档系统, 各游戏系统 |
| 26 | 每日任务系统 | Meta | Alpha | 🔲 Planned | design/gdd/daily-mission-system.md | 存档系统, 各游戏系统 |

---

## Categories

| Category | Description | Systems in This Game |
|----------|-------------|---------------------|
| **Foundation** | 数据定义，无依赖的基础 | 单位数据定义, 玩家数据 |
| **Infrastructure** | 基础设施系统 | 存档系统 |
| **Core** | 核心玩法系统 | 伤害计算系统, 目标选择 AI, 网格布局系统, 战斗状态机, 自动战斗系统, 资源系统, 克制系统, 单位协同系统 |
| **Feature** | 功能扩展系统 | 商店系统 |
| **Content** | 游戏内容系统 | 敌人系统, 关卡系统 |
| **Meta** | 进度和元游戏系统 | 关卡解锁系统, 进度系统, 世界地图系统, 成就系统, 每日任务系统 |
| **Presentation** | UI 和表现系统 | 主菜单 UI, 关卡选择 UI, 布局编辑 UI, 战斗 UI, 商店 UI |

---

## Priority Tiers

| Tier | Definition | Target Milestone | Systems Count |
|------|------------|------------------|---------------|
| **MVP** | 验证核心循环「布局 → 战斗 → 奖励 → 购买」 | 第一可玩原型 | 11 |
| **Vertical Slice** | 一个完整区域的完整体验 | 垂直切片 / Demo | 5 |
| **Alpha** | 所有功能粗略实现 | Alpha 里程碑 | 9 |

---

## Dependency Map

### Foundation Layer (no dependencies)

1. **单位数据定义** — 所有单位属性、技能、稀有度的数据结构，其他 9 个系统依赖它
2. **玩家数据** — 玩家存档的数据结构（拥有的单位、金币、进度）

### Infrastructure Layer (depends on foundation)

1. **存档系统** — depends on: 玩家数据

### Core Layer (depends on foundation/infrastructure)

1. **伤害计算系统** — depends on: 单位数据定义
2. **目标选择 AI** — depends on: 单位数据定义
3. **网格布局系统** — depends on: 单位数据定义
4. **资源系统** — depends on: 玩家数据
5. **战斗状态机** — depends on: 网格布局系统
6. **自动战斗系统** — depends on: 战斗状态机, 伤害计算系统, 目标选择 AI
7. **克制系统** — depends on: 单位数据定义
8. **单位协同系统** — depends on: 单位数据定义

### Feature Layer (depends on core)

1. **商店系统** — depends on: 单位数据定义, 资源系统

### Content Layer (depends on core/feature)

1. **敌人系统** — depends on: 单位数据定义
2. **关卡系统** — depends on: 自动战斗系统, 敌人系统

### Meta Layer (depends on content)

1. **关卡解锁系统** — depends on: 关卡系统, 玩家数据
2. **进度系统** — depends on: 玩家数据, 存档系统, 关卡解锁系统

### Presentation Layer (depends on everything)

1. **布局编辑 UI** — depends on: 网格布局系统, 单位数据定义, 玩家数据
2. **战斗 UI** — depends on: 自动战斗系统, 战斗状态机, 伤害计算系统
3. **主菜单 UI** — depends on: 存档系统, 进度系统
4. **关卡选择 UI** — depends on: 关卡系统, 关卡解锁系统
5. **商店 UI** — depends on: 商店系统, 资源系统, 单位数据定义

---

## Recommended Design Order

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | 单位数据定义 | MVP | Foundation | game-designer | M |
| 2 | 玩家数据 | MVP | Foundation | game-designer | S |
| 3 | 伤害计算系统 | MVP | Core | game-designer, systems-designer | M |
| 4 | 目标选择 AI | MVP | Core | game-designer, ai-programmer | M |
| 5 | 网格布局系统 | MVP | Core | game-designer, systems-designer | M |
| 6 | 战斗状态机 | MVP | Core | game-designer | S |
| 7 | 自动战斗系统 | MVP | Core | game-designer, ai-programmer | L |
| 8 | 资源系统 | MVP | Core | game-designer | S |
| 9 | 敌人系统 | MVP | Content | game-designer | M |
| 10 | 关卡系统 | MVP | Content | game-designer, level-designer | M |
| 11 | 商店系统 | MVP | Feature | game-designer, economy-designer | M |
| 12 | 存档系统 | VS | Infrastructure | gameplay-programmer | S |
| 13 | 克制系统 | VS | Core | game-designer | S |
| 14 | 关卡解锁系统 | VS | Meta | game-designer | S |
| 15 | 布局编辑 UI | VS | Presentation | ux-designer, ui-programmer | M |
| 16 | 战斗 UI | VS | Presentation | ux-designer, ui-programmer | M |
| 17 | 单位协同系统 | Alpha | Core | game-designer | M |
| 18 | 进度系统 | Alpha | Meta | game-designer | M |
| 19 | 主菜单 UI | Alpha | Presentation | ux-designer, ui-programmer | S |
| 20 | 关卡选择 UI | Alpha | Presentation | ux-designer, ui-programmer | S |
| 21 | 商店 UI | Alpha | Presentation | ux-designer, ui-programmer | M |

**Effort estimates**: S = 1 session, M = 2-3 sessions, L = 4+ sessions

---

## Circular Dependencies

**None found.** All dependencies form a directed acyclic graph (DAG).

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| **单位数据定义** | Design | 9 个系统依赖它；设计错误会传播到所有依赖系统 | 设计完成后立即 review，原型验证后再扩展 |
| **自动战斗系统** | Technical | 核心玩法的核心；AI 逻辑需要足够智能但可预测 | 早期原型，多轮迭代 |
| **关卡系统** | Scope | 依赖敌人系统和自动战斗系统；是内容入口 | 确保前置系统稳定后再设计 |
| **伤害计算系统** | Design | 平衡敏感；公式设计影响整个战斗体验 | 建立清晰的公式框架，预留调整参数 |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 21 |
| Design docs started | 11 |
| Design docs reviewed | 0 |
| Design docs approved | 0 |
| MVP systems designed | 11 / 11 ✅ |
| Vertical Slice systems designed | 5 / 5 ✅ |
| Alpha systems designed | 7 / 9 🔄 |

---

## Next Steps

- [x] Design all MVP systems (11/11 完成)
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check pre-production` to validate readiness for implementation
- [ ] Prototype 自动战斗系统 early (`/prototype auto-battle`)
- [ ] Plan first sprint with `/sprint-plan new`
