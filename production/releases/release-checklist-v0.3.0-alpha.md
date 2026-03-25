# Release Checklist: v0.3.0-alpha -- All Platforms

**Generated:** 2026-03-25
**Target Milestone:** Alpha
**Current Sprint:** Sprint 9 (2026-03-27 to 2026-04-02)

---

## Codebase Health

| Metric | Count | Status |
|--------|-------|--------|
| TODO | 1 | ⚠️ Review required |
| FIXME | 0 | ✅ Clean |
| HACK | 0 | ✅ Clean |

### Outstanding TODOs
- `src/autoload/sound_manager.gd:57` - 替换为真实音效播放

---

## Build Verification

- [ ] Clean build succeeds on all target platforms
- [ ] No compiler warnings (zero-warning policy)
- [ ] All assets included and loading correctly
- [ ] Build size within budget ([TO BE CONFIGURED])
- [ ] Build version number correctly set (v0.3.0-alpha)
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
  - [ ] Memory usage within budget
  - [ ] Load times within budget
  - [ ] No memory leaks over extended play sessions
- [ ] No regression from previous build
- [ ] Soak test passed (4+ hours continuous play)

---

## Content Complete

- [ ] All placeholder assets replaced with final versions
- [ ] All TODO/FIXME in content files resolved or documented
- [ ] All player-facing text proofread
- [ ] All text localization-ready (no hardcoded strings)
- [ ] Audio mix finalized and approved
- [ ] Credits complete and accurate

---

## Feature Completeness (Alpha Milestone)

### Core Systems
- [ ] 单位升级系统 ✅ Sprint 7 Complete
- [ ] 单位协同系统 ✅ Sprint 8 Complete
- [ ] 世界地图系统 ✅ Sprint 8 Complete
- [ ] 进度系统
- [ ] 成就系统

### Content Targets
- [ ] 15+ 可玩单位 (当前: 10，目标: 15)
- [ ] 12+ 敌人类型 (当前: 7，目标: 12)
- [ ] 20 关卡分布在 5 个世界 (当前: 5，目标: 20)
- [ ] 每个世界主题敌人有差异

---

## Platform Requirements: PC

- [ ] Minimum and recommended specs verified and documented
- [ ] Keyboard+mouse controls fully functional
- [ ] Controller support tested (Xbox, PlayStation, generic)
- [ ] Resolution scaling tested (1080p, 1440p, 4K, ultrawide)
- [ ] Windowed, borderless, and fullscreen modes working
- [ ] Graphics settings save and load correctly
- [ ] Steam/Epic/GOG SDK integrated and tested (if applicable)
- [ ] Achievements functional
- [ ] Cloud saves functional
- [ ] Steam Deck compatibility verified (if targeting)

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

## Go / No-Go: **NOT READY**

### Rationale

当前项目处于 **Alpha 里程碑进行中**，Sprint 9 正在进行中。主要阻塞项：

1. **功能未完成**: 成就系统和进度系统尚未实现
2. **内容不足**: 当前仅 5 个关卡、10 个单位，目标为 20 关卡、15 单位
3. **音频占位**: 音效系统仍使用占位实现 (TODO 在 sound_manager.gd)
4. **平台测试**: 未进行跨平台构建测试
5. **商店准备**: 商店页面、年龄分级等尚未开始

### 预估完成时间

基于当前 Sprint 计划：
- Sprint 9 (进行中): 内容扩展 - 2 周
- Sprint 10: 成就系统 + UI 完善 - 2 周
- Sprint 11: 平衡调整 + Bug 修复 - 2 周
- **预计 Alpha 就绪: 6 周后 (约 2026-05-06)**

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
| Sprint 9 | 内容扩展 (单位/关卡) | 🔄 In Progress |
| Sprint 10 | 成就系统 + UI 完善 | 🔲 Planned |
| Sprint 11 | 平衡调整 + Bug 修复 | 🔲 Planned |
