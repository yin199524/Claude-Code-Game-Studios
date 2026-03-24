# Godot Engine — Version Reference

| Field | Value |
|-------|-------|
| **Engine Version** | Godot 4.6 |
| **Release Date** | 2026-01-26 |
| **Project Pinned** | 2026-03-23 |
| **Last Docs Verified** | 2026-03-23 |
| **LLM Knowledge Cutoff** | May 2025 |
| **Risk Level** | HIGH |

## Knowledge Gap Warning

The LLM's training data likely covers Godot up to ~4.3. Versions 4.4, 4.5,
and 4.6 introduced significant changes that the model does NOT know about.
**Always cross-reference this directory before suggesting Godot API calls.**

## Post-Cutoff Version Timeline

| Version | Release | Risk Level | Key Theme |
|---------|---------|------------|-----------|
| 4.4 | ~Mid 2025 | MEDIUM | Jolt physics (experimental), Metal backend, ubershaders, typed dictionaries |
| 4.5 | ~Late 2025 | HIGH | AccessKit accessibility, variadic args, @abstract, shader baker, SMAA |
| 4.6 | Jan 2026 | HIGH | Jolt default (3D), glow rework, D3D12 default on Windows, IK framework |

## Major Changes Summary

### Godot 4.6 Highlights
- **Jolt Physics is now default** for new 3D projects (was experimental in 4.4)
- **Glow blends before tonemapping**, Screen is new default mode
- **D3D12 is default on Windows** (more stable than Vulkan on some drivers)
- **Full IK framework restored**: `IKModifier3D`, `TwoBoneIK3D`, `SplineIK3D`, `FABRIK3D`, etc.
- **SSR (Screen Space Reflections) overhauled**
- **New "Modern" editor theme** enabled by default
- **LibGodot** allows embedding engine in custom applications

### Godot 4.5 Highlights
- **Screen reader support via AccessKit** (experimental)
- **Variadic arguments** in GDScript: `func foo(...args: Array)`
- **@abstract annotation** for abstract classes/methods
- **Shader baker**: pre-compile shaders at export, up to 20× faster loading
- **SMAA 1x** antialiasing added
- **visionOS export** support

### Godot 4.4 Highlights
- **Jolt Physics integration** (experimental option)
- **Metal rendering backend** for macOS/iOS (replaces MoltenVK)
- **Ubershaders** to eliminate shader stutter
- **Typed dictionaries** in core and GDScript
- **3D physics interpolation** for smooth visuals
- **Embedded game window** in editor

## Verified Sources

- Official docs: https://docs.godotengine.org/en/stable/
- 4.5→4.6 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.6.html
- 4.4→4.5 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.5.html
- 4.3→4.4 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.4.html
- Changelog: https://github.com/godotengine/godot/blob/master/CHANGELOG.md
- Release notes: https://godotengine.org/releases/4.6/
