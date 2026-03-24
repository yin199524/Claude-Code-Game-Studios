# Sprint 7 — 2026-03-25 to 2026-03-31

## Sprint Goal

实现单位升级系统，让玩家可以用金币提升单位属性，增加收集深度和长期目标。

## Capacity

- Total days: 7
- Buffer (20%): 1.4 days
- Available: ~5.5 days of effective work

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T1 | 设计单位升级系统 GDD | game-designer | 0.25 | — | ✅ Complete |
| T2 | 添加单位等级和经验数据 | gameplay-programmer | 0.25 | T1 | ✅ Complete |
| T3 | 实现升级逻辑和费用计算 | gameplay-programmer | 0.5 | T2 | ✅ Complete |
| T4 | 商店升级 UI | ui-programmer | 0.5 | T3 | ✅ Complete |
| T5 | 升级特效和音效 | ui-programmer | 0.25 | T4 | ✅ Complete |

**Total Must Have: 1.75 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T6 | 单位详情面板 | ui-programmer | 0.5 | T4 | ✅ Complete |
| T7 | 批量升级功能 | gameplay-programmer | 0.25 | T3 | 🔲 Pending |
| T8 | 升级预览 (显示属性变化) | ui-programmer | 0.25 | T4 | ✅ Complete |

**Total Should Have: 1 day**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T9 | 升级动画 (单位发光) | ui-programmer | 0.25 | T5 | 🔲 Pending |
| T10 | 升级成就 | gameplay-programmer | 0.25 | T3 | 🔲 Pending |

**Total Nice to Have: 0.5 days**

---

## Total Estimated: 3.25 days (within capacity)

---

## Definition of Done

- [x] 单位可通过金币升级
- [x] 升级后属性正确提升
- [x] UI 显示升级选项和费用
- [x] 升级有视觉和音效反馈
