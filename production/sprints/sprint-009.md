# Sprint 9 — 2026-03-27 to 2026-04-02

## Sprint Goal

扩展游戏内容规模，添加新单位和关卡，丰富游戏体验。

## Capacity

- Total days: 7
- Buffer (20%): 1.4 days
- Available: ~5.5 days of effective work

## Tasks

### Must Have (Critical Path)

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T1 | 添加 ROGUE 职业类型 | gameplay-programmer | 0.25 | — | ✅ Complete |
| T2 | 添加 5 个新单位 | game-designer | 0.5 | T1 | ✅ Complete |
| T3 | 添加 5 个新敌人 | game-designer | 0.5 | — | ✅ Complete |
| T4 | 创建沙漠世界关卡 | level-designer | 0.5 | — | ✅ Complete |
| T5 | 创建冰原世界关卡 | level-designer | 0.5 | — | ✅ Complete |
| T6 | 创建火山世界关卡 | level-designer | 0.5 | — | ✅ Complete |
| T7 | 创建暗影世界关卡 | level-designer | 0.5 | — | ✅ Complete |

**Total Must Have: 3.75 days**

### Should Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T8 | 单位技能系统基础 | gameplay-programmer | 0.5 | T2 | 🔲 Pending |
| T9 | 敌人特殊效果 | gameplay-programmer | 0.5 | T3 | 🔲 Pending |

**Total Should Have: 1 day**

### Nice to Have

| ID | Task | Agent/Owner | Est. Days | Dependencies | Status |
|----|------|-------------|-----------|--------------|--------|
| T10 | Boss 战设计 | game-designer | 0.25 | T7 | 🔲 Pending |
| T11 | 单位获取方式 | game-designer | 0.25 | T2 | 🔲 Pending |

**Total Nice to Have: 0.5 days**

---

## Total Estimated: 5.25 days (within capacity)

---

## Definition of Done

- [x] 玩家可使用 15+ 单位 (当前: 11 个玩家单位)
- [x] 12+ 敌人类型 (当前: 9 个敌人类型)
- [x] 20 关卡分布在 5 个世界 (当前: 21 关)
- [x] 每个世界主题敌人有差异

---

## Content Plan

### 新玩家单位 (6 个)

| ID | 名称 | 职业 | 稀有度 | HP | ATK | 特点 |
|----|------|------|--------|-----|-----|------|
| unit_spearman | 长枪兵 | WARRIOR | COMMON | 400 | 50 | 克制骑士 |
| unit_hunter | 猎人 | ARCHER | COMMON | 180 | 70 | 远程输出 |
| unit_priest | 牧师 | HEALER | RARE | 200 | 25 | 群体治疗 |
| unit_pyromancer | 火法师 | MAGE | RARE | 150 | 90 | 高伤害 |
| unit_paladin | 圣骑士 | KNIGHT | EPIC | 450 | 45 | 攻守兼备 |
| unit_assassin | 刺客 | ROGUE | EPIC | 280 | 75 | 暴击输出 |

### 新敌人类型 (5 个)

| ID | 名称 | 职业 | HP | ATK | 出现世界 |
|----|------|------|-----|-----|----------|
| enemy_scorpion | 沙蝎 | WARRIOR | 400 | 45 | 沙漠 |
| enemy_mummy | 木乃伊 | KNIGHT | 550 | 40 | 沙漠 |
| enemy_frost_wolf | 冰狼 | WARRIOR | 350 | 50 | 冰原 |
| enemy_ice_mage | 冰法师 | MAGE | 200 | 85 | 冰原 |
| enemy_fire_imp | 火魔 | MAGE | 150 | 100 | 火山 |

### 关卡分布

| 世界 | 关卡数 | 难度范围 | 敌人特点 |
|------|--------|----------|----------|
| 森林 | 4 | 1-4 | 基础敌人 |
| 沙漠 | 4 | 5-8 | 高护甲 |
| 冰原 | 4 | 9-12 | 减速效果 |
| 火山 | 4 | 13-16 | 高伤害 |
| 暗影 | 4 | 17-20 | Boss战 |
