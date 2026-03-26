# Milestone: Beta

**Status**: 🔄 In Progress
**Start Date**: 2026-05-01
**Target End Date**: 2026-06-15

---

## Goal

完善游戏体验，添加新手引导和教程系统，优化性能，执行全面测试，为正式发布做准备。

---

## Scope

### Must Have (Beta Systems)

| # | System | Category | Status | Dependencies |
|---|--------|----------|--------|--------------|
| 1 | 新手引导系统 | Presentation | ✅ Complete | UI 系统 ✅ |
| 2 | 战斗动画优化 | Presentation | 🔲 Pending | 战斗系统 ✅ |
| 3 | 性能优化 | Technical | 🔲 Pending | 核心系统 ✅ |
| 4 | 错误处理增强 | Technical | 🔲 Pending | 全系统 |
| 5 | 全面测试执行 | QA | 🔄 In Progress | 所有系统 ✅ |

### Quality Improvements

| Area | Alpha State | Beta Target | Current |
|------|-------------|-------------|---------|
| 新手引导 | 无 | 完整教程流程 | ✅ 完成 |
| 性能 | 未优化 | < 2s 加载，稳定 60 FPS | 🔲 待优化 |
| 测试覆盖 | 检查清单未执行 | 100% 执行通过 | 🔄 单元测试就绪 |
| 错误处理 | 基础 | 友好提示 + 恢复机制 | ✅ 完成 |

### New Features

- **新手引导**: 首次进入引导、战斗教程、克制关系说明
- **统计数据面板**: 显示玩家游戏统计
- **粒子效果增强**: 战斗特效提升
- **UI 打磨**: 按钮状态、加载指示器、确认对话框

### Explicitly NOT in Beta

- PVP 系统 (Release)
- 排行榜 (Release)
- 社交功能 (Post-Release)
- 云存档 (Post-Release)

---

## Acceptance Criteria

- [ ] 新手引导完整可玩，覆盖核心玩法
- [ ] 场景加载时间 < 2 秒
- [ ] 战斗帧率稳定 60 FPS
- [ ] 所有测试检查清单执行通过
- [ ] 无 S1/S2 级别 Bug
- [x] 错误提示友好且有恢复路径
- [x] 存档损坏可自动恢复

---

## Technical Requirements

- 教程系统架构
- 性能分析工具集成
- 错误日志系统
- 自动化测试框架

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| 教程设计复杂度 | Medium | High | 参考竞品，迭代优化 |
| 性能瓶颈定位 | Medium | Medium | 使用 Godot profiler |
| 测试覆盖不足 | Low | High | 强制 DoD 检查 |

---

## Sprint Breakdown

| Sprint | Focus | Target |
|--------|-------|--------|
| Sprint 12 | 新手引导 + 测试执行 | ✅ Complete |
| Sprint 13 | 性能优化 + 动画增强 | 🔲 Planned |
| Sprint 14 | 错误处理 + 最终打磨 | 🔲 Planned |

---

## Content Plan

### 新手引导流程

| 步骤 | 内容 | 触发条件 |
|------|------|----------|
| 1 | 欢迎介绍 | 首次进入游戏 |
| 2 | 单位介绍 | 首次进入商店 |
| 3 | 战斗教程 | 首次进入战斗 |
| 4 | 克制关系 | 战斗中提示 |
| 5 | 协同效果 | 首次触发协同 |

### UI 打磨项

- [ ] 按钮悬停状态统一
- [ ] 加载状态指示器
- [ ] 错误提示友好化
- [ ] 确认对话框（购买、重置等）
- [ ] 统计数据面板
