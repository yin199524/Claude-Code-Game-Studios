# Game Concept: 禅意军团 (Zen Legion)

*Created: 2026-03-23*
*Status: Draft*

---

## Elevator Pitch

> 一款放置自动战斗游戏，你布置军团然后观看战斗自动展开——像照料花园一样培育你的军团布局，在像素风格的奇幻世界中收集和升级独特的职业单位。
>
> "像《皇室战争》，但你不需要紧张操作——你只需智慧地布局，然后享受战斗的花开。"

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Auto-battler + Strategy + Collection |
| **Platform** | Mobile (primary), PC (possible later) |
| **Target Audience** | Achievers, Competitors |
| **Player Count** | Single-player (PVP for later version) |
| **Session Length** | 5-15 minutes |
| **Monetization** | F2P with Shop/Gacha (to be decided) |
| **Estimated Scope** | Medium (3-9 months recommended, user targets a few weeks) |
| **Comparable Titles** | Clash Royale, Teamfight Tactics (mobile), Auto Chess |

---

## Core Fantasy

成为一位智慧的军团指挥官——你不需要亲自挥剑，你只需要精心布局。

你的单位会在战场上自动战斗，展现你战略眼光的成果。你像照料一座花园一样培育你的军团：每个单位都有独特的个性和能力，收集它们、升级它们、找到完美的组合，看着你的战略在战场上开花结果。

这是一种权力的幻想，也是一种创造的满足——你不是战士，你是军团的建筑师。

---

## Unique Hook

**「Auto-battler AND ALSO 禅意花园」**

像《云顶之弈》或《皇室战争》，但你不需要紧张操作或快速反应。

战斗自动进行，你的乐趣来自：
1. **布局的策略深度** — 单位位置、组合、克制关系
2. **收集的满足感** — 每个单位都是独特的宝藏
3. **观赛的放松体验** — 看着你的布局自动展开成一场战斗

**为什么这特别**：大多数策略游戏要求紧张操作，而禅意军团让你在轻松的状态下享受策略的乐趣。

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Fantasy** (make-believe, role-playing) | 1 | 扮演智慧的军团指挥官，拥有并培养自己的军队 |
| **Challenge** (obstacle course, mastery) | 2 | 布局策略有深度，关卡难度递进 |
| **Submission** (relaxation, comfort zone) | 3 | 战斗自动进行，无需紧张操作，观赛即是享受 |
| **Discovery** (exploration, secrets) | 4 | 发现单位组合的协同效果 |
| **Sensation** (sensory pleasure) | Supporting | 像素风格动画，打击反馈音效 |
| **Expression** (self-expression, creativity) | Supporting | 不同布局风格，培养偏好的单位 |
| **Narrative** (drama, story arc) | N/A | 反支柱：故事仅作背景装饰 |
| **Fellowship** (social connection) | Future | PVP系统后期加入 |

### Key Dynamics (Emergent player behaviors)

- **实验组合**：玩家会尝试不同的单位组合，寻找协同效应
- **分享布局**：玩家会分享他们的获胜布局（为PVP社交做准备）
- **追逐稀有**：玩家会为了稀有的传说单位持续投入
- **优化微调**：玩家会因为一场失败而微调一个单位的位置

### Core Mechanics (Systems we build)

1. **网格布局系统** — 3x3 或 4x4 网格，单位位置影响战斗效果
2. **自动战斗系统** — 回合制或实时战斗，单位按AI逻辑行动
3. **单位收集系统** — 商店购买 + 抽卡获取，稀有度分级
4. **永久进度系统** — 单位升级、关卡解锁、资源积累

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** (freedom, meaningful choice) | 布局决策完全由玩家掌控，每个位置都是选择 | Core |
| **Competence** (mastery, skill growth) | 战斗结果是策略的直接反馈，胜利证明能力 | Core |
| **Relatedness** (connection, belonging) | PVP排行榜和分享功能（后期） | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** (goal completion, collection, progression) — How: 收集所有单位、完成所有关卡、升级到最高等级
- [ ] **Explorers** (discovery, understanding systems, hidden secrets) — How: 发现单位协同效应
- [ ] **Socializers** (relationships, cooperation, community) — How: PVP和分享布局（后期）
- [x] **Competitors** (domination, PvP, leaderboards) — How: PVP竞技场和排行榜（后期）

### Flow State Design

- **Onboarding curve**: 第一个关卡只有1-2个单位，教会玩家基本操作；第二关引入更多单位；第三关引入克制概念
- **Difficulty scaling**: 关卡难度逐步提升，解锁新单位帮助玩家应对更高难度
- **Feedback clarity**: 战斗结果清晰（胜利/失败），伤害数字显示，单位死亡动画
- **Recovery from failure**: 失败后可以立即重试，调整布局；永久进度不会丢失

---

## Core Loop

### Moment-to-Moment (30 seconds)

- 玩家观看战斗自动展开
- 单位攻击、受击、死亡都有清晰的动画和音效
- 战斗结束，显示结算界面和获得的奖励
- 点击领取奖励 → 多巴胺满足

**为什么这是满足的**：观赛本身是放松的，同时看到自己布局的成果带来满足感。

### Short-Term (5-15 minutes)

- 选择关卡 → 布置军团 → 开始战斗 → 获得资源
- 使用资源在商店购买新单位或升级现有单位
- 尝试新的布局组合
- 「再来一局」的冲动来自：解锁下一个关卡、试试新单位、优化布局

### Session-Level (30-60 minutes)

- 完成多个关卡，推进地图
- 在商店购买1-2个新单位
- 尝试新单位的组合
- 可能遇到卡住的关卡，思考布局调整

### Long-Term Progression

- **短期目标**：通过当前关卡
- **中期目标**：收集特定稀有单位、解锁新地图区域
- **长期目标**：收集所有单位、挑战最高难度关卡、PVP排行榜高位

### Retention Hooks

- **Curiosity**: 还有什么稀有单位？下一个地图区域长什么样？
- **Investment**: 已投入的资源、已培养的单位、已解锁的进度
- **Social**: PVP排行榜竞争、分享获胜布局（后期）
- **Mastery**: 更高效的布局、挑战高难度关卡

---

## Game Pillars

### Pillar 1: 策略深度

「布局即游戏」—— 军团布置是游戏的核心乐趣，不同单位组合和位置带来截然不同的战斗结果。

*Design test*: 如果我们要在「添加新单位」和「深化布局机制（如地形效果）」之间选择，这个支柱说我们选择**布局机制**。

### Pillar 2: 收集满足

「每个单位都是宝藏」—— 单位有独特的设计、个性、稀有度，收集和升级带来持续的成就感。

*Design test*: 如果我们要在「增加更多关卡」和「让每个单位更独特（独特动画、技能、故事片段）」之间选择，这个支柱说我们选择**单位独特性**。

### Anti-Pillars (What This Game Is NOT)

- **NOT 叙事驱动**: 这款游戏不是靠剧情推动的。故事是为世界提供风味背景，不是让玩家追着看的。我们不会投入大量资源在对话、过场动画、角色剧情上。*为什么*：这会分散开发时间，且不是玩家的核心动机。

- **NOT 紧张操作**: 这款游戏不需要快速反应或精确操作。如果某个设计要求玩家在短时间内做出多个决策，那就是违反了这个反支柱。*为什么*：这与「禅意/放松」的核心体验冲突。

- **NOT 硬核难度**: 这款游戏不会有硬核的惩罚机制（如单位永久死亡、失败丢失大量进度）。*为什么*：这会破坏放松体验。

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| **Clash Royale** | 卡牌收集、单位布置概念 | 战斗自动进行，无需实时操作 | 验证了收集+策略的组合吸引力 |
| **Teamfight Tactics** | Auto-battler核心玩法 | 简化复杂度，移动端友好 | 验证了自动战斗的策略深度 |
| **猫咪大战 (Battle Cats)** | 放置+收集+关卡推进 | 更强调布局策略，更多单位个性 | 验证了移动端放置+收集的市场 |
| **Stardew Valley** | 像素风格、放松氛围 | 战斗主题而非农场 | 像素风格可行性验证 |

**Non-game inspirations**: 盆栽园艺（培育和观察的乐趣）、宠物养成（收集和培养的情感连接）

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 18-35 |
| **Gaming experience** | Casual to Mid-core |
| **Time availability** | 碎片时间，5-15分钟一局 |
| **Platform preference** | Mobile (通勤、休息时间) |
| **Current games they play** | Clash Royale, Teamfight Tactics, 猫咪大战 |
| **What they're looking for** | 策略乐趣但没有操作压力，收集的长期目标 |
| **What would turn them away** | 过于复杂的系统、需要投入大量时间才能有进展、强制社交 |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | Godot 4 (project already configured) — 2D友好，移动端导出简单，像素游戏常用 |
| **Key Technical Challenges** | 自动战斗AI、单位协同效果、PVP同步（后期） |
| **Art Style** | 2D Pixel Art |
| **Art Pipeline Complexity** | Medium (custom pixel art, manageable for solo dev) |
| **Audio Needs** | Moderate (BGM + combat SFX + UI sounds) |
| **Networking** | PVP需要简单的匹配系统（后期） |
| **Content Volume** | MVP: 5-10 units, 5-10 levels; Full: 30+ units, 50+ levels |
| **Procedural Systems** | None initially; consider procedural level generation for endless mode |

---

## Risks and Open Questions

### Design Risks

- **核心循环可能不够吸引**：观赛可能很快变得无聊，需要足够的视觉反馈和策略深度
- **收集动机可能不足**：如果单位差异不够大，收集动机会下降
- **PVP平衡难度**：不同稀有度单位之间的平衡是长期挑战

### Technical Risks

- **自动战斗AI复杂度**：单位行为逻辑需要足够智能但可预测
- **PVP实现复杂度**：对于「几周」的时间线，PVP是显著的技术挑战

### Market Risks

- **竞争激烈**：Auto-battler类型已有成熟竞品
- **移动端用户获取成本高**：需要有效的营销策略

### Scope Risks

- **范围过大**：用户期望「几周」完成，但设计包含：网格战斗、关卡系统、商店+抽卡、多资源、单位收集升级、PVP+排行榜
- **第一个游戏**：作为第一个游戏，多个系统的学习曲线可能比预期更长

### Open Questions

- **抽卡机制是否必须？** 简化为直接购买可能更适合初版 — 通过原型验证
- **关卡如何设计？** 手工设计 vs 程序生成 — 先手工设计5关作为MVP
- **单位稀有度如何影响战斗？** 稀有单位是否更强，还是只是更独特？— 通过原型验证平衡

---

## MVP Definition

**Core hypothesis**: 玩家会觉得「布局 → 观看战斗 → 收集奖励」的循环足够有趣，愿意持续进行多次。

**Required for MVP**:
1. 3x3 网格布局系统（拖拽放置单位）
2. 自动战斗系统（单位按简单AI行动）
3. 5个基础单位（战士、弓手、法师、骑士、治疗）
4. 3个关卡（难度递进）
5. 简单资源系统（金币，战斗获得，用于购买）
6. 基础商店（直接购买单位，无抽卡）

**Explicitly NOT in MVP** (defer to later):
- 抽卡系统（先验证核心循环）
- PVP/排行榜（先验证单人体验）
- 单位升级系统（先验证收集动机）
- 多资源类型（先只用金币）
- 关卡地图系统（先用简单关卡列表）

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 5 units, 3 levels | Core loop only | 1-2 weeks |
| **Vertical Slice** | 10 units, 10 levels | Core + shop + progression | 3-4 weeks |
| **Alpha** | 20 units, 30 levels | All features (no PVP) | 2-3 months |
| **Full Vision** | 30+ units, 50+ levels | All features + PVP | 3-6 months |

---

## Next Steps

- [ ] Get concept approval from creative-director
- [ ] Fill in CLAUDE.md technology stack based on engine choice (`/setup-engine`)
- [ ] Create game pillars document (`/design-review` to validate)
- [ ] Decompose concept into systems (`/map-systems` — maps dependencies, assigns priorities, guides per-system GDD writing)
- [ ] Create first architecture decision record (`/architecture-decision`)
- [ ] Prototype core loop (`/prototype grid-battle`)
- [ ] Validate core loop with playtest (`/playtest-report`)
- [ ] Plan first milestone (`/sprint-plan new`)
