# 战斗状态机 (Battle State Machine)

> **Status**: Designed (pending review)
> **Author**: user + game-designer
> **Last Updated**: 2026-03-24
> **Implements Pillar**: 策略深度（战斗流程管理）

## Overview

战斗状态机管理战斗的整体流程，从布局确认到战斗结束。它定义了战斗的所有阶段和阶段之间的转换条件，确保战斗有清晰的开始、进行和结束。

## Player Fantasy

这个系统让战斗有结构感——玩家知道什么时候在布局，什么时候在观战，什么时候战斗结束。清晰的阶段划分让游戏体验更有节奏感。

## Detailed Design

### Core Rules

#### 1. 战斗阶段

| 阶段 | 描述 |
|------|------|
| **Setup（布局）** | 玩家放置单位 |
| **Ready（准备）** | 布局确认，显示敌人信息 |
| **Fighting（战斗中）** | 自动战斗进行 |
| **Victory（胜利）** | 玩家获胜，显示奖励 |
| **Defeat（失败）** | 玩家失败，显示重试选项 |

#### 2. 状态转换

```
[Setup] --确认布局--> [Ready]
[Ready] --开始战斗--> [Fighting]
[Fighting] --敌人全灭--> [Victory]
[Fighting] --我方全灭--> [Defeat]
[Victory] --领取奖励--> [返回关卡选择]
[Defeat] --重试--> [Setup]
[Defeat] --返回--> [返回关卡选择]
```

#### 3. 阶段时长

| 阶段 | 时长 |
|------|------|
| Setup | 无限制 |
| Ready | 1-2 秒（动画）|
| Fighting | 自动，最长 N 秒 |
| Victory | 等待玩家点击 |
| Defeat | 等待玩家选择 |

#### 4. 战斗超时

如果战斗时间超过 `MAX_BATTLE_TIME`，判定为失败（防止无限战斗）。

### States and Transitions

```
状态机定义:

enum BattleState {
    SETUP,
    READY,
    FIGHTING,
    VICTORY,
    DEFEAT
}

信号:
- state_changed(old_state, new_state)
- battle_started()
- battle_ended(result)
```

### Interactions with Other Systems

#### 输入接口

| 来源系统 | 数据 | 用途 |
|----------|------|------|
| **网格布局系统** | 布局确认 | 进入 Ready 阶段 |
| **自动战斗系统** | 战斗结果 | 进入 Victory/Defeat 阶段 |

#### 输出接口

| 目标系统 | 数据 | 用途 |
|----------|------|------|
| **自动战斗系统** | 开始/停止命令 | 控制战斗 |
| **战斗 UI** | 当前状态 | 更新 UI 显示 |
| **资源系统** | 奖励发放 | 胜利时发放奖励 |

## Formulas

### 战斗时长限制

```
MAX_BATTLE_TIME = 180  # 秒（3分钟）
```

### 准备阶段动画时长

```
READY_ANIMATION_DURATION = 1.5  # 秒
```

## Edge Cases

| 情况 | 处理方式 |
|------|----------|
| 战斗时间超过上限 | 强制结束，判定为失败 |
| 在 Setup 阶段退出 | 保存当前布局（可选）|
| 所有单位同时死亡 | 正常进入 Defeat/Victory |

## Dependencies

### 上游依赖

| 系统 | 依赖内容 | 状态 |
|------|----------|------|
| **网格布局系统** | 布局确认信号 | ✅ 已设计 |

### 下游依赖

| 系统 | 依赖内容 |
|------|----------|
| **自动战斗系统** | 状态控制 |
| **战斗 UI** | 状态显示 |

## Tuning Knobs

| 旋钮 | 当前值 | 安全范围 | 影响 |
|------|--------|----------|------|
| `MAX_BATTLE_TIME` | 180s | 60 - 300 | 战斗最长时长 |
| `READY_ANIMATION_DURATION` | 1.5s | 0.5 - 3.0 | 准备动画时长 |

## Visual/Audio Requirements

| 阶段 | 视觉 | 音频 |
|------|------|------|
| Setup | 布局界面 | 背景音乐（轻松）|
| Ready | 倒计时动画 | 准备音效 |
| Fighting | 战斗动画 | 战斗音乐 |
| Victory | 胜利动画、奖励显示 | 胜利音效 |
| Defeat | 失败动画 | 失败音效 |

## UI Requirements

| 阶段 | UI 元素 |
|------|---------|
| Setup | 布局界面、开始按钮 |
| Ready | "战斗开始"提示 |
| Fighting | 战斗画面、暂停按钮 |
| Victory | 奖励界面、继续按钮 |
| Defeat | 重试/返回按钮 |

## Acceptance Criteria

- [ ] **AC1**: 状态转换正确执行
- [ ] **AC2**: 战斗超时正确处理
- [ ] **AC3**: 胜利/失败条件正确判断
- [ ] **AC4**: 状态变化时正确通知 UI
- [ ] **AC5**: 可以在战斗中暂停（可选）

## Open Questions

| # | 问题 | 状态 | 所有者 |
|---|------|------|--------|
| 1 | 是否支持战斗中暂停？ | 待定 | 游戏设计师 |
| 2 | 失败后是否保留布局？ | 待定 | 游戏设计师 |
