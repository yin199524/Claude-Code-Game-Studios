# Milestone: MVP (Minimum Viable Product)

**Status**: In Progress
**Start Date**: 2026-03-24
**Target End Date**: TBD

---

## Goal

验证核心循环「布局 → 战斗 → 奖励 → 购买」足够有趣，玩家愿意持续进行多次。

---

## Scope

### Must Have (MVP Systems)

| # | System | Category | Status | Dependencies |
|---|--------|----------|--------|--------------|
| 1 | 单位数据定义 | Foundation | Designed | — |
| 2 | 玩家数据 | Foundation | Designed | — |
| 3 | 伤害计算系统 | Core | Designed | #1 |
| 4 | 目标选择 AI | Core | Designed | #1 |
| 5 | 网格布局系统 | Core | Designed | #1 |
| 6 | 战斗状态机 | Core | Designed | #5 |
| 7 | 自动战斗系统 | Core | Designed | #3, #4, #6 |
| 8 | 资源系统 | Core | Designed | #2 |
| 9 | 敌人系统 | Content | Designed | #1 |
| 10 | 关卡系统 | Content | Designed | #7, #9 |
| 11 | 商店系统 | Feature | Designed | #1, #8 |

### Content Scope

- **Units**: 5 basic units (Warrior, Archer, Mage, Knight, Healer)
- **Levels**: 3 levels (difficulty progression)
- **Resources**: Gold only

### Explicitly NOT in MVP

- 抽卡系统
- PVP/排行榜
- 单位升级系统
- 多资源类型
- 关卡地图系统

---

## Acceptance Criteria

- [ ] 玩家可以放置单位到 3x3 网格
- [ ] 战斗自动进行，单位按 AI 选择目标
- [ ] 战斗有明确的胜利/失败结果
- [ ] 胜利后获得金币奖励
- [ ] 金币可以购买新单位
- [ ] 核心循环可以重复进行 3+ 次而不无聊

---

## Technical Requirements

- Target FPS: 60
- Frame budget: 16.6ms
- Platform: Mobile (primary)
- Engine: Godot 4.6

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| 核心循环不够有趣 | Medium | High | 早期原型验证，快速迭代 |
| 平衡问题 | Medium | Medium | 预留调整参数，数据驱动 |
| 范围蔓延 | High | Medium | 严格遵守 MVP 定义 |

---

## Sprint Breakdown

| Sprint | Focus | Target |
|--------|-------|--------|
| Sprint 1 | Foundation + 核心计算 | 数据层 + 战斗逻辑 |
| Sprint 2 | 战斗系统 | 完整战斗流程 |
| Sprint 3 | 内容 + 商店 | 关卡、敌人、商店 |
| Sprint 4 | 打磨 + 集成 | UI、视觉反馈、测试 |
