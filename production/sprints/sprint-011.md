# Sprint 11 — 2026-04-17 to 2026-04-30

## Sprint Goal

平衡游戏数值，修复已知问题，优化用户体验，为 Alpha 发布做准备。

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
| T1 | 单位平衡调整 | game-designer | 1.0 | — | ✅ Complete |
| T2 | 关卡难度曲线调整 | game-designer | 1.0 | T1 | ✅ Complete |
| T3 | 经济系统平衡 | economy-designer | 0.5 | T1 | 🔲 Pending |
| T4 | 音效系统完善 | sound-designer | 0.5 | — | ✅ Complete |
| T5 | 存档兼容性测试 | qa-tester | 0.5 | — | 🔲 Pending |
| T6 | UI/UX 打磨 | ux-designer | 1.0 | — | 🔲 Pending |

**Total Must Have: 4.5 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T7 | 战斗动画优化 | technical-artist | 0.5 | — | 🔲 Pending |
| T8 | 加载性能优化 | performance-analyst | 0.5 | — | 🔲 Pending |
| T9 | 错误处理增强 | gameplay-programmer | 0.5 | — | 🔲 Pending |
| T10 | 教程/引导设计 | game-designer | 1.0 | — | 🔲 Pending |

**Total Should Have: 2.5 days**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T11 | 粒子效果增强 | technical-artist | 0.5 | — | 🔲 Pending |
| T12 | 统计数据面板 | ui-programmer | 0.5 | — | 🔲 Pending |
| T13 | 音量设置持久化 | gameplay-programmer | 0.25 | — | ✅ Complete |

**Total Nice to Have: 1.25 days**

---

## Total Estimated: 8.25 days (within capacity)

---

## Definition of Done

- [ ] 所有单位属性符合设计规范
- [ ] 关卡难度曲线平滑合理
- [ ] 金币经济平衡（收入/支出比合理）
- [ ] 无阻塞性 Bug
- [ ] UI 响应流畅
- [ ] 存档系统稳定可靠
- [ ] 新手引导完整

---

## Balance Adjustment Plan

### 单位平衡调整

**目标:** 确保所有职业和稀有度有明确的使用价值

| 职业 | 当前问题 | 调整方向 |
|------|----------|----------|
| WARRIOR | 护甲收益不明显 | 提高护甲减伤比例 |
| ARCHER | 脆皮易死 | 略微提高 HP 或攻击范围 |
| MAGE | 攻击间隔过长 | 略微提高攻击速度 |
| KNIGHT | 定位模糊 | 强化移速优势 |
| HEALER | 治疗量不足 | 提高治疗系数 |
| ROGUE | 新职业未充分测试 | 需要实战验证 |

### 关卡难度曲线

**目标:** 难度逐步上升，无明显断层

| 世界 | 当前难度 | 目标难度 | 调整 |
|------|----------|----------|------|
| 森林 (1-5) | ✅ 合适 | 入门级 | 保持 |
| 沙漠 (6-9) | 跳跃过大 | 平滑过渡 | 降低敌人属性加成 |
| 冰原 (10-13) | 偏难 | 中等难度 | 调整敌人组合 |
| 火山 (14-17) | 合适 | 高难度 | 保持 |
| 暗影 (18-21) | 需验证 | Boss级 | 根据测试调整 |

### 经济平衡

**目标:** 玩家可在合理时间内获得足够金币

| 指标 | 当前值 | 目标值 |
|------|--------|--------|
| 关卡平均奖励 | 50-300 | 100-400 |
| 单位平均价格 | 50-300 | 调整为关卡奖励的 1-2 倍 |
| 升级费用 | 50-200 | 调整为关卡奖励的 0.5-1 倍 |

---

## Known Issues

### Code Issues

| File | Line | Type | Description | Priority |
|------|------|------|-------------|----------|
| sound_manager.gd | 57 | TODO | 替换为真实音效播放 | Medium |

### Potential Issues to Test

1. **存档系统**: 版本升级后存档兼容性
2. **成就系统**: 多次触发同事件的幂等性
3. **每日任务**: 跨天刷新时在线的处理
4. **协同效果**: 多个协同叠加的计算
5. **战斗系统**: 回合超时和最大回合的处理

---

## UX Improvements

### 新手引导

- [ ] 首次进入游戏的功能介绍
- [ ] 战斗系统的简化说明
- [ ] 克制关系的可视化提示
- [ ] 协同效果的触发提示

### UI 打磨

- [ ] 按钮悬停状态统一
- [ ] 加载状态指示器
- [ ] 错误提示友好化
- [ ] 确认对话框（购买、重置等）

---

## Performance Targets

| 指标 | 目标值 |
|------|--------|
| 场景加载时间 | < 2 秒 |
| 战斗帧率 | 稳定 60 FPS |
| 内存占用 | < 200 MB |
| 存档大小 | < 1 MB |

---

## Testing Checklist

### 功能测试

- [ ] 新游戏流程完整
- [ ] 关卡解锁逻辑正确
- [ ] 单位购买和升级正常
- [ ] 成就解锁和奖励发放
- [ ] 每日任务刷新和完成
- [ ] 存档保存和加载
- [ ] 协同效果正确触发

### 边界测试

- [ ] 金币不足时的处理
- [ ] 单位满级时的处理
- [ ] 关卡全通关后的状态
- [ ] 存档损坏时的恢复

### 兼容性测试

- [ ] Windows 运行正常
- [ ] 不同分辨率适配
- [ ] 长时间运行稳定性
