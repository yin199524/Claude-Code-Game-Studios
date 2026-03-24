# Prototype: Auto-Battle System

## Quick Start

```bash
# In Godot editor:
# 1. Open prototypes/auto-battle/prototype.tscn
# 2. Run the scene (F6)

# Or via command line (headless test):
godot --headless --script res://prototypes/auto-battle/test_battle.gd
```

## What This Tests

**Core Question**: Is the '布局 → 观战 → 收集奖励' core loop engaging enough?

## Prototype Scope

| Feature | Included |
|---------|----------|
| 3x3 Grid | ✅ |
| Unit placement | ✅ (hardcoded) |
| Turn-based combat | ✅ |
| Target selection (nearest) | ✅ |
| Damage calculation | ✅ (simplified) |
| Movement | ✅ |
| Victory/defeat | ✅ |
| UI | ❌ |
| Shop | ❌ |
| Save/Load | ❌ |
| Animations | ❌ |

## Test Configuration

- **Player**: 3 units (warrior, archer, mage)
- **Enemy**: 3 units (2 warriors, 1 archer)
- **Turn Duration**: 0.5 seconds

## Key Metrics to Observe

1. **Battle Length**: How many turns until victory/defeat?
2. **Win Rate**: Can the player win with default setup?
3. **Engagement**: Is watching the battle interesting?

## Files

```
prototypes/auto-battle/
├── README.md          # This file
├── prototype.tscn     # Main scene
├── battle_manager.gd  # Core battle logic
├── unit.gd            # Unit visual (minimal)
└── test_battle.gd     # Headless test script
```

## Expected Results

- Player should win ~60-70% of battles with default setup
- Battles should complete in 5-15 turns
- Different unit types should show distinct behaviors

## How to Modify

1. **Change unit stats**: Edit `UNIT_TYPES` in `battle_manager.gd`
2. **Change unit placement**: Edit `_setup_test_units()` in `battle_manager.gd`
3. **Change turn speed**: Edit `TURN_DURATION` in `battle_manager.gd`
