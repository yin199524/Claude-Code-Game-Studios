# Sprint 13 — 2026-05-15 to 2026-05-28

**Status**: 🔄 In Progress

## Sprint Goal

优化游戏性能，增强战斗动画，执行手动测试，实现延期功能，为 Beta 里程碑冲刺。

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
| T1 | 执行手动测试 (14项) | qa-tester | 2.0 | — | ⏸ Deferred |
| T2 | 场景加载性能优化 | performance-analyst | 1.0 | — | ✅ Complete |
| T3 | 战斗帧率优化 | performance-analyst | 0.75 | — | 🔲 Pending |
| T4 | 战斗动画增强 | technical-artist | 1.0 | — | 🔲 Pending |
| T5 | QuickHint 单元测试 | gameplay-programmer | 0.25 | — | 🔲 Pending |

**Total Must Have: 5.0 days**

### Should Have (来自 Sprint 12 延期)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T6 | 统计数据面板 | ui-programmer | 0.75 | — | 🔲 Pending |

**T2 场景加载性能优化 - 扩展优化:**
- 关卡选择场景: 延迟加载 UI、预览面板延迟创建、UI 缓存
- 商店场景: 延迟加载单位列表、提示面板延迟创建、增量加载
| T7 | 确认对话框组件 | ui-programmer | 0.5 | — | 🔲 Pending |
| T8 | 错误处理增强 | gameplay-programmer | 0.5 | — | 🔲 Pending |
| T9 | 加载状态指示器 | ui-programmer | 0.5 | — | 🔲 Pending |

**Total Should Have: 2.25 days**

### Nice to Have (来自 Sprint 12 延期)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T10 | 按钮悬停状态统一 | ux-designer | 0.25 | — | 🔲 Pending |
| T11 | 协同效果提示优化 | ui-programmer | 0.5 | — | 🔲 Pending |
| T12 | 引导跳过功能 | gameplay-programmer | 0.25 | — | 🔲 Pending |

**Total Nice to Have: 1.0 day**

---

## Total Estimated: 8.25 days (within capacity)

---

## Definition of Done

- [ ] 14 项手动测试执行完毕
- [ ] 场景加载时间 < 2 秒
- [ ] 战斗帧率稳定 60 FPS
- [ ] 战斗动画流畅自然
- [ ] 统计数据面板功能完整
- [ ] 确认对话框组件可用
- [ ] 无 S1/S2 Bug

---

## Performance Optimization Plan

### 加载性能优化

| 场景 | 当前状态 | 目标 | 优化策略 |
|------|----------|------|----------|
| 主菜单 | 未测量 | < 1s | 预加载资源 |
| 关卡选择 | 未测量 | < 1.5s | 延迟加载关卡预览 |
| 战斗场景 | 未测量 | < 2s | 异步加载单位资源 |
| 商店 | 未测量 | < 1s | 单位列表虚拟化 |

### 帧率优化

| 区域 | 潜在瓶颈 | 优化策略 |
|------|----------|----------|
| 战斗场景 | 单位渲染 | 批量绘制、LOD |
| 战斗场景 | 伤害计算 | 缓存计算结果 |
| UI 更新 | 频繁重绘 | 减少不必要的更新 |
| 粒子效果 | 过多粒子 | 限制粒子数量 |

---

## Battle Animation Enhancement

### 当前状态
- 攻击动画：简单的位移抖动
- 死亡动画：淡出消失
- 技能动画：无

### 增强目标

| 动画类型 | 当前 | 目标 |
|----------|------|------|
| 攻击 | 位移抖动 | 冲刺攻击 + 命中特效 |
| 死亡 | 淡出 | 击飞 + 消散粒子 |
| 治疗 | 无 | 绿色光环 |
| 克制攻击 | 金色数字 | 额外闪光特效 |
| 协同触发 | 提示文字 | 单位连线特效 |

---

## Manual Test Execution Plan

### 功能测试 (7 项)

| Test ID | Description | Priority |
|---------|-------------|----------|
| TC01 | 新游戏流程完整 | High |
| TC02 | 关卡解锁逻辑正确 | High |
| TC03 | 单位购买和升级正常 | High |
| TC04 | 成就解锁和奖励发放 | Medium |
| TC05 | 每日任务刷新和完成 | Medium |
| TC06 | 存档保存和加载 | High |
| TC07 | 协同效果正确触发 | Medium |

### 边界测试 (4 项)

| Test ID | Description | Priority |
|---------|-------------|----------|
| TC08 | 金币不足时的处理 | High |
| TC09 | 单位满级时的处理 | Medium |
| TC10 | 关卡全通关后的状态 | Low |
| TC11 | 存档损坏时的恢复 | High |

### 兼容性测试 (3 项)

| Test ID | Description | Priority |
|---------|-------------|----------|
| TC12 | Windows 运行正常 | High |
| TC13 | 不同分辨率适配 | Medium |
| TC14 | 长时间运行稳定性 | Medium |

---

## Deferred Features from Sprint 12

### 统计数据面板

显示内容：
- 总游戏时长
- 累计击败敌人数
- 累计获得金币
- 累计触发协同次数
- 最高连胜记录
- 收集单位数量

### 确认对话框组件

用途：
- 购买确认
- 升级确认
- 重置存档确认
- 退出游戏确认

### 加载状态指示器

位置：
- 场景切换时
- 存档加载时
- 资源加载时

---

## Dependencies

- 所有核心系统 ✅
- TutorialManager ✅
- SaveManager ✅

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| 性能瓶颈难以定位 | Medium | Medium | 使用 Godot Profiler 工具 |
| 手动测试发现 Bug | Medium | High | 预留修复时间 |
| 动画效果不符合预期 | Low | Low | 参考竞品动画 |

---

## Success Metrics

| Metric | Target |
|--------|--------|
| 手动测试通过率 | > 90% |
| 场景加载时间 | < 2s |
| 战斗帧率 | 稳定 60 FPS |
| S1/S2 Bug 数量 | 0 |
| Should Have 完成率 | > 50% |
