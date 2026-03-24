# Milestone: Alpha

**Status**: Planned
**Start Date**: TBD
**Target End Date**: TBD

---

## Goal

实现所有核心功能（不含 PVP），扩展内容规模到 15+ 单位和 20+ 关卡，添加单位升级系统和协同机制，提供完整的单人游戏体验。

---

## Scope

### Must Have (Alpha Systems)

| # | System | Category | Status | Dependencies |
|---|--------|----------|--------|--------------|
| 1 | 单位升级系统 | Core | Not Started | 玩家数据 ✅, 单位数据定义 ✅ |
| 2 | 单位协同系统 | Core | Not Started | 单位数据定义 ✅ |
| 3 | 进度系统 | Meta | Not Started | 玩家数据 ✅, 存档系统 ✅ |
| 4 | 主菜单 UI 增强 | Presentation | Partial | 存档系统 ✅ |
| 5 | 商店 UI 增强 | Presentation | Partial | 商店系统 ✅ |

### Content Expansion

| Content | Vertical Slice | Alpha Target |
|---------|---------------|--------------|
| 可玩单位 | 5 | 15 |
| 敌人类型 | 7 | 12 |
| 关卡数量 | 5 | 20 |
| 关卡难度 | 5 级 | 5 世界 × 4 关 |

### New Features

- **单位升级**: 使用金币或材料提升单位属性
- **协同效果**: 特定单位组合获得额外加成
- **世界地图**: 关卡按世界分组，每个世界有独特主题
- **成就系统**: 解锁成就获得奖励
- **每日任务**: 提供长期游玩目标

### Explicitly NOT in Alpha

- PVP 系统
- 排行榜
- 社交功能
- 云存档

---

## Acceptance Criteria

- [ ] 单位可通过金币升级，属性正确提升
- [ ] 至少 3 种协同效果可用
- [ ] 4 个世界共 16+ 关卡可玩
- [ ] 15+ 单位可收集
- [ ] 完整的单人游戏循环（从开始到"通关"）

---

## Technical Requirements

- 升级数据持久化
- 协同效果计算
- 世界/关卡元数据
- 成就追踪系统

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| 升级平衡 | High | Medium | 预留调整参数，收集测试数据 |
| 内容量过大 | Medium | High | 分批添加，优先核心内容 |
| 协同效果复杂度 | Medium | Medium | 从简单协同开始，逐步迭代 |

---

## Sprint Breakdown

| Sprint | Focus | Target |
|--------|-------|--------|
| Sprint 7 | 单位升级系统 | 单位成长 |
| Sprint 8 | 协同系统 + 世界地图 | 策略深度 |
| Sprint 9 | 内容扩展 (单位/关卡) | 内容丰富 |
| Sprint 10 | 成就系统 + UI 完善 | 长期目标 |
| Sprint 11 | 平衡调整 + Bug 修复 | 打磨体验 |

---

## Content Plan

### 新单位 (10 个)

| ID | 名称 | 职业 | 稀有度 | 特点 |
|----|------|------|--------|------|
| unit_spearman | 长枪兵 | WARRIOR | COMMON | 克制骑兵 |
| unit_hunter | 猎人 | ARCHER | COMMON | 克制飞行 |
| unit_pyromancer | 火法师 | MAGE | RARE | 范围伤害 |
| unit_cryomancer | 冰法师 | MAGE | RARE | 减速效果 |
| unit_paladin | 圣骑士 | KNIGHT | EPIC | 治疗+护盾 |
| unit_assassin | 刺客 | ROGUE | EPIC | 暴击伤害 |
| unit_priest | 牧师 | HEALER | RARE | 群体治疗 |
| unit_necromancer | 死灵法师 | MAGE | LEGENDARY | 召唤亡灵 |
| unit_dragon_knight | 龙骑士 | KNIGHT | LEGENDARY | 高伤害 |
| unit_angel | 天使 | HEALER | LEGENDARY | 复活队友 |

### 协同效果 (3 种)

| 名称 | 条件 | 效果 |
|------|------|------|
| 战士兄弟 | 2+ 战士单位 | 所有战士 +10% 攻击 |
| 法术共鸣 | 2+ 法师单位 | 法术伤害 +15% |
| 前后排 | 近战在前排，远程在后排 | 远程 +10% 生存 |

### 世界主题

| 世界 | 主题 | 关卡数 | 敌人特点 |
|------|------|--------|----------|
| 1 | 森林 | 4 | 基础敌人 |
| 2 | 沙漠 | 4 | 高护甲敌人 |
| 3 | 冰原 | 4 | 减速效果 |
| 4 | 火山 | 4 | 高伤害敌人 |
| 5 | 暗影 | 4 | Boss 战 |
