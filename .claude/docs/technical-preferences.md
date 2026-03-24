# Technical Preferences

<!-- Populated by /setup-engine. Updated as the user makes decisions throughout development. -->
<!-- All agents reference this file for project-specific standards and conventions. -->

## Engine & Language

- **Engine**: Godot 4.6
- **Language**: GDScript (primary)
- **Rendering**: Forward+ (default), Compatibility for mobile/older hardware
- **Physics**: Jolt (3D default in 4.6), Godot Physics 2D

## Naming Conventions (GDScript)

- **Classes**: PascalCase (e.g., `PlayerController`, `EnemyAI`)
- **Variables**: snake_case (e.g., `move_speed`, `health_points`)
- **Functions**: snake_case (e.g., `take_damage()`, `update_position()`)
- **Signals**: snake_case past tense (e.g., `health_changed`, `enemy_died`)
- **Files**: snake_case matching class (e.g., `player_controller.gd`)
- **Scenes**: PascalCase matching root node (e.g., `PlayerController.tscn`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_HEALTH`, `DEFAULT_SPEED`)
- **Enums**: PascalCase for enum name, UPPER_SNAKE_CASE for values

## Performance Budgets

- **Target Framerate**: 60 FPS
- **Frame Budget**: 16.6ms
- **Draw Calls**: [TO BE CONFIGURED — depends on target hardware]
- **Memory Ceiling**: [TO BE CONFIGURED — depends on target platform]

## Testing

- **Framework**: GUT (Godot Unit Testing) or GdUnit4
- **Minimum Coverage**: [TO BE CONFIGURED]
- **Required Tests**: Balance formulas, gameplay systems, networking (if applicable)

## Forbidden Patterns

<!-- Add patterns that should never appear in this project's codebase -->
- [None configured yet — add as architectural decisions are made]

## Allowed Libraries / Addons

<!-- Add approved third-party dependencies here -->
- [None configured yet — add as dependencies are approved]

## Architecture Decisions Log

- [ADR-0001: 游戏架构](docs/architecture/adr-0001-game-architecture.md) — Autoload 单例 + 场景树模式

## Godot 4.6 Specific Notes

> ⚠️ **Knowledge Gap**: The LLM's training data covers Godot up to ~4.3.
> Versions 4.4, 4.5, and 4.6 introduced significant changes.
> Always check `docs/engine-reference/godot/` before suggesting APIs.

### Key 4.6 Changes to Remember

- **Jolt Physics is default** for new 3D projects
- **Glow processes before tonemapping** (different visuals)
- **D3D12 is default on Windows** (was Vulkan)
- **IK framework restored**: Use `IKModifier3D` nodes
- **Variadic args** in GDScript: `func foo(...args: Array)`
- **@abstract** annotation for abstract classes/methods
- **Typed dictionaries**: `var d: Dictionary[String, int]`
