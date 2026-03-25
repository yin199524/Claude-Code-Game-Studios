## Release Checklist: v0.5.0-beta — All Platforms

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
- [ ] Build version number correctly set (0.5.0-beta)
- [ ] Build is reproducible from tagged commit

---

### Quality Gates

- [ ] Zero S1 (Critical) bugs
- [ ] Zero S2 (Major) bugs — or documented exceptions with producer approval
- [ ] All critical path features tested and signed off by QA
- [ ] Performance within budgets:
  - [ ] Target FPS met on minimum spec hardware (60 FPS)
  - [ ] Memory usage within budget
  - [ ] Load times within budget (< 2s per scene)
  - [ ] No memory leaks over extended play sessions
- [ ] No regression from previous build (v0.4.0-alpha)
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
- [ ] 引导跳过功能 (Sprint 13 T12)

#### 性能优化 (Performance Optimization)
- [ ] 场景加载时间 < 2 秒 (Sprint 13 T2)
- [ ] 战斗帧率稳定 60 FPS (Sprint 13 T3)
- [ ] 内存使用在预算范围内

#### 战斗动画增强 (Battle Animation Enhancement)
- [ ] 攻击动画：冲刺攻击 + 命中特效 (Sprint 13 T4)
- [ ] 死亡动画：击飞 + 消散粒子
- [ ] 治疗动画：绿色光环
- [ ] 克制攻击：额外闪光特效
- [ ] 协同触发：单位连线特效

#### UI 打磨 (UI Polish)
- [ ] 统计数据面板 (Sprint 13 T6)
- [ ] 确认对话框组件 (Sprint 13 T7)
- [ ] 错误处理增强 (Sprint 13 T8)
- [ ] 加载状态指示器 (Sprint 13 T9)
- [ ] 按钮悬停状态统一 (Sprint 13 T10)
- [ ] 协同效果提示优化 (Sprint 13 T11)

#### 测试执行 (Test Execution)
- [ ] 14 项手动测试执行完毕 (Sprint 13 T1)
- [ ] 单元测试全部通过
- [ ] 边界测试通过
- [ ] 兼容性测试通过

---

### Go / No-Go: NOT READY

**Rationale:**

当前处于 Beta 里程碑的 Sprint 13 阶段，以下关键项目尚未完成：

**阻塞项 (必须完成):**
1. 性能优化未执行 - 场景加载时间和战斗帧率未验证
2. 手动测试 (14项) 未执行
3. 战斗动画增强未实现
4. UI 打磨项 (6项) 未完成

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

1. 完成 Sprint 13 所有待办任务
2. 执行性能分析和优化
3. 完成 14 项手动测试
4. 解决发现的任何 S1/S2 Bug
5. 重新运行此检查清单验证发布就绪状态
