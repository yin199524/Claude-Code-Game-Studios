# Sprint 4 — 2026-03-24 to 2026-03-30

## Sprint Goal

打磨游戏体验，完善 UI 视觉反馈，提升整体品质感，确保 MVP 可以交付测试。

## Capacity

- Total days: 7
- Buffer (20%): 1.4 days (reserved for unplanned work)
- Available: ~5.5 days of effective work

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T1 | UI 视觉美化 - 主菜单 | ui-programmer | 0.5 | Sprint 3 | 主菜单有背景、按钮样式统一 |
| T2 | UI 视觉美化 - 关卡选择 | ui-programmer | 0.5 | Sprint 3 | 关卡卡片样式、解锁状态清晰 |
| T3 | 战斗 UI 完善战斗反馈 | ui-programmer | 0.5 | Sprint 3 | 伤害数字动画、单位选中高亮 |
| T4 | 商店 UI 完善 | ui-programmer | 0.5 | Sprint 3 | 单位卡片样式、购买反馈 |
| T5 | 添加音效占位 | audio-director | 0.5 | — | 按钮、战斗、购买有音效 |
| T6 | 游戏流程串联测试 | qa-tester | 0.5 | T1-T4 | 完整流程可玩无阻塞 |

**Total Must Have: 3 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T7 | 单位信息提示 | ui-programmer | 0.25 | T2 | 鼠标悬停显示单位详情 |
| T8 | 战斗结果动画 | ui-programmer | 0.25 | T3 | 胜利/失败有动画效果 |
| T9 | 加载过渡动画 | ui-programmer | 0.25 | — | 场景切换有淡入淡出 |
| T10 | 金币变化动画 | ui-programmer | 0.25 | T4 | 金币增减有飘字效果 |

**Total Should Have: 1 day**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------------|-----------|--------------|---------------------|
| T11 | 主菜单背景动态效果 | ui-programmer | 0.25 | T1 | 背景有轻微动画 |
| T12 | 单位攻击动画 | ui-programmer | 0.25 | T3 | 单位攻击时有简单动画 |
| T13 | 粒子效果占位 | technical-artist | 0.25 | — | 胜利/失败有粒子效果 |
| T14 | 敌人波次预告 | ui-programmer | 0.25 | T2 | 显示关卡敌人数量 |

**Total Nice to Have: 1 day**

---

## Total Estimated: 5 days (within 5.5 available days + buffer)

---

## Carryover from Previous Sprint

无

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| UI 美化耗时超预期 | Medium | Low | 使用简单样式，避免过度设计 |
| 音效资源缺失 | Low | Low | 使用占位音效或跳过 |

---

## Dependencies on External Factors

- 无外部依赖

---

## Definition of Done for this Sprint

- [ ] 所有 Must Have 任务完成
- [ ] UI 风格统一，按钮可点击状态清晰
- [ ] 战斗反馈明显（伤害数字、单位状态）
- [ ] 商店购买流程流畅
- [ ] 完整游戏流程可玩
- [ ] MVP 验收标准全部通过

---

## Daily Checkpoints

| Day | Focus |
|-----|-------|
| Day 1 | 主菜单 UI 美化 (T1) |
| Day 2 | 关卡选择 UI 美化 (T2) |
| Day 3 | 战斗 UI 完善 (T3) |
| Day 4 | 商店 UI + 音效 (T4, T5) |
| Day 5 | 流程测试 + Should Have (T6, T7-T10) |
| Day 6 | Nice to Have 任务 (T11-T14) |
| Day 7 | 最终验证 + 收尾 |

---

## MVP Final Checklist

完成 Sprint 4 后，应满足 MVP 里程碑验收标准：

- [x] 玩家可以放置单位到 3x3 网格
- [x] 战斗自动进行，单位按 AI 选择目标
- [x] 战斗有明确的胜利/失败结果
- [x] 胜利后获得金币奖励
- [x] 金币可以购买新单位
- [ ] 核心循环可以重复进行 3+ 次而不无聊（需验证）

---

## Notes

- 本次 Sprint 聚焦于「感觉打磨」，让游戏感觉更完整
- UI 美化不需要专业美术，使用 Godot 内置控件样式即可
- 音效可以使用免费资源或简单占位
- 目标是让 MVP 可以交付给其他玩家测试
