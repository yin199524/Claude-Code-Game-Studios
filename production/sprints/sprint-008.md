# Sprint 8 — 2026-03-26 to 2026-04-01

## Sprint Goal

实现单位协同系统和世界地图，增加策略深度和关卡组织结构。

## Capacity

- Total days: 7
- Buffer (20%): 1.4 days
- Available: ~5.5 days of effective work

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T1 | 设计协同系统 GDD | game-designer | 0.25 | — | ✅ Complete |
| T2 | 实现协同效果数据结构 | gameplay-programmer | 0.25 | T1 | ✅ Complete |
| T3 | 战斗中应用协同效果 | gameplay-programmer | 0.5 | T2 | ✅ Complete |
| T4 | 设计世界地图 GDD | game-designer | 0.25 | — | ✅ Complete |
| T5 | 实现世界/关卡元数据 | gameplay-programmer | 0.5 | T4 | ✅ Complete |
| T6 | 关卡选择 UI 重构 | ui-programmer | 0.5 | T5 | ✅ Complete |

**Total Must Have: 2.25 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T7 | 协同效果 UI 提示 | ui-programmer | 0.5 | T3 | 🔲 Pending |
| T8 | 世界主题视觉差异 | ui-programmer | 0.5 | T6 | ✅ Complete |
| T9 | 协同激活动画 | ui-programmer | 0.25 | T3 | 🔲 Pending |

**Total Should Have: 1.25 days**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T10 | 协同组合预览 | ui-programmer | 0.25 | T7 | 🔲 Pending |
| T11 | 世界解锁动画 | ui-programmer | 0.25 | T6 | 🔲 Pending |

**Total Nice to Have: 0.5 days**

---

## Total Estimated: 4 days (within capacity)

---

## Definition of Done

- [x] 至少 3 种协同效果可用
- [x] 协同效果在战斗中正确应用
- [x] 关卡按世界分组显示
- [x] 世界主题有视觉区分

---

## Technical Notes

### 协同效果类型

1. **职业协同**: 同职业单位数量达标
2. **位置协同**: 特定阵型配置
3. **属性协同**: 特定属性组合

### 世界结构

```
World
├── id: String
├── display_name: String
├── theme: enum (FOREST, DESERT, ICE, VOLCANO, SHADOW)
├── levels: Array[String]  # level IDs
├── unlock_condition: String  # previous world completion
└── theme_color: Color
```
