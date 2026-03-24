# Sprint 2 — 2026-03-24 to 2026-03-30

## Sprint Goal

实现完整的战斗流程，从布局到战斗结束，玩家可以体验「布局 → 观战 → 结算」的核心循环。

## Capacity

- Total days: 7
- Buffer (20%): 1.4 days (reserved for unplanned work)
- Available: ~5.5 days of effective work

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T1 | 创建 GridLayout 类 | gameplay-programmer | 0.5 | Sprint 1 | 可以放置/移除单位，格子有唯一单位 |
| T2 | 创建 BattleStateMachine 类 | gameplay-programmer | 0.5 | T1 | 状态转换正确，信号正确发射 |
| T3 | 创建 BattleManager 类 | gameplay-programmer | 1.0 | T1, T2 | 回合制战斗正确执行 |
| T4 | 实现单位移动逻辑 | gameplay-programmer | 0.5 | T3 | 单位向目标移动，不穿过其他单位 |
| T5 | 实现单位攻击逻辑 | gameplay-programmer | 0.5 | T3 | 攻击、伤害应用、死亡处理 |
| T6 | 实现战斗结束判断 | gameplay-programmer | 0.25 | T3 | 胜利/失败/超时正确判定 |
| T7 | 单元测试：网格布局 | qa-tester | 0.25 | T1 | 放置、移除、边界测试通过 |
| T8 | 单元测试：战斗流程 | qa-tester | 0.5 | T3, T4, T5, T6 | 完整战斗模拟测试通过 |

**Total Must Have: 4.0 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T9 | 创建 BattleScene 场景 | gameplay-programmer | 0.5 | T3 | 可以运行完整战斗 |
| T10 | 创建战斗 HUD | ui-programmer | 0.5 | T9 | 显示回合计数、暂停按钮 |
| T11 | 实现战斗暂停/继续 | gameplay-programmer | 0.25 | T9 | 可以暂停和继续战斗 |

**Total Should Have: 1.25 days**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T12 | 创建 BattleSetupScene 场景 | gameplay-programmer | 0.5 | T1 | 玩家可以在网格上放置单位 |
| T13 | 战斗加速功能 | gameplay-programmer | 0.25 | T9 | 1x/2x 速度切换 |

**Total Nice to Have: 0.75 days**

---

## Total Estimated: 6.0 days (within 5.5 available days + buffer)

---

## Carryover from Previous Sprint

无

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| 战斗逻辑复杂度高 | Medium | High | 参考 prototype 验证过的模式 |
| 单位移动碰撞检测 | Medium | Medium | 使用简单的格子占用检查 |
| 状态同步问题 | Low | High | 使用信号驱动状态更新 |

---

## Dependencies on External Factors

- 无外部依赖

---

## Definition of Done for this Sprint

- [ ] 所有 Must Have 任务完成
- [ ] 所有任务通过验收标准
- [ ] 单元测试通过
- [ ] 可以运行完整的战斗流程（从布局到结束）
- [ ] 战斗结果正确判定
- [ ] 代码符合 GDScript 命名规范

---

## Daily Checkpoints

| Day | Focus |
|-----|-------|
| Day 1 | GridLayout + BattleStateMachine (T1, T2) |
| Day 2 | BattleManager 核心框架 (T3) |
| Day 3 | 单位移动逻辑 + 测试 (T4, T7) |
| Day 4 | 单位攻击逻辑 + 战斗结束 (T5, T6) |
| Day 5 | 战斗测试 (T8) |
| Day 6 | BattleScene + HUD (T9, T10, T11) |
| Day 7 | BattleSetupScene + 收尾 (T12, T13) |

---

## Notes

- 参考 `design/gdd/auto-battle-system.md` 实现战斗逻辑
- 参考 `design/gdd/battle-state-machine.md` 实现状态机
- 参考 `design/gdd/grid-layout-system.md` 实现布局系统
- 参考 `prototypes/auto-battle/` 的验证模式
- 所有代码应放在 `src/` 目录下
- 单元测试放在 `tests/` 目录下
