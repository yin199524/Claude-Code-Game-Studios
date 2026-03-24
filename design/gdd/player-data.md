# 玩家数据 (Player Data)

> **Status**: Designed (pending review)
> **Author**: user + game-designer
> **Last Updated**: 2026-03-24
> **Implements Pillar**: 收集满足（追踪玩家收集的单位）

## Overview

玩家数据系统定义并管理玩家的存档数据结构，包括拥有的单位、金币余额、解锁的关卡等。它是所有进度追踪和资源管理的数据载体，存档系统负责持久化这些数据。

## Player Fantasy

这个系统服务于「收集满足」支柱。玩家应该能够清晰地看到自己的进度——收集了多少单位、积累了多少金币、解锁了哪些关卡。数据的持久化让玩家的投入不会丢失，增强了长期留存。

## Detailed Design

### Core Rules

#### 1. 玩家数据结构

```gdscript
class_name PlayerData extends Resource

# 元数据
@export var save_version: int = 1
@export var created_at: int      # Unix timestamp
@export var last_played: int     # Unix timestamp

# 资源
@export var gold: int = 0

# 收集
@export var owned_units: Array[OwnedUnit] = []

# 进度
@export var unlocked_levels: Array[String] = []  # Level IDs
@export var level_progress: Dictionary = {}      # {level_id: LevelProgress}
```

#### 2. 拥有单位结构

```gdscript
class_name OwnedUnit extends Resource

@export var unit_id: String      # 引用 UnitDefinition.id
@export var level: int = 1       # 单位等级 (MVP 阶段可能不使用)
@export var obtained_at: int     # 获得时间 (Unix timestamp)
```

#### 3. 关卡进度结构

```gdscript
class_name LevelProgress extends Resource

@export var completed: bool = false
@export var best_time: float = -1.0   # 最佳通关时间（秒），-1 表示未完成
@export var stars: int = 0            # 星级评价（如果需要）
```

#### 4. 初始状态

新玩家默认数据：
- `gold`: 100（初始金币）
- `owned_units`: 包含 1 个初始单位（新手引导单位）
- `unlocked_levels`: ["level_01"]
- `level_progress`: {}

#### 5. 数据约束

| 字段 | 约束 |
|------|------|
| `gold` | >= 0，不能为负 |
| `owned_units` | 同一 unit_id 最多一个实例 |
| `level` | >= 1，最大值由升级系统定义 |
| `unlocked_levels` | 只能包含关卡定义中存在的 ID |

### States and Transitions

玩家数据本身无运行时状态转换。数据在游戏运行期间被修改，由存档系统负责持久化。

状态变化的时机：
- **战斗结束**：金币增减、关卡进度更新
- **商店购买**：金币减少、获得新单位
- **解锁关卡**：unlocked_levels 添加新 ID

### Interactions with Other Systems

#### 输出接口（其他系统从此获取数据）

| 目标系统 | 输出数据 | 用途 |
|----------|----------|------|
| **存档系统** | 完整 PlayerData 对象 | 持久化到本地存储 |
| **资源系统** | gold | 余额查询、消耗验证 |
| **关卡解锁系统** | unlocked_levels, level_progress | 判断解锁条件 |
| **进度系统** | 全部数据 | 计算整体进度 |
| **布局编辑 UI** | owned_units | 显示可用单位列表 |

#### 输入接口（修改此系统数据）

| 来源系统 | 输入数据 | 用途 |
|----------|----------|------|
| **资源系统** | gold 变更 | 金币增减 |
| **商店系统** | 新 OwnedUnit | 购买单位 |
| **关卡系统** | level_progress 更新 | 完成关卡 |

## Formulas

### 初始金币

```
STARTING_GOLD = 100
```

### 金币上限

```
MAX_GOLD = 999999
```

### 单位等级上限

```
MAX_UNIT_LEVEL = 10  # 待升级系统定义
```

### 数据大小估算

| 数据类型 | 估算大小 | 说明 |
|----------|----------|------|
| 元数据 | ~100 bytes | 版本、时间戳 |
| 金币 | 4 bytes | int32 |
| 拥有单位 | ~50 bytes/单位 | 假设 100 单位 = 5KB |
| 关卡进度 | ~20 bytes/关卡 | 假设 50 关卡 = 1KB |
| **总计** | ~10KB | 可接受 |

## Edge Cases

### 1. 金币边界

| 情况 | 处理方式 |
|------|----------|
| 金币不足购买 | 拒绝交易，返回错误 |
| 金币溢出（超过上限） | 截断到 MAX_GOLD |
| 金币为负 | 数据验证失败，重置为 0 |

### 2. 单位重复

| 情况 | 处理方式 |
|------|----------|
| 尝试添加已拥有的单位 | MVP 阶段：拒绝（不重复）<br>后期：可能是升星材料 |
| 单位引用不存在 | 数据验证警告，标记为无效 |

### 3. 关卡进度异常

| 情况 | 处理方式 |
|------|----------|
| 关卡未解锁但已完成 | 数据不一致，重置为未完成 |
| 关卡 ID 不存在 | 数据验证警告，忽略该条目 |
| best_time 为负数 | 表示未完成，合法值 |

### 4. 存档版本

| 情况 | 处理方式 |
|------|----------|
| 旧版本存档 | 迁移到新版本格式 |
| 新版本存档（版本号更高） | 警告：存档来自未来版本 |

## Dependencies

### 上游依赖

**无。** 此系统是 Foundation 层，没有依赖任何其他系统。

### 下游依赖

| 系统 | 依赖类型 | 依赖内容 |
|------|----------|----------|
| **存档系统** | 硬依赖 | 完整 PlayerData 对象 |
| **资源系统** | 硬依赖 | gold 余额 |
| **关卡解锁系统** | 硬依赖 | unlocked_levels, level_progress |
| **进度系统** | 硬依赖 | 全部数据 |
| **布局编辑 UI** | 硬依赖 | owned_units |

## Tuning Knobs

| 旋钮 | 当前值 | 安全范围 | 影响 |
|------|--------|----------|------|
| `STARTING_GOLD` | 100 | 50 - 500 | 新玩家初始资源 |
| `MAX_GOLD` | 999999 | 100000 - 9999999 | 金币上限 |
| `MAX_UNIT_LEVEL` | 10 | 5 - 50 | 单位等级上限（待定义） |

## Visual/Audio Requirements

此系统是纯数据系统，无直接视觉/音频需求。数据展示由 UI 系统负责。

## UI Requirements

### 显示需求

| 场景 | 显示内容 |
|------|----------|
| 主界面 | 金币余额 |
| 单位列表 | 拥有单位数量 / 总数量 |
| 关卡选择 | 关卡完成状态 |

### 数据格式

| 数据 | 显示格式 |
|------|----------|
| 金币 | 数字缩写（如 1.2K, 150K） |
| 单位数量 | "12 / 50" |
| 完成状态 | 星星、勾选、进度条 |

## Acceptance Criteria

### 功能验收

- [ ] **AC1**: 新玩家创建时自动初始化默认数据
- [ ] **AC2**: 金币变更正确保存到数据结构
- [ ] **AC3**: 购买单位后 owned_units 正确更新
- [ ] **AC4**: 完成关卡后 level_progress 正确更新
- [ ] **AC5**: 解锁关卡后 unlocked_levels 正确更新

### 数据验证

- [ ] **AC6**: 金币为负时数据验证失败
- [ ] **AC7**: 重复单位 ID 数据验证失败
- [ ] **AC8**: 无效关卡 ID 数据验证警告

### 性能验收

- [ ] **AC9**: 数据结构内存占用 < 100KB
- [ ] **AC10**: 数据查询耗时 < 1ms

## Open Questions

| # | 问题 | 状态 | 所有者 |
|---|------|------|--------|
| 1 | 单位是否可以重复拥有？如果可以，用于什么？ | 待定 | 游戏设计师 |
| 2 | 单位升级系统如何设计？等级如何影响属性？ | 待定 | 游戏设计师 |
| 3 | 是否需要云存档同步？ | 待定 | 技术总监 |
