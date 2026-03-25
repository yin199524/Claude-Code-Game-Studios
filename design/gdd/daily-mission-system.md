# 每日任务系统设计文档

## Overview

每日任务系统为玩家提供日常游玩目标和奖励，鼓励玩家每天登录游戏。系统每天随机生成一组任务，完成后可获得金币奖励。

## Player Fantasy

**"每天都有新的挑战等待着我，完成任务就能获得丰厚奖励。"**

玩家希望：
- 每天有明确的游戏目标
- 获得日常登录的动力
- 任务难度适中，不会过于繁重
- 奖励有价值且值得追求

## Detailed Rules

### 任务刷新机制

1. **刷新时间**: 每天 0:00 (本地时间)
2. **任务数量**: 每天 3 个任务
3. **随机选择**: 从任务池中随机抽取
4. **进度清零**: 刷新时所有未完成进度清零
5. **已领取任务**: 刷新时重置为未领取状态

### 任务完成机制

1. **实时检测**: 游戏过程中实时检测进度
2. **手动领取**: 完成后需要手动点击领取奖励
3. **奖励发放**: 领取时发放金币到玩家账户
4. **完成标记**: 领取后标记为已完成

### 任务类型

| 类型 | 刷新规则 | 数量 |
|------|----------|------|
| DAILY | 每天刷新 | 3 个 |

### 任务池

当前版本包含 5 种每日任务：

| ID | 名称 | 目标 | 基础奖励 |
|----|------|------|----------|
| dm_win_3 | 胜利者 | 通关 3 关 | 100 金币 |
| dm_upgrade_1 | 强化部队 | 升级 1 个单位 | 50 金币 |
| dm_buy_unit | 招募新兵 | 购买 1 个单位 | 50 金币 |
| dm_defeat_20 | 清剿敌人 | 击败 20 个敌人 | 80 金币 |
| dm_use_synergy | 战术大师 | 触发协同效果 3 次 | 100 金币 |

## Formulas

### 刷新时间判断

```gdscript
# 判断是否需要刷新
func should_refresh(last_refresh_time: int) -> bool:
    var last_date = Time.get_date_dict_from_unix_time(last_refresh_time)
    var current_date = Time.get_date_dict_from_unix_time(Time.get_unix_time_from_system())

    return last_date.year != current_date.year or \
           last_date.month != current_date.month or \
           last_date.day != current_date.day
```

### 任务奖励

固定奖励值，后续可扩展为：
- 基于玩家等级的奖励倍率
- VIP 玩家额外奖励
- 连续完成奖励加成

## Edge Cases

### 跨天时游戏在线

- 游戏中检测日期变化
- 日期变化时立即刷新任务
- 弹出通知提示玩家

### 离线多天

- 只刷新一次（当前日期）
- 不补发错过的任务
- 保持"每日"的节奏感

### 时间修改作弊

- 使用服务器时间验证（如有多人模式）
- 单机模式下信任本地时间
- 检测到大幅时间回退可重置进度

### 任务无法完成

- 某些任务可能因玩家进度无法完成（如没有单位可升级）
- 任务设计时考虑新手友好性
- 可选：提供任务刷新功能（消耗资源）

## Dependencies

- **SaveManager**: 持久化任务进度和刷新时间
- **EventBus**: 跨系统事件通信
- **LevelManager**: 通关任务检测
- **ShopSystem**: 购买任务检测
- **BattleManager**: 杀敌任务检测
- **SynergyManager**: 协同任务检测

## Tuning Knobs

| 参数 | 默认值 | 说明 |
|------|--------|------|
| DAILY_MISSION_COUNT | 3 | 每日任务数量 |
| MISSION_REFRESH_HOUR | 0 | 每日刷新小时 (0-23) |
| MISSION_POOL_SIZE | 5 | 任务池大小 |
| REWARD_BASE_MULTIPLIER | 1.0 | 奖励基础倍率 |

## Acceptance Criteria

- [ ] 每天 0:00 自动刷新任务
- [ ] 随机从任务池中选择 3 个任务
- [ ] 任务进度实时更新
- [ ] 完成后可手动领取奖励
- [ ] 奖励正确发放到玩家账户
- [ ] 跨天时在线玩家收到刷新通知
- [ ] 任务进度正确持久化
- [ ] 刷新时间正确持久化
- [ ] UI 清晰展示任务目标和进度
- [ ] 已完成的任务有明显视觉区分
