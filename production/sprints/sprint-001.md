# Sprint 1 — 2026-03-24 to 2026-03-30

## Sprint Goal

建立游戏的数据基础层和核心计算系统，实现第一个可运行的数据驱动战斗原型。

## Capacity

- Total days: 7
- Buffer (20%): 1.4 days (reserved for unplanned work)
- Available: ~5.5 days of effective work

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T1 | 创建 UnitDefinition Resource 类 | gameplay-programmer | 0.5 | — | 可以在编辑器中创建单位定义资源 |
| T2 | 定义 5 个 MVP 单位数据 | game-designer | 0.25 | T1 | 5 个单位可在编辑器中查看和使用 |
| T3 | 创建 PlayerData Resource 类 | gameplay-programmer | 0.25 | — | 可以存储金币和单位列表 |
| T4 | 创建 DamageCalculator 类 | gameplay-programmer | 0.5 | T1, T2 | 给定攻击者和防御者，返回正确伤害值 |
| T5 | 创建 TargetSelector 类 | ai-programmer | 0.5 | T1 | 给定单位列表，返回最近目标 |
| T6 | 单元测试：伤害计算 | qa-tester | 0.25 | T4 | 所有边界情况和正常情况通过 |
| T7 | 单元测试：目标选择 | qa-tester | 0.25 | T5 | 所有边界情况和正常情况通过 |

**Total Must Have: 2.5 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T8 | 创建 GameManager Autoload | gameplay-programmer | 0.5 | — | 可以访问全局游戏状态 |
| T9 | 创建 UnitDatabase Autoload | gameplay-programmer | 0.25 | T1, T2 | 可以通过 ID 查询单位定义 |
| T10 | 创建 SaveManager Autoload | gameplay-programmer | 0.5 | T3 | 可以保存和加载 PlayerData |

**Total Should Have: 1.25 days**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T11 | 创建基础项目结构 | gameplay-programmer | 0.25 | — | 目录结构符合 ADR-0001 |
| T12 | 配置 GUT 测试框架 | gameplay-programmer | 0.25 | — | 可以运行单元测试 |

**Total Nice to Have: 0.5 days**

---

## Total Estimated: 4.25 days (within 5.5 available days)

---

## Carryover from Previous Sprint

无（这是第一个冲刺）

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Godot 4.6 API 不熟悉 | Medium | Medium | 参考 `docs/engine-reference/godot/` |
| Resource 序列化问题 | Low | Medium | 参考 Godot 官方文档 |

---

## Dependencies on External Factors

- 无外部依赖

---

## Definition of Done for this Sprint

- [ ] 所有 Must Have 任务完成
- [ ] 所有任务通过验收标准
- [ ] 单元测试通过
- [ ] 代码符合 GDScript 命名规范
- [ ] 可以在编辑器中创建和查看单位数据
- [ ] 伤害计算和目标选择逻辑经过测试验证

---

## Daily Checkpoints

| Day | Focus |
|-----|-------|
| Day 1 | 项目结构 + UnitDefinition (T1, T11) |
| Day 2 | 单位数据 + PlayerData (T2, T3) |
| Day 3 | DamageCalculator + 测试 (T4, T6) |
| Day 4 | TargetSelector + 测试 (T5, T7) |
| Day 5 | Autoloads (T8, T9, T10) |
| Day 6 | 测试框架 + 缓冲 (T12) |
| Day 7 | 收尾 + 代码审查 |

---

## Notes

- 所有代码应放在 `src/` 目录下
- 单元测试放在 `tests/` 目录下
- 参考 `design/gdd/unit-data-definition.md` 和 `design/gdd/damage-calculation.md` 实现
- 参考 `docs/architecture/adr-0001-game-architecture.md` 架构
