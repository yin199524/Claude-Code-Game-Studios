# Release Checklist: v0.4.0-alpha -- All Platforms

**Generated:** 2026-03-25
**Target Milestone:** Alpha
**Current Sprint:** Sprint 11 (2026-04-17 to 2026-04-30)
**Milestone Status:** ✅ Complete

---

## Codebase Health

| Metric | Count | Status |
|--------|-------|--------|
| TODO (src/) | 0 | ✅ Clean |
| FIXME (src/) | 0 | ✅ Clean |
| HACK (src/) | 0 | ✅ Clean |

### Uncommitted Changes
- `src/autoload/level_database.gd` (modified)
- `src/autoload/save_manager.gd` (modified)
- `src/core/player_data.gd` (modified)

---

## Build Verification

- [ ] Clean build succeeds on all target platforms
- [ ] No compiler warnings (zero-warning policy)
- [ ] All assets included and loading correctly
- [ ] Build size within budget (Target: < 200 MB)
- [ ] Build version number correctly set (project.godot shows 0.1.0, needs update to 0.4.0)
- [ ] Build is reproducible from tagged commit

---

## Quality Gates

### Bug Severity
- [ ] Zero S1 (Critical) bugs
- [ ] Zero S2 (Major) bugs -- or documented exceptions with producer approval

### Testing
- [ ] All critical path features tested and signed off by QA
- [ ] Performance within budgets:
  - [ ] Target FPS met on minimum spec hardware (60 FPS)
  - [ ] Memory usage within budget (< 200 MB)
  - [ ] Load times within budget (< 2 seconds)
  - [ ] No memory leaks over extended play sessions
- [ ] No regression from previous build
- [ ] Soak test passed (4+ hours continuous play)

### Unit Tests
8 test files available in `tests/unit/`:
- `test_target_selector.gd`
- `test_damage_calculator_gut.gd`
- `test_target_selector_gut.gd`
- `test_grid_layout.gd`
- `test_battle_manager.gd`
- `test_level_system.gd`
- `test_damage_calculator.gd`

---

## Content Complete

### Alpha Milestone Acceptance Criteria (All Met ✅)
- [x] 单位可通过金币升级，属性正确提升
- [x] 至少 3 种协同效果可用 (10 种协同效果已实现)
- [x] 4 个世界共 16+ 关卡可玩 (21 关，5 世界)
- [x] 15+ 单位可收集 (11 玩家单位 + 敌人单位)
- [x] 完整的单人游戏循环（从开始到"通关"）

### Systems Complete
- [x] 单位升级系统
- [x] 单位协同系统
- [x] 进度系统
- [x] 主菜单 UI 增强
- [x] 商店 UI 增强
- [x] 成就系统
- [x] 每日任务系统

### Content Verification
- [ ] All placeholder assets replaced with final versions
- [ ] All TODO/FIXME in content files resolved or documented
- [ ] All player-facing text proofread
- [ ] All text localization-ready (no hardcoded strings)
- [ ] Audio mix finalized and approved
- [ ] Credits complete and accurate

---

## Platform Requirements: PC

- [ ] Minimum and recommended specs verified and documented
- [ ] Keyboard+mouse controls fully functional
- [ ] Controller support tested (Xbox, PlayStation, generic)
- [ ] Resolution scaling tested (720x1280 portrait mode)
- [ ] Windowed, borderless, and fullscreen modes working
- [ ] Graphics settings save and load correctly
- [ ] Steam/Epic/GOG SDK integrated and tested (if applicable)
- [ ] Achievements functional
- [ ] Cloud saves functional

---

## Platform Requirements: Mobile (Future Target)

- [ ] App store guidelines compliance verified
- [ ] All required device permissions justified and documented
- [ ] Privacy policy linked and accurate
- [ ] Data safety/nutrition labels completed
- [ ] Touch controls tested on multiple screen sizes
- [ ] Battery usage within acceptable range
- [ ] Background behavior correct (pause, resume, terminate)
- [ ] Push notification permissions handled correctly
- [ ] In-app purchase flow tested (if applicable)
- [ ] App size within store limits

---

## Store / Distribution

- [ ] Store page metadata complete and proofread
  - [ ] Short description
  - [ ] Long description
  - [ ] Feature list
  - [ ] System requirements (PC/Mobile)
- [ ] Screenshots up to date and per-platform resolution requirements met
- [ ] Trailers up to date
- [ ] Key art and capsule images current
- [ ] Age rating obtained and configured:
  - [ ] ESRB
  - [ ] PEGI
  - [ ] Other regional ratings as required
- [ ] Legal notices, EULA, and privacy policy in place
- [ ] Third-party license attributions complete
- [ ] Pricing configured for all regions

---

## Launch Readiness

- [ ] Analytics / telemetry verified and receiving data
- [ ] Crash reporting configured and dashboard accessible
- [ ] Day-one patch prepared and tested (if needed)
- [ ] On-call team schedule set for first 72 hours
- [ ] Community launch announcements drafted
- [ ] Press/influencer keys prepared for distribution
- [ ] Support team briefed on known issues and FAQ
- [ ] Rollback plan documented (if critical issues found post-launch)

---

## Sprint 11 Remaining Tasks

### Must Have (Pending)
- [ ] T3: 经济系统平衡 (economy-designer, 0.5 days)
- [ ] T5: 存档兼容性测试 (qa-tester, 0.5 days)

### Should Have (Pending)
- [ ] T7: 战斗动画优化 (technical-artist, 0.5 days)
- [ ] T8: 加载性能优化 (performance-analyst, 0.5 days)
- [ ] T9: 错误处理增强 (gameplay-programmer, 0.5 days)
- [ ] T10: 教程/引导设计 (game-designer, 1.0 days)

### Nice to Have (Pending)
- [ ] T11: 粒子效果增强 (technical-artist, 0.5 days)
- [ ] T12: 统计数据面板 (ui-programmer, 0.5 days)

---

## Known Issues to Test

1. **存档系统**: 版本升级后存档兼容性
2. **成就系统**: 多次触发同事件的幂等性
3. **每日任务**: 跨天刷新时在线的处理
4. **协同效果**: 多个协同叠加的计算
5. **战斗系统**: 回合超时和最大回合的处理

---

## Go / No-Go: **CONDITIONALLY READY**

### Rationale

**Alpha 里程碑已标记完成**，核心功能和内容目标均已达成。但仍有关注点：

#### ✅ 完成项
1. 所有 Alpha 系统功能已实现
2. 内容目标已达成（21 关、5 世界、10 种协同效果）
3. 代码质量良好（无 TODO/FIXME/HACK）
4. 测试框架已就位（GUT + 8 个测试文件）

#### ⚠️ 待处理项
1. **版本号未更新**: project.godot 显示 0.1.0，应为 0.4.0
2. **未提交更改**: 3 个文件有修改待提交
3. **Sprint 11 任务未完成**: 经济平衡、存档测试等任务待处理
4. **平台测试缺失**: 未进行实际构建和跨平台测试
5. **商店准备未开始**: 商店页面、年龄分级等尚未配置

#### 🔒 阻塞项
无阻塞性问题。建议完成以下工作后发布：
- 更新版本号
- 提交当前更改
- 完成 Sprint 11 必要任务 (T3, T5)
- 进行基础构建测试

---

## Sign-offs Required

- [ ] QA Lead
- [ ] Technical Director
- [ ] Producer
- [ ] Creative Director

---

## Appendix: Sprint History

| Sprint | Focus | Status |
|--------|-------|--------|
| Sprint 1-4 | MVP 核心功能 | ✅ Complete |
| Sprint 5-6 | 反击系统、关卡解锁、存档增强 | ✅ Complete |
| Sprint 7 | 单位升级系统 | ✅ Complete |
| Sprint 8 | 协同系统 + 世界地图 | ✅ Complete |
| Sprint 9 | 内容扩展 (单位/关卡) | ✅ Complete |
| Sprint 10 | 成就系统 + UI 完善 | ✅ Complete |
| Sprint 11 | 平衡调整 + Bug 修复 | 🔄 In Progress |
