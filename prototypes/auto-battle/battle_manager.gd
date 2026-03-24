# PROTOTYPE - NOT FOR PRODUCTION
# Question: Is the '布局 → 观战 → 收集奖励' core loop engaging enough?
# Date: 2026-03-24

class_name BattleManager
extends Node

# === PROTOTYPE CONFIG (hardcoded for testing) ===
const GRID_SIZE := 3
const CELL_SIZE := 80
const TURN_DURATION := 0.5  # seconds between turns

# Unit definitions (simplified)
const UNIT_TYPES := {
	"warrior": {"hp": 100, "attack": 15, "range": 1, "speed": 1.0, "color": Color.RED},
	"archer": {"hp": 60, "attack": 20, "range": 2, "speed": 1.5, "color": Color.GREEN},
	"mage": {"hp": 50, "attack": 30, "range": 2, "speed": 0.8, "color": Color.BLUE},
}

# === STATE ===
enum State { SETUP, FIGHTING, VICTORY, DEFEAT }

var current_state := State.SETUP
var turn := 0
var player_units: Array[Dictionary] = []
var enemy_units: Array[Dictionary] = []
var grid: Array = []  # 3x3 grid, each cell can hold a unit

signal state_changed(new_state: State)
signal turn_completed(turn_num: int)
signal damage_dealt(attacker: Dictionary, target: Dictionary, damage: int)
signal unit_died(unit: Dictionary)

func _ready() -> void:
	_init_grid()
	_setup_test_units()

func _init_grid() -> void:
	grid = []
	for i in range(GRID_SIZE):
		var row = []
		for j in range(GRID_SIZE):
			row.append(null)
		grid.append(row)

func _setup_test_units() -> void:
	# Place 3 player units in bottom row
	player_units = [
		_create_unit("warrior", Vector2i(0, 2), true),
		_create_unit("archer", Vector2i(1, 2), true),
		_create_unit("mage", Vector2i(2, 2), true),
	]

	# Place 3 enemies in top row
	enemy_units = [
		_create_unit("warrior", Vector2i(0, 0), false),
		_create_unit("archer", Vector2i(1, 0), false),
		_create_unit("warrior", Vector2i(2, 0), false),
	]

func _create_unit(type_id: String, pos: Vector2i, is_player: bool) -> Dictionary:
	var type_data = UNIT_TYPES[type_id]
	var unit = {
		"type": type_id,
		"pos": pos,
		"is_player": is_player,
		"hp": type_data["hp"],
		"max_hp": type_data["hp"],
		"attack": type_data["attack"],
		"range": type_data["range"],
		"speed": type_data["speed"],
		"color": type_data["color"],
		"alive": true,
	}
	grid[pos.y][pos.x] = unit
	return unit

# === PUBLIC API ===

func start_battle() -> void:
	if current_state != State.SETUP:
		return
	current_state = State.FIGHTING
	state_changed.emit(current_state)
	_run_battle()

func _run_battle() -> void:
	while current_state == State.FIGHTING:
		turn += 1
		_execute_turn()
		_check_battle_end()

		# In real game, this would be animated
		await get_tree().create_timer(TURN_DURATION).timeout

func _execute_turn() -> void:
	# Get all alive units, sorted by speed (descending)
	var all_units = []
	for u in player_units:
		if u["alive"]:
			all_units.append(u)
	for u in enemy_units:
		if u["alive"]:
			all_units.append(u)

	all_units.sort_custom(func(a, b): return a["speed"] > b["speed"])

	# Each unit takes action
	for unit in all_units:
		if not unit["alive"]:
			continue
		_execute_unit_action(unit)

	turn_completed.emit(turn)

func _execute_unit_action(unit: Dictionary) -> void:
	# Find target (nearest enemy)
	var targets = unit["is_player"] and enemy_units or player_units
	var nearest: Dictionary = {}
	var nearest_dist := 999

	for t in targets:
		if not t["alive"]:
			continue
		var dist = _manhattan_distance(unit["pos"], t["pos"])
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = t

	if nearest.is_empty():
		return

	# Check if in range
	if nearest_dist <= unit["range"]:
		# Attack!
		var damage = unit["attack"]
		nearest["hp"] -= damage
		damage_dealt.emit(unit, nearest, damage)

		if nearest["hp"] <= 0:
			nearest["alive"] = false
			nearest["hp"] = 0
			grid[nearest["pos"].y][nearest["pos"].x] = null
			unit_died.emit(nearest)
	else:
		# Move toward target (simplified - move 1 cell)
		var dir = Vector2i(
			sign(nearest["pos"].x - unit["pos"].x),
			sign(nearest["pos"].y - unit["pos"].y)
		)
		var new_pos = unit["pos"] + dir
		if _is_valid_pos(new_pos) and grid[new_pos.y][new_pos.x] == null:
			grid[unit["pos"].y][unit["pos"].x] = null
			unit["pos"] = new_pos
			grid[new_pos.y][new_pos.x] = unit

func _manhattan_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)

func _is_valid_pos(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE

func _check_battle_end() -> void:
	var player_alive = player_units.any(func(u): return u["alive"])
	var enemy_alive = enemy_units.any(func(u): return u["alive"])

	if not enemy_alive:
		current_state = State.VICTORY
		state_changed.emit(current_state)
	elif not player_alive:
		current_state = State.DEFEAT
		state_changed.emit(current_state)

func get_result() -> Dictionary:
	return {
		"state": current_state,
		"turns": turn,
		"player_survivors": player_units.filter(func(u): return u["alive"]).size(),
	}
