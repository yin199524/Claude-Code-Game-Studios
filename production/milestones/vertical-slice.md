# Milestone: Vertical Slice

**Status**: Complete
**Start Date**: 2026-03-24
**End Date**: 2026-03-24

---

## Goal

完善游戏体验，添加克制系统、关卡解锁流程，以及更完善的 UI 反馈，提供一个完整的游戏循环体验。

---

## Scope

### Must Have (Vertical Slice Systems)

| # | System | Category | Status | Dependencies |
|---|--------|----------|--------|--------------|
| 1 | 存档系统完善 | Infrastructure | ✅ Complete | 玩家数据 ✅ |
| 2 | 克制系统 | Core | ✅ Complete | 单位数据定义 ✅ |
| 3 | 关卡解锁系统 | Meta | ✅ Complete | 关卡系统 ✅, 玩家数据 ✅ |
| 4 | 布局编辑 UI 增强 | Presentation | ✅ Complete | 网格布局系统 ✅ |
| 5 | 战斗 UI 增强 | Presentation | ✅ Complete | 自动战斗系统 ✅ |

### Already Implemented (from MVP)

- ✅ 存档系统基础 (SaveManager)
- ✅ 关卡解锁基础 (LevelDatabase.is_level_unlocked)
- ✅ 布局编辑场景 (battle_setup.tscn)
- ✅ 战斗场景和 HUD (battle_scene.tscn)
- ✅ 场景过渡动画
- ✅ 粒子效果
- ✅ 音效系统

### Content Additions

- **克制关系**: 职业间相克机制
- **更多关卡**: 扩展到 5 个关卡
- **关卡预览**: 显示敌人详情
- **存档槽**: 支持多存档

### Explicitly NOT in Vertical Slice

- 单位升级系统
- 抽卡系统
- 成就系统
- PVP

---

## Acceptance Criteria

- [x] 克制系统影响战斗结果
- [x] 关卡按顺序解锁
- [x] 存档正确保存和加载
- [x] UI 反馈完整流畅
- [x] 可完整游玩 5 个关卡

---

## Technical Requirements

- 存档数据持久化
- 克制关系计算
- 关卡依赖链验证

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| 克制系统平衡 | Medium | Medium | 预留调整参数 |
| 存档兼容性 | Low | High | 版本控制 |

---

## Sprint Breakdown

| Sprint | Focus | Target |
|--------|-------|--------|
| Sprint 5 | 克制系统 + 关卡解锁完善 | 战斗深度 |
| Sprint 6 | 存档系统完善 + UI 增强 | 完整体验 |
