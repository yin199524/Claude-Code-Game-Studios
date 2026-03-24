# Sprint 5 — 2026-03-24 to 2026-03-30

## Sprint Goal

实现克制系统和完善关卡解锁流程，增加战斗策略深度。

## Capacity

- Total days: 7
- Buffer (20%): 1.4 days
- Available: ~5.5 days of effective work

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T1 | 设计克制系统 GDD | game-designer | 0.25 | — | ✅ Done |
| T2 | 实现克制系统 | gameplay-programmer | 0.5 | T1 | ✅ Done |
| T3 | 添加克制 UI 提示 | ui-programmer | 0.25 | T2 | ✅ Done |
| T4 | 完善关卡解锁逻辑 | gameplay-programmer | 0.25 | — | ✅ Done |
| T5 | 添加解锁动画/音效 | ui-programmer | 0.25 | T4 | ✅ Done |
| T6 | 扩展到 5 个关卡 | game-designer | 0.25 | — | ✅ Done |

**Total Must Have: 1.75 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T7 | 关卡预览弹窗 | ui-programmer | 0.5 | T6 | ✅ Done |
| T8 | 单位推荐提示 | ui-programmer | 0.25 | T1 | ✅ Done |
| T9 | 战斗伤害详情 | ui-programmer | 0.25 | T2 | ✅ Done |

**Total Should Have: 1 day**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T10 | 克制图标显示 | ui-programmer | 0.25 | T3 | ✅ Done |
| T11 | 更多敌人类型 | game-designer | 0.25 | T6 | ✅ Done |
| T12 | 关卡星级评价 | gameplay-programmer | 0.25 | T4 | ✅ Done |

**Total Nice to Have: 0.75 days**

---

## Total Estimated: 3.5 days (within capacity)

---

## Definition of Done

- [x] 克制系统影响伤害计算
- [x] 关卡解锁流程正确
- [x] 有 5 个可玩关卡
- [x] UI 显示克制信息（伤害数字颜色）
- [x] 解锁动画和音效
- [x] 关卡预览弹窗（显示敌人详情和克制提示）
- [x] 战斗伤害详情（显示克制倍率 +30%/-20%）
- [x] 单位职业图标显示
- [x] 2 个新敌人类型（精英战士、暗影法师）
- [x] 关卡星级评价系统
