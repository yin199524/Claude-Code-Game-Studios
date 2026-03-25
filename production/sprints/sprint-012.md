# Sprint 12 — 2026-05-01 to 2026-05-14

**Status**: 🔄 In Progress

## Sprint Goal

实现新手引导系统，执行测试检查清单，提升用户体验，为 Beta 里程碑奠定基础。

---

## Capacity

- Total days: 14
- Buffer (20%): 2.8 days
- Available: ~11 days of effective work

---

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T1 | 新手引导系统设计 | game-designer | 1.0 | — | 🔲 Pending |
| T2 | 引导管理器实现 | gameplay-programmer | 1.0 | T1 | 🔲 Pending |
| T3 | 欢迎界面实现 | ui-programmer | 0.5 | T2 | 🔲 Pending |
| T4 | 战斗教程实现 | gameplay-programmer | 1.0 | T2 | 🔲 Pending |
| T5 | 克制关系提示 | ui-programmer | 0.5 | T4 | 🔲 Pending |
| T6 | 测试检查清单执行 | qa-tester | 1.5 | — | 🔲 Pending |

**Total Must Have: 5.5 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T7 | 统计数据面板 | ui-programmer | 0.75 | — | 🔲 Pending |
| T8 | 错误处理增强 | gameplay-programmer | 0.5 | — | 🔲 Pending |
| T9 | 确认对话框组件 | ui-programmer | 0.5 | — | 🔲 Pending |
| T10 | 协同效果提示优化 | ui-programmer | 0.5 | T4 | 🔲 Pending |

**Total Should Have: 2.25 days**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T11 | 按钮悬停状态统一 | ux-designer | 0.25 | — | 🔲 Pending |
| T12 | 加载状态指示器 | ui-programmer | 0.5 | — | 🔲 Pending |
| T13 | 引导跳过功能 | gameplay-programmer | 0.25 | T2 | 🔲 Pending |

**Total Nice to Have: 1.0 day**

---

## Total Estimated: 8.75 days (within capacity)

---

## Definition of Done

- [ ] 新玩家首次进入可完成完整引导流程
- [ ] 战斗教程清晰易懂
- [ ] 克制关系有可视化提示
- [ ] 测试检查清单 100% 执行
- [ ] 所有 S1/S2 Bug 已修复
- [ ] 引导进度正确持久化

---

## Tutorial System Design

### 引导流程

```
首次启动 → 欢迎界面 → 主菜单介绍 → 商店介绍 → 首次战斗教程 → 战斗结束
```

### 欢迎界面

- 游戏名称和简介
- "开始冒险" 按钮
- 跳过选项（老玩家）

### 战斗教程

| 步骤 | 内容 | UI 指示 |
|------|------|----------|
| 1 | 放置单位 | 高亮网格区域 |
| 2 | 开始战斗 | 高亮开始按钮 |
| 3 | 观察战斗 | 战斗说明弹窗 |
| 4 | 胜利结算 | 奖励说明 |

### 克制关系提示

```
攻击克制目标时:
- 显示绿色箭头指向目标
- 显示 "克制! +50%伤害" 提示
```

---

## Testing Checklist Execution

### 功能测试

| Test | Description | Owner |
|------|-------------|-------|
| TC01 | 新游戏流程完整 | qa-tester |
| TC02 | 关卡解锁逻辑正确 | qa-tester |
| TC03 | 单位购买和升级正常 | qa-tester |
| TC04 | 成就解锁和奖励发放 | qa-tester |
| TC05 | 每日任务刷新和完成 | qa-tester |
| TC06 | 存档保存和加载 | qa-tester |
| TC07 | 协同效果正确触发 | qa-tester |

### 边界测试

| Test | Description | Owner |
|------|-------------|-------|
| TC08 | 金币不足时的处理 | qa-tester |
| TC09 | 单位满级时的处理 | qa-tester |
| TC10 | 关卡全通关后的状态 | qa-tester |
| TC11 | 存档损坏时的恢复 | qa-tester |

### 兼容性测试

| Test | Description | Owner |
|------|-------------|-------|
| TC12 | Windows 运行正常 | qa-tester |
| TC13 | 不同分辨率适配 | qa-tester |
| TC14 | 长时间运行稳定性 | qa-tester |

---

## Known Issues from Sprint 11

### Potential Issues to Test

1. **存档系统**: 版本升级后存档兼容性
2. **成就系统**: 多次触发同事件的幂等性
3. **每日任务**: 跨天刷新时在线的处理
4. **协同效果**: 多个协同叠加的计算
5. **战斗系统**: 回合超时和最大回合的处理

---

## Dependencies

- SaveManager 存档系统 ✅
- UnitDatabase 单位数据 ✅
- LevelDatabase 关卡数据 ✅
- BattleManager 战斗系统 ✅

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| 教程设计不当 | Medium | High | 参考《王国保卫战》教程设计 |
| 测试发现严重 Bug | Medium | High | 预留修复时间 |
| 引导打断流程 | Low | Medium | 设计非阻塞式引导 |

---

## Success Metrics

| Metric | Target |
|--------|--------|
| 新手引导完成率 | > 90% |
| 测试通过率 | 100% |
| S1/S2 Bug 数量 | 0 |
| 用户反馈评分 | > 4.0/5.0 |
