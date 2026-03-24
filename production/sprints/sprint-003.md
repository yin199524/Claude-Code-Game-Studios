# Sprint 3 — 2026-03-24 to 2026-03-30

## Sprint Goal

实现游戏内容和商店系统，完成核心循环「布局 → 战斗 → 奖励 → 购买」的最后环节。

## Capacity

- Total days: 7
- Buffer (20%): 1.4 days (reserved for unplanned work)
- Available: ~5.5 days of effective work

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T1 | 创建 EnemySpawn 类 | gameplay-programmer | 0.25 | Sprint 2 | 敌人配置可序列化 |
| T2 | 创建 LevelDefinition 类 | gameplay-programmer | 0.5 | T1 | 关卡可定义敌人、奖励、限制 |
| T3 | 创建 LevelDatabase Autoload | gameplay-programmer | 0.5 | T2 | 可以加载和查询关卡 |
| T4 | 创建 LevelSelectScene 场景 | ui-programmer | 0.5 | T3 | 显示关卡列表、解锁状态 |
| T5 | 集成关卡到战斗流程 | gameplay-programmer | 0.5 | T4 | 从关卡选择进入战斗 |
| T6 | 实现战斗奖励发放 | gameplay-programmer | 0.25 | Sprint 2 | 胜利后正确发放金币 |
| T7 | 创建 ShopScene 场景 | ui-programmer | 0.5 | — | 显示可购买单位列表 |
| T8 | 实现购买逻辑 | gameplay-programmer | 0.25 | T7 | 金币扣除、单位添加 |
| T9 | 单元测试：关卡系统 | qa-tester | 0.25 | T2, T3 | 关卡加载、验证测试通过 |

**Total Must Have: 3.5 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T10 | 定义 3 个 MVP 关卡数据 | game-designer | 0.25 | T2 | 3 个关卡可游玩 |
| T11 | 创建关卡完成/解锁逻辑 | gameplay-programmer | 0.25 | T5 | 顺序解锁正确 |
| T12 | 商店购买反馈 UI | ui-programmer | 0.25 | T7 | 购买成功/失败提示 |

**Total Should Have: 0.75 days**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T13 | 金币变化动画 | ui-programmer | 0.25 | T6 | 金币变化有飘字效果 |
| T14 | 关卡难度预览 | ui-programmer | 0.25 | T4 | 显示敌人信息预览 |

**Total Nice to Have: 0.5 days**

---

## Total Estimated: 4.75 days (within 5.5 available days + buffer)

---

## Carryover from Previous Sprint

无

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| 关卡数据平衡 | Medium | Medium | 预留调整参数 |
| UI 场景切换流畅性 | Low | Low | 使用信号驱动 |

---

## Dependencies on External Factors

- 无外部依赖

---

## Definition of Done for this Sprint

- [ ] 所有 Must Have 任务完成
- [ ] 所有任务通过验收标准
- [ ] 单元测试通过
- [ ] 可以从关卡选择进入战斗
- [ ] 战斗胜利后获得金币奖励
- [ ] 金币可以在商店购买单位
- [ ] 核心循环完整可玩

---

## Daily Checkpoints

| Day | Focus |
|-----|-------|
| Day 1 | EnemySpawn + LevelDefinition (T1, T2) |
| Day 2 | LevelDatabase + LevelSelect (T3, T4) |
| Day 3 | 战斗集成 + 奖励 (T5, T6) |
| Day 4 | 商店系统 (T7, T8) |
| Day 5 | 测试 + 数据定义 (T9, T10) |
| Day 6 | 解锁逻辑 + UI 反馈 (T11, T12) |
| Day 7 | 动画 + 收尾 (T13, T14) |

---

## Notes

- 参考 `design/gdd/enemy-system.md` 实现敌人配置
- 参考 `design/gdd/level-system.md` 实现关卡系统
- 参考 `design/gdd/shop-system.md` 实现商店系统
- 参考 `design/gdd/resource-system.md` 实现资源管理
- 资源系统大部分已在 PlayerData 中实现
