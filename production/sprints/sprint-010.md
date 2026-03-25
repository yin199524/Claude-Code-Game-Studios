# Sprint 10 — 2026-04-03 to 2026-04-16

## Sprint Goal

实现成就系统和每日任务系统，完善主菜单和商店 UI，为玩家提供长期游玩目标和奖励机制。

---

## Capacity

- Total days: 10
- Buffer (20%): 2 days
- Available: ~8 days of effective work

---

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T1 | 成就系统数据结构设计 | game-designer | 0.5 | — | ✅ Complete |
| T2 | 成就管理器实现 | gameplay-programmer | 1.0 | T1 | ✅ Complete |
| T3 | 成就解锁检测逻辑 | gameplay-programmer | 0.5 | T2 | ✅ Complete |
| T4 | 成就 UI 面板 | ui-programmer | 0.75 | T2 | ✅ Complete |
| T5 | 每日任务系统设计 | game-designer | 0.5 | — | ✅ Complete |
| T6 | 每日任务管理器实现 | gameplay-programmer | 0.75 | T5 | ✅ Complete |
| T7 | 任务刷新和奖励发放 | gameplay-programmer | 0.5 | T6 | ✅ Complete |
| T8 | 每日任务 UI | ui-programmer | 0.5 | T6 | ✅ Complete |

**Total Must Have: 5.5 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T9 | 主菜单 UI 增强 | ui-programmer | 1.0 | — | ✅ Complete |
| T10 | 商店 UI 增强 | ui-programmer | 0.75 | — | 🔲 Pending |
| T11 | 成就通知弹窗 | ui-programmer | 0.5 | T4 | ✅ Complete |
| T12 | 进度系统整合 | gameplay-programmer | 0.5 | T2, T6 | 🔲 Pending |

**Total Should Have: 2.75 days**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T13 | 成就统计和展示 | ui-programmer | 0.5 | T4 | 🔲 Pending |
| T14 | 连续登录奖励 | gameplay-programmer | 0.5 | T6 | 🔲 Pending |

**Total Nice to Have: 1.0 day**

---

## Total Estimated: 9.25 days (within capacity)

---

## Definition of Done

- [ ] 玩家可以查看所有成就及其进度
- [ ] 成就解锁时有视觉和音效反馈
- [ ] 每日任务每天自动刷新
- [ ] 完成任务可领取奖励
- [ ] 主菜单 UI 美观且功能完整
- [ ] 商店 UI 展示单位详情和协同信息
- [ ] 所有数据正确持久化

---

## Achievement System Design

### 成就分类

| 类别 | 说明 | 示例 |
|------|------|------|
| PROGRESS | 进度类 | 通关第 N 关 |
| COLLECTION | 收集类 | 收集 N 个单位 |
| COMBAT | 战斗类 | 累计击败 N 个敌人 |
| UPGRADE | 升级类 | 将单位升到最高级 |
| SYNERGY | 协同类 | 触发特定协同效果 |
| SPECIAL | 特殊类 | 使用特定策略通关 |

### 成就列表 (V1)

| ID | 名称 | 类别 | 条件 | 奖励 |
|----|------|------|------|------|
| ach_first_victory | 初战告捷 | PROGRESS | 通关第一关 | 100 金币 |
| ach_forest_master | 森林征服者 | PROGRESS | 通关森林世界 | 200 金币 |
| ach_desert_master | 沙漠征服者 | PROGRESS | 通关沙漠世界 | 300 金币 |
| ach_ice_master | 冰原征服者 | PROGRESS | 通关冰原世界 | 400 金币 |
| ach_volcano_master | 火山征服者 | PROGRESS | 通关火山世界 | 500 金币 |
| ach_shadow_master | 暗影终结者 | PROGRESS | 通关暗影世界 | 1000 金币 |
| ach_unit_collector_5 | 初收集者 | COLLECTION | 收集 5 个不同单位 | 150 金币 |
| ach_unit_collector_10 | 收藏家 | COLLECTION | 收集 10 个不同单位 | 300 金币 |
| ach_warrior_synergy | 战士兄弟 | SYNERGY | 触发战士协同效果 | 100 金币 |
| ach_mage_synergy | 法术共鸣 | SYNERGY | 触发法师协同效果 | 100 金币 |
| ach_first_upgrade | 初次升级 | UPGRADE | 升级任意单位 1 次 | 100 金币 |
| ach_max_upgrade | 满级大师 | UPGRADE | 将单位升到满级 | 500 金币 |
| ach_kill_100 | 百人斩 | COMBAT | 累计击败 100 个敌人 | 200 金币 |
| ach_kill_1000 | 千人斩 | COMBAT | 累计击败 1000 个敌人 | 1000 金币 |

---

## Daily Mission System Design

### 任务类型

| 类型 | 说明 | 刷新规则 |
|------|------|----------|
| DAILY | 每日任务 | 每天 0 点刷新 |
| WEEKLY | 每周任务 | 每周一 0 点刷新 |

### 每日任务池

| ID | 名称 | 目标 | 奖励 |
|----|------|------|------|
| dm_win_3 | 胜利者 | 通关 3 关 | 100 金币 |
| dm_upgrade_1 | 强化部队 | 升级 1 个单位 | 50 金币 |
| dm_buy_unit | 招募新兵 | 购买 1 个单位 | 50 金币 |
| dm_defeat_20 | 清剿敌人 | 击败 20 个敌人 | 80 金币 |
| dm_use_synergy | 战术大师 | 触发协同效果 3 次 | 100 金币 |

### 任务机制

- 每天随机分配 3 个每日任务
- 任务进度实时更新
- 完成后手动领取奖励
- 未完成次日清零刷新

---

## UI Enhancement Plan

### 主菜单增强

- [ ] 背景动画效果
- [ ] 按钮悬停效果
- [ ] 显示玩家等级和金币
- [ ] 快捷入口：继续游戏、每日任务
- [ ] 成就和任务图标提示

### 商店 UI 增强

- [ ] 单位卡片显示职业图标
- [ ] 悬停显示单位详情面板
- [ ] 显示协同效果提示
- [ ] 筛选功能（按职业、稀有度）
- [ ] 购买确认弹窗

---

## Technical Notes

### 数据结构

```gdscript
# 成就定义
class AchievementDefinition:
    var id: String
    var display_name: String
    var description: String
    var category: AchievementCategory
    var target_value: int
    var reward_gold: int

# 成就进度
class AchievementProgress:
    var achievement_id: String
    var current_value: int
    var is_unlocked: bool
    var unlocked_at: int  # timestamp

# 每日任务定义
class DailyMissionDefinition:
    var id: String
    var display_name: String
    var description: String
    var target_value: int
    var reward_gold: int

# 每日任务进度
class DailyMissionProgress:
    var mission_id: String
    var current_value: int
    var is_completed: bool
    var is_reward_claimed: bool
```

### 存档集成

- 成就进度保存到 `SaveManager`
- 每日任务进度和刷新时间需要记录
- 使用本地时间判断刷新

---

## Dependencies

- SaveManager 存档系统
- UnitDatabase 单位数据
- LevelDatabase 关卡数据
- SynergyManager 协同系统
- ShopSystem 商店系统
