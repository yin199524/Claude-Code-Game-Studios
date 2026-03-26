## Release Checklist: v0.6.0-beta — All Platforms

Generated: 2026-03-25

---

### Codebase Health

| Metric | Count | Status |
|--------|-------|--------|
| TODO (src/) | 0 | ✅ Clean |
| FIXME (src/) | 0 | ✅ Clean |
| HACK (src/) | 0 | ✅ Clean |

**Assessment**: 代码质量优秀，无待处理的技术债务标记。

---

### Build Verification

- [ ] Clean build succeeds on all target platforms
  - [ ] Windows (D3D12 default)
  - [ ] Windows (Vulkan fallback)
- [ ] No compiler warnings (zero-warning policy)
- [ ] All assets included and loading correctly
- [ ] Build size within budget
- [ ] Build version number correctly set (0.6.0-beta)
- [ ] Build is reproducible from tagged commit

---

### Quality Gates

- [ ] Zero S1 (Critical) bugs
- [ ] Zero S2 (Major) bugs — or documented exceptions with producer approval
- [ ] All critical path features tested and signed off by QA
- [ ] Performance within budgets:
  - [ ] Target FPS met on minimum spec hardware (60 FPS) ✅ Sprint 13 T3 完成
  - [ ] Memory usage within budget
  - [ ] Load times within budget (< 2s per scene) ✅ Sprint 13 T2 完成
  - [ ] No memory leaks over extended play sessions
- [ ] No regression from previous build (v0.5.0-beta)
- [ ] Soak test passed (4+ hours continuous play)

---

### Content Complete

- [ ] All placeholder assets replaced with final versions
- [ ] All TODO/FIXME in content files resolved or documented
- [ ] All player-facing text proofread
- [ ] All text localization-ready (no hardcoded strings)
- [ ] Audio mix finalized and approved
- [ ] Credits complete and accurate

---

### Platform Requirements: PC

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

### Store / Distribution

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

### Launch Readiness

- [ ] Analytics / telemetry verified and receiving data
- [ ] Crash reporting configured and dashboard accessible
- [ ] Day-one patch prepared and tested (if needed)
- [ ] On-call team schedule set for first 72 hours
- [ ] Community launch announcements drafted
- [ ] Press/influencer keys prepared for distribution
- [ ] Support team briefed on known issues and FAQ
- [ ] Rollback plan documented (if critical issues found post-launch)

---

### Beta Milestone Specific Checklist

#### 新手引导系统 (Tutorial System)
- [x] 首次进入引导
- [x] 战斗教程
- [x] 克制关系说明
- [x] 协同效果提示
- [x] 引导跳过功能 ✅ Sprint 13 T12 完成

#### 性能优化 (Performance Optimization)
- [x] 场景加载时间 < 2 秒 ✅ Sprint 13 T2 完成
- [x] 战斗帧率稳定 60 FPS ✅ Sprint 13 T3 完成
- [ ] 内存使用在预算范围内

#### 战斗动画增强 (Battle Animation Enhancement)
- [x] 攻击动画：冲刺攻击 + 命中特效 ✅ Sprint 13 T4 完成
- [x] 死亡动画：击飞 + 消散粒子 ✅ Sprint 13 T4 完成
- [x] 治疗动画：绿色光环 + 上升粒子 ✅ Sprint 13 T4 完成
- [x] 克制攻击：额外金色闪光特效 ✅ Sprint 13 T4 完成
- [x] 协同触发：单位连线特效 ✅ Sprint 13 T4 完成

#### UI 打磨 (UI Polish)
- [x] 统计数据面板 ✅ Sprint 13 T6 完成
- [x] 确认对话框组件 ✅ Sprint 13 T7 完成
- [x] 错误处理增强 ✅ Sprint 13 T8 完成
- [x] 加载状态指示器 ✅ Sprint 13 T9 完成
- [x] 按钮悬停状态统一 ✅ Sprint 13 T10 完成
- [x] 协同效果提示优化 ✅ Sprint 13 T11 完成

#### 测试执行 (Test Execution)
- [ ] 14 项手动测试执行完毕 (Sprint 13 T1 - Deferred)
- [x] QuickHint 单元测试 ✅ Sprint 13 T5 完成
- [ ] 边界测试通过
- [ ] 兼容性测试通过

---

### Sprint 13 Progress Summary

| Task | Description | Status |
|------|-------------|--------|
| T1 | 执行手动测试 (14项) | ⏸ Deferred |
| T2 | 场景加载性能优化 | ✅ Complete |
| T3 | 战斗帧率优化 | ✅ Complete |
| T4 | 战斗动画增强 | ✅ Complete |
| T5 | QuickHint 单元测试 | ✅ Complete |
| T6 | 统计数据面板 | ✅ Complete |
| T7 | 确认对话框组件 | ✅ Complete |
| T8 | 错误处理增强 | ✅ Complete |
| T9 | 加载状态指示器 | ✅ Complete |
| T10 | 按钮悬停状态统一 | ✅ Complete |
| T11 | 协同效果提示优化 | ✅ Complete |
| T12 | 引导跳过功能 | ✅ Complete |

**Sprint 13 完成度: 11/12 (92%)**

---

### Go / No-Go: NOT READY

**Rationale:**

当前处于 Beta 里程碑的 Sprint 13 阶段，已完成核心性能和动画优化。

**已完成项:**
1. ✅ 场景加载性能优化 (T2)
2. ✅ 战斗帧率优化 (T3)
3. ✅ 战斗动画增强 (T4)
4. ✅ QuickHint 单元测试 (T5)
5. ✅ 统计数据面板 (T6)
6. ✅ 确认对话框组件 (T7)
7. ✅ 错误处理增强 (T8)
8. ✅ 加载状态指示器 (T9)
9. ✅ 按钮悬停状态统一 (T10)
10. ✅ 协同效果提示优化 (T11)
11. ✅ 引导跳过功能 (T12)

**阻塞项 (必须完成):**
1. 手动测试 (14项) 延期 - 需要安排执行

**预计完成时间:**
- Sprint 13 结束日期: 2026-05-28
- Beta 里程碑目标日期: 2026-06-15

**Sign-offs Required:**
- [ ] QA Lead
- [ ] Technical Director
- [ ] Producer
- [ ] Creative Director

---

### Next Steps

1. ~~完成场景加载性能优化~~ ✅ 已完成
2. ~~完成战斗帧率优化~~ ✅ 已完成
3. ~~完成战斗动画增强~~ ✅ 已完成
4. ~~完成统计数据面板~~ ✅ 已完成
5. ~~完成确认对话框组件~~ ✅ 已完成
6. ~~完成错误处理增强~~ ✅ 已完成
7. ~~完成加载状态指示器~~ ✅ 已完成
8. ~~完成按钮悬停状态统一~~ ✅ 已完成
9. ~~完成协同效果提示优化~~ ✅ 已完成
10. ~~完成引导跳过功能~~ ✅ 已完成
11. 执行 14 项手动测试 (T1)
12. 解决发现的任何 S1/S2 Bug
13. 重新运行此检查清单验证发布就绪状态
