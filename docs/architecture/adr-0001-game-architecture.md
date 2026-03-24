# ADR-0001: 游戏架构

## Status
Proposed

## Date
2026-03-24

## Context

### Problem Statement
禅意军团是一款回合制自动战斗游戏，需要清晰的架构来管理：
1. 游戏状态（主菜单、关卡选择、布局、战斗、结算）
2. 场景切换和数据传递
3. 全局游戏数据的访问

### Constraints
- 目标平台：移动端（需考虑内存和加载性能）
- 引擎：Godot 4.6
- 语言：GDScript
- 单人开发，需要简单可维护的架构

### Requirements
- 必须支持清晰的游戏状态切换
- 必须支持玩家数据的全局访问
- 必须支持场景之间的数据传递
- 必须在移动端上运行流畅

## Decision

采用 **Autoload 单例 + 场景树** 的架构模式。

### 架构图

```
┌─────────────────────────────────────────────────────────┐
│                    Autoload Singletons                   │
├─────────────────────────────────────────────────────────┤
│  GameManager    │  SaveManager   │  AudioManager        │
│  - game_state   │  - player_data │  - bgm/sfx control   │
│  - current_level│  - save/load   │                      │
├─────────────────────────────────────────────────────────┤
│                      Scene Tree                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   MainMenu ──► LevelSelect ──► BattleSetup ──► Battle   │
│                      │                │            │     │
│                      └────────────────┴────────────┘     │
│                           返回/重试                       │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 核心单例

| 单例 | 职责 |
|------|------|
| **GameManager** | 游戏状态、当前关卡、全局配置 |
| **SaveManager** | 玩家数据、存档/读档 |
| **AudioManager** | 背景音乐、音效控制 |
| **UnitDatabase** | 单位定义数据（只读）|

### 场景结构

```
scenes/
├── main_menu.tscn       # 主菜单
├── level_select.tscn    # 关卡选择
├── battle_setup.tscn    # 布局阶段
├── battle.tscn          # 战斗场景
└── ui/
    ├── hud.tscn         # 战斗 HUD
    ├── shop.tscn        # 商店界面
    └── settings.tscn    # 设置界面
```

### 状态管理

```gdscript
# GameManager.gd (Autoload)
enum GameState {
    MAIN_MENU,
    LEVEL_SELECT,
    BATTLE_SETUP,
    BATTLE,
    SHOP,
    SETTINGS
}

var current_state: GameState = GameState.MAIN_MENU
var current_level_id: String = ""

signal state_changed(old_state: GameState, new_state: GameState)

func change_state(new_state: GameState) -> void:
    var old_state = current_state
    current_state = new_state
    state_changed.emit(old_state, new_state)
```

### 数据流

```
[关卡选择]
    │
    ▼ 选择关卡
[BattleSetup] ◄─── GameManager.current_level_id
    │
    ▼ 确认布局
[Battle] ◄─── GridLayout 数据
    │
    ▼ 战斗结束
[结算界面] ───► SaveManager.add_gold(reward)
    │
    ▼ 返回
[LevelSelect]
```

## Alternatives Considered

### Alternative 1: 全局场景管理器 (SceneManager)
- **Description**: 创建一个 SceneManager 单例负责所有场景切换
- **Pros**: 集中管理场景切换，可以添加转场动画
- **Cons**: 增加一层间接调用，简单场景切换变得复杂
- **Rejection Reason**: Godot 的 `get_tree().change_scene_to_file()` 已足够，过度设计

### Alternative 2: 依赖注入模式
- **Description**: 每个场景通过依赖注入获取需要的服务
- **Cons**: GDScript 的依赖注入生态不成熟，增加复杂度
- **Rejection Reason**: 对单人开发过度设计，Autoload 更简单

### Alternative 3: 无单例，场景间传递所有数据
- **Description**: 所有数据通过场景参数传递
- **Cons**: 数据传递链过长，容易出错
- **Rejection Reason**: 玩家数据需要全局访问，单例更合适

## Consequences

### Positive
- 简单直观，符合 Godot 最佳实践
- 数据访问方便，无需复杂传递
- 状态清晰，易于调试
- 适合单人开发

### Negative
- 单例可能导致隐式依赖
- 测试时需要模拟单例
- 全局状态可能被意外修改

### Risks
- **风险**: 单例过多导致全局状态混乱
- **缓解**: 限制单例数量，每个单例职责明确

## Performance Implications
- **CPU**: 最小，单例访问是 O(1)
- **Memory**: 单例常驻内存，但数据量小（<1MB）
- **Load Time**: 游戏启动时加载单例，可接受
- **Network**: 不适用（单机游戏）

## Migration Plan
这是新项目，无需迁移。

## Validation Criteria
1. 场景切换正常，无数据丢失
2. 玩家数据在场景间正确保持
3. 游戏状态切换符合设计
4. 内存占用在合理范围内

## Related Decisions
- 相关设计文档: `design/gdd/game-concept.md`
- 相关系统: 战斗状态机 (`design/gdd/battle-state-machine.md`)
