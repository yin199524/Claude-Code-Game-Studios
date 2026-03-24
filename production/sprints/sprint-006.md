# Sprint 6 — 2026-03-24 to 2026-03-30

## Sprint Goal

完善存档系统，支持关卡星级保存、存档版本控制和数据验证，完成 Vertical Slice 里程碑。

## Capacity

- Total days: 7
- Buffer (20%): 1.4 days
- Available: ~5.5 days of effective work

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T1 | 添加关卡星级保存 | gameplay-programmer | 0.25 | — | ✅ Done |
| T2 | 添加存档版本控制 | gameplay-programmer | 0.25 | — | ✅ Done |
| T3 | 实现数据验证 | gameplay-programmer | 0.5 | — | ✅ Done |
| T4 | 存档 UI 集成测试 | qa-tester | 0.25 | T1-T3 | 🔲 Pending |

**Total Must Have: 1.25 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T5 | 存档信息显示 | ui-programmer | 0.25 | T1-T3 | 🔲 Pending |
| T6 | 重置存档确认弹窗 | ui-programmer | 0.25 | — | 🔲 Pending |

**Total Should Have: 0.5 days**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T7 | 多存档槽支持 | gameplay-programmer | 0.5 | T1-T3 | 🔲 Pending |
| T8 | 存档迁移工具 | gameplay-programmer | 0.25 | T2 | 🔲 Pending |

**Total Nice to Have: 0.75 days**

---

## Total Estimated: 2.5 days (within capacity)

---

## Definition of Done

- [x] 关卡星级正确保存和加载
- [x] 存档包含版本号和创建时间
- [x] 数据验证能检测异常数据
- [ ] 存档系统通过集成测试
