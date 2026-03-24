# Release Checklist: v0.1.0 — Vertical Slice

**Generated**: 2026-03-24
**Platform**: All (Mobile Primary)
**Game**: Zen Legion (禅意军团)
**Engine**: Godot 4.6

---

## Codebase Health

- **TODO count**: 1
  - `src/autoload/sound_manager.gd:57` — 替换为真实音效播放 (非阻塞)
- **FIXME count**: 0 ✓
- **HACK count**: 0 ✓

---

## Build Verification

- [ ] Clean build succeeds on all target platforms
- [ ] No compiler warnings (zero-warning policy)
- [ ] All assets included and loading correctly
- [ ] Build size within budget (TBD — define target size)
- [ ] Build version number correctly set (0.1.0)
- [ ] Build is reproducible from tagged commit

---

## Quality Gates

- [ ] Zero S1 (Critical) bugs
- [ ] Zero S2 (Major) bugs — or documented exceptions with producer approval
- [ ] All critical path features tested and signed off by QA
- [ ] Performance within budgets:
  - [ ] Target FPS met (60 FPS on minimum spec)
  - [ ] Memory usage within budget
  - [ ] Load times within budget
  - [ ] No memory leaks over extended play sessions
- [ ] No regression from previous build
- [ ] Soak test passed (4+ hours continuous play)

### Test Coverage

**Unit Tests Available** (8 files):
- `test_damage_calculator.gd` / `test_damage_calculator_gut.gd`
- `test_target_selector.gd` / `test_target_selector_gut.gd`
- `test_grid_layout.gd`
- `test_battle_manager.gd`
- `test_level_system.gd`

- [ ] All unit tests passing
- [ ] Integration tests passing
- [ ] Manual playtest completed

---

## Content Complete

### MVP Systems (Complete)
- [x] 单位数据定义 (5 units: Warrior, Archer, Mage, Knight, Healer)
- [x] 玩家数据
- [x] 伤害计算系统
- [x] 目标选择 AI
- [x] 网格布局系统 (3x3 grid)
- [x] 战斗状态机
- [x] 自动战斗系统
- [x] 资源系统 (Gold)
- [x] 敌人系统
- [x] 关卡系统 (3 levels)
- [x] 商店系统

### Vertical Slice Systems (In Progress)
- [ ] 存档系统完善 — 多存档槽支持
- [ ] 克制系统 — 职业间相克机制
- [ ] 关卡解锁系统 — 顺序解锁
- [ ] 布局编辑 UI 增强
- [ ] 战斗 UI 增强
- [ ] 扩展到 5 个关卡

### Content Requirements
- [ ] All placeholder assets replaced with final versions
- [ ] All TODO/FIXME in content files resolved or documented
- [ ] All player-facing text proofread
- [ ] All text localization-ready (no hardcoded strings)
- [ ] Audio mix finalized and approved
- [ ] Credits complete and accurate

---

## Platform Requirements: Mobile (Primary)

- [ ] App store guidelines compliance verified
- [ ] All required device permissions justified and documented
- [ ] Privacy policy linked and accurate
- [ ] Data safety/nutrition labels completed
- [ ] Touch controls tested on multiple screen sizes
  - Current resolution: 720x1280 (9:16 portrait)
- [ ] Battery usage within acceptable range
- [ ] Background behavior correct (pause, resume, terminate)
- [ ] Push notification permissions handled correctly (if applicable)
- [ ] In-app purchase flow tested (if applicable)
- [ ] App size within store limits

---

## Platform Requirements: PC

- [ ] Minimum and recommended specs verified and documented
- [ ] Keyboard+mouse controls fully functional
- [ ] Controller support tested (Xbox, PlayStation, generic)
- [ ] Resolution scaling tested (1080p, 1440p, 4K, ultrawide)
- [ ] Windowed, borderless, and fullscreen modes working
- [ ] Graphics settings save and load correctly
- [ ] Steam/Epic/GOG SDK integrated and tested (if applicable)
- [ ] Achievements functional (if applicable)
- [ ] Cloud saves functional (if applicable)
- [ ] Steam Deck compatibility verified (if targeting)

---

## Platform Requirements: Console

- [ ] TRC/TCR/Lotcheck requirements checklist complete
- [ ] Platform-specific controller prompts display correctly
- [ ] Suspend/resume works correctly
- [ ] User switching handled properly
- [ ] Network connectivity loss handled gracefully
- [ ] Storage full scenario handled
- [ ] Parental controls respected
- [ ] Platform-specific achievement/trophy integration tested
- [ ] First-party certification submission prepared

---

## Store / Distribution

- [ ] Store page metadata complete and proofread
  - [ ] Short description
  - [ ] Long description
  - [ ] Feature list
  - [ ] System requirements (PC)
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

## Go / No-Go: NOT READY

**Rationale:**

Vertical Slice 里程碑尚未完成。以下项目必须先解决：

| Blocker | Priority | Status |
|---------|----------|--------|
| 克制系统未实现 | High | Sprint 5 进行中 |
| 关卡解锁系统待完善 | High | Sprint 5 进行中 |
| 存档系统待完善 | Medium | Sprint 6 计划 |
| UI 反馈待增强 | Medium | Sprint 5-6 计划 |
| 需扩展到 5 个关卡 | Medium | Sprint 5 计划 |

**Known Issues:**
- 1 TODO (音效占位符) — 非阻塞

**Estimated Readiness:** Sprint 6 完成后 (约 2026-04-07)

---

## Sign-offs Required

- [ ] QA Lead
- [ ] Technical Director
- [ ] Producer
- [ ] Creative Director

---

## Checklist Summary

| Category | Total Items | Completed | Blocked |
|----------|-------------|-----------|---------|
| Build Verification | 6 | 0 | 0 |
| Quality Gates | 7 | 0 | 0 |
| Content Complete | 12 | 11 | 5 |
| Mobile Platform | 10 | 0 | 0 |
| PC Platform | 10 | 0 | 0 |
| Console Platform | 9 | 0 | 0 |
| Store/Distribution | 11 | 0 | 0 |
| Launch Readiness | 8 | 0 | 0 |
| **Total** | **73** | **11** | **5** |
