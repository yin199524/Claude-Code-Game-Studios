# PROTOTYPE - NOT FOR PRODUCTION
# Question: Is the '布局 → 观战 → 收集奖励' core loop engaging enough?
# Date: 2026-03-24

# Simplified unit visual representation for prototype
extends Node2D
class_name UnitVisual

@onready var sprite: Sprite2D = $Sprite2D
@onready var hp_bar: ProgressBar = $HPBar

var unit_data: Dictionary

func setup(data: Dictionary) -> void:
	unit_data = data
	modulate = data["color"]
	position = Vector2(data["pos"].x * 80 + 40, data["pos"].y * 80 + 40)

func update_visual() -> void:
	if hp_bar:
		hp_bar.value = float(unit_data["hp"]) / float(unit_data["max_hp"]) * 100
	modulate.a = 1.0 if unit_data["alive"] else 0.3
