# Tutorial System Design

**Version**: 1.0
**Author**: game-designer
**Status**: Draft
**Created**: 2026-03-25

---

## Overview

新手引导系统为首次进入游戏的玩家提供逐步引导，帮助他们理解游戏核心机制，包括单位放置、战斗流程、克制关系和协同效果。引导采用非阻塞式设计，允许玩家跳过并在需要时重新查看。

---

## Player Fantasy

玩家作为新进入游戏的指挥官，通过友好的引导逐步了解游戏世界和战斗机制，而不是被复杂的教程压倒。引导感觉像是自然的探索过程，帮助玩家快速上手并享受游戏乐趣。

---

## Detailed Rules

### 1. 引导触发条件

| 引导类型 | 触发条件 | 显示时机 |
|----------|----------|----------|
| 欢迎引导 | `is_first_launch == true` | 游戏启动后 |
| 商店引导 | `is_first_shop_visit == true` | 进入商店时 |
| 战斗引导 | `is_first_battle == true` | 进入第一关战斗前 |
| 克制提示 | 首次攻击克制目标 | 战斗中 |
| 协同提示 | 首次触发协同效果 | 战斗中 |

### 2. 引导步骤定义

#### 欢迎引导 (3 步)

| Step | Action | UI Highlight | Description |
|------|--------|--------------|-------------|
| 1 | 显示欢迎界面 | 全屏遮罩 | "欢迎来到禅意军团！你将成为一位指挥官，带领你的部队征服五大世界。" |
| 2 | 目标说明 | 全屏遮罩 | "你的目标：组建强大的队伍，击败敌人，征服所有世界！" |
| 3 | 开始按钮 | 高亮按钮 | "准备好了吗？让我们开始吧！" |

#### 商店引导 (4 步)

| Step | Action | UI Highlight | Description |
|------|--------|--------------|-------------|
| 1 | 商店入口 | 高亮商店按钮 | "这是商店，你可以在这里招募新的单位。" |
| 2 | 单位卡片 | 高亮第一个单位 | "每个单位有不同的职业和技能。点击查看详情。" |
| 3 | 购买按钮 | 高亮购买按钮 | "选择你想要的单位，点击购买。" |
| 4 | 确认购买 | 高亮确认按钮 | "确认购买后，单位将加入你的队伍。" |

#### 战斗引导 (5 步)

| Step | Action | UI Highlight | Description |
|------|--------|--------------|-------------|
| 1 | 单位选择 | 高亮单位列表 | "选择一个单位准备放置到战场。" |
| 2 | 放置区域 | 高亮网格区域 | "点击网格放置单位。注意：单位只能放在下方区域。" |
| 3 | 开始战斗 | 高亮开始按钮 | "放置完成后，点击开始战斗！" |
| 4 | 观察战斗 | 无高亮 | "战斗自动进行，观察你的单位与敌人战斗。" |
| 5 | 胜利结算 | 高亮奖励 | "恭喜胜利！获得金币奖励。继续挑战更多关卡！" |

### 3. 引导控制

#### 跳过机制
- 每个引导界面显示"跳过"按钮
- 跳过后标记引导为完成
- 可在设置中重新启用引导

#### 进度保存
- 引导进度保存到 `PlayerData.tutorial_progress`
- 每完成一步立即保存
- 支持断点续引导

#### 强制完成条件
- 战斗引导在第一关通关后自动标记完成
- 克制提示在触发 3 次后不再显示
- 协同提示在触发 3 次后不再显示

---

## Formulas

### 引导显示判断

```gdscript
func should_show_tutorial(tutorial_id: String) -> bool:
    # 检查是否已启用引导
    if not player_data.settings.get("tutorial_enabled", true):
        return false

    # 检查是否已完成
    if tutorial_id in player_data.completed_tutorials:
        return false

    # 检查触发条件
    match tutorial_id:
        "welcome":
            return player_data.is_first_launch
        "shop":
            return player_data.is_first_shop_visit
        "battle":
            return player_data.is_first_battle
        _:
            return false
```

### 引导步骤进度

```gdscript
func get_tutorial_step(tutorial_id: String) -> int:
    return player_data.tutorial_progress.get(tutorial_id, 0)

func advance_tutorial_step(tutorial_id: String) -> void:
    var current = get_tutorial_step(tutorial_id)
    player_data.tutorial_progress[tutorial_id] = current + 1
    SaveManager.save_game()
```

---

## Edge Cases

### 1. 引导中断
- **场景**: 玩家在引导过程中退出游戏
- **处理**: 进度已保存，下次进入从当前步骤继续

### 2. 引导跳过后重置
- **场景**: 玩家想重新查看引导
- **处理**: 设置菜单提供"重置引导"选项

### 3. 多个引导排队
- **场景**: 玩家快速完成多个首次操作
- **处理**: 引导队列，按优先级依次显示

### 4. 网格放置失败
- **场景**: 战斗引导中玩家放置到无效位置
- **处理**: 显示错误提示，引导步骤不前进

---

## Dependencies

| System | Usage |
|--------|-------|
| SaveManager | 引导进度持久化 |
| PlayerData | 引导状态存储 |
| UIManager | 弹窗和遮罩显示 |
| BattleManager | 战斗状态检测 |
| EventBus | 引导事件触发 |

---

## Tuning Knobs

| Parameter | Default | Range | Description |
|-----------|---------|-------|-------------|
| `tutorial_enabled` | true | [true, false] | 全局引导开关 |
| `hint_display_time` | 3.0 | [1.0, 5.0] | 提示显示时间(秒) |
| `highlight_animation_duration` | 0.3 | [0.1, 0.5] | 高亮动画时长 |
| `max_hint_repeat` | 3 | [1, 5] | 提示最大重复次数 |

---

## Acceptance Criteria

- [ ] 新玩家首次启动可完成完整欢迎引导
- [ ] 商店引导正确高亮所有 UI 元素
- [ ] 战斗引导引导玩家完成首次战斗
- [ ] 克制关系在战斗中正确提示
- [ ] 协同效果触发时正确提示
- [ ] 引导进度正确保存和恢复
- [ ] 跳过功能正常工作
- [ ] 设置中可重置引导

---

## Implementation Notes

### 数据结构

```gdscript
# PlayerData 中新增字段
@export var tutorial_progress: Dictionary = {}  # {tutorial_id: step}
@export var completed_tutorials: Array[String] = []
@export var is_first_launch: bool = true
@export var is_first_shop_visit: bool = true
@export var is_first_battle: bool = true

# 设置
settings = {
    "tutorial_enabled": true,
    # ...
}
```

### 引导管理器结构

```gdscript
class_name TutorialManager
extends Node

signal tutorial_started(tutorial_id: String)
signal tutorial_step_changed(tutorial_id: String, step: int)
signal tutorial_completed(tutorial_id: String)

var current_tutorial: String = ""
var current_step: int = 0

func start_tutorial(tutorial_id: String) -> void:
    pass

func advance_step() -> void:
    pass

func skip_tutorial() -> void:
    pass

func show_hint(message: String, highlight_node: Node = null) -> void:
    pass
```

---

## Visual Design Reference

### 高亮遮罩
- 半透明黑色背景 (alpha = 0.7)
- 高亮区域使用白色边框
- 箭头指向高亮元素

### 提示弹窗
- 底部居中显示
- 半透明白色背景
- 黑色文字，最大 2 行
- "下一步" 和 "跳过" 按钮
