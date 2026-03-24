# GridLayout.gd - 网格布局数据
# 管理单位在网格上的位置
# 参考: design/gdd/grid-layout-system.md

class_name GridLayout
extends Resource

## 网格宽度（格子数）
@export var grid_width: int = 3

## 网格高度（格子数）
@export var grid_height: int = 3

## 格子大小（像素，用于 UI）
@export var cell_size: int = 64

## 玩家区域起始行（包含）
@export var player_area_start: int = 2

## 敌人区域结束行（不包含）
@export var enemy_area_end: int = 1

## 单位位置映射 {Vector2i: UnitInstance}
var _units: Dictionary = {}

## 布局变化信号
signal unit_placed(unit: UnitInstance, position: Vector2i)
signal unit_removed(unit: UnitInstance, position: Vector2i)
signal unit_moved(unit: UnitInstance, old_pos: Vector2i, new_pos: Vector2i)


## 放置单位到指定位置
## unit: 要放置的单位实例
## position: 目标位置
## 返回: 是否成功放置
func place_unit(unit: UnitInstance, position: Vector2i) -> bool:
	# 检查位置有效性
	if not is_valid_position(position):
		return false

	# 检查位置是否已被占用
	if has_unit_at(position):
		return false

	# 检查单位是否已在网格上（移动操作）
	var old_pos = find_unit_position(unit)
	if old_pos != null:
		# 这是一个移动操作
		_units.erase(old_pos)

	# 放置单位
	_units[position] = unit
	unit.grid_position = position

	if old_pos != null:
		unit_moved.emit(unit, old_pos, position)
	else:
		unit_placed.emit(unit, position)

	return true


## 移除指定位置的单位
## position: 要移除的位置
## 返回: 被移除的单位，如果该位置没有单位则返回 null
func remove_unit(position: Vector2i) -> UnitInstance:
	if not has_unit_at(position):
		return null

	var unit = _units[position]
	_units.erase(position)
	unit.grid_position = Vector2i(-1, -1)
	unit_removed.emit(unit, position)

	return unit


## 移除指定单位
## unit: 要移除的单位
## 返回: 是否成功移除
func remove_unit_instance(unit: UnitInstance) -> bool:
	var pos = find_unit_position(unit)
	if pos == null:
		return false

	remove_unit(pos)
	return true


## 获取指定位置的单位
func get_unit_at(position: Vector2i) -> UnitInstance:
	if _units.has(position):
		return _units[position]
	return null


## 检查指定位置是否有单位
func has_unit_at(position: Vector2i) -> bool:
	return _units.has(position) and _units[position] != null


## 查找单位的位置
## unit: 要查找的单位
## 返回: 单位位置，如果未找到则返回 null
func find_unit_position(unit: UnitInstance) -> Variant:
	for pos in _units.keys():
		if _units[pos] == unit:
			return pos
	return null


## 检查位置是否有效（在网格范围内）
func is_valid_position(position: Vector2i) -> bool:
	return position.x >= 0 and position.x < grid_width and position.y >= 0 and position.y < grid_height


## 检查位置是否在玩家区域
func is_player_area(position: Vector2i) -> bool:
	return position.y >= player_area_start


## 检查位置是否在敌人区域
func is_enemy_area(position: Vector2i) -> bool:
	return position.y < enemy_area_end


## 检查玩家是否可以在该位置放置单位
func can_place_player_unit(position: Vector2i) -> bool:
	return is_valid_position(position) and is_player_area(position) and not has_unit_at(position)


## 获取所有单位列表
func get_all_units() -> Array[UnitInstance]:
	var units: Array[UnitInstance] = []
	for unit in _units.values():
		units.append(unit)
	return units


## 获取玩家单位列表
func get_player_units() -> Array[UnitInstance]:
	var units: Array[UnitInstance] = []
	for unit in _units.values():
		if unit.is_player_unit:
			units.append(unit)
	return units


## 获取敌方单位列表
func get_enemy_units() -> Array[UnitInstance]:
	var units: Array[UnitInstance] = []
	for unit in _units.values():
		if not unit.is_player_unit:
			units.append(unit)
	return units


## 获取单位总数
func get_unit_count() -> int:
	return _units.size()


## 获取玩家单位数量
func get_player_unit_count() -> int:
	return get_player_units().size()


## 获取敌方单位数量
func get_enemy_unit_count() -> int:
	return get_enemy_units().size()


## 清空所有单位
func clear() -> void:
	var positions = _units.keys()
	for pos in positions:
		remove_unit(pos)


## 清空玩家单位
func clear_player_units() -> void:
	var player_units = get_player_units()
	for unit in player_units:
		remove_unit_instance(unit)


## 网格坐标转屏幕坐标
func grid_to_screen(position: Vector2i, origin: Vector2 = Vector2.ZERO) -> Vector2:
	return Vector2(
		origin.x + position.x * cell_size + cell_size / 2.0,
		origin.y + position.y * cell_size + cell_size / 2.0
	)


## 屏幕坐标转网格坐标
func screen_to_grid(screen_pos: Vector2, origin: Vector2 = Vector2.ZERO) -> Vector2i:
	return Vector2i(
		int((screen_pos.x - origin.x) / cell_size),
		int((screen_pos.y - origin.y) / cell_size)
	)


## 获取所有空位置
func get_empty_positions() -> Array[Vector2i]:
	var empty: Array[Vector2i] = []
	for y in range(grid_height):
		for x in range(grid_width):
			var pos = Vector2i(x, y)
			if not has_unit_at(pos):
				empty.append(pos)
	return empty


## 获取玩家区域的空位置
func get_empty_player_positions() -> Array[Vector2i]:
	var empty: Array[Vector2i] = []
	for y in range(player_area_start, grid_height):
		for x in range(grid_width):
			var pos = Vector2i(x, y)
			if not has_unit_at(pos):
				empty.append(pos)
	return empty


## 获取敌人区域的空位置
func get_empty_enemy_positions() -> Array[Vector2i]:
	var empty: Array[Vector2i] = []
	for y in range(0, enemy_area_end):
		for x in range(grid_width):
			var pos = Vector2i(x, y)
			if not has_unit_at(pos):
				empty.append(pos)
	return empty


## 复制布局
func duplicate_layout() -> GridLayout:
	var new_layout = GridLayout.new()
	new_layout.grid_width = grid_width
	new_layout.grid_height = grid_height
	new_layout.cell_size = cell_size
	new_layout.player_area_start = player_area_start
	new_layout.enemy_area_end = enemy_area_end

	# 复制单位引用（不创建新实例）
	for pos in _units.keys():
		new_layout._units[pos] = _units[pos]

	return new_layout


## 获取布局信息字符串（用于调试）
func get_info_string() -> String:
	return "GridLayout: %d units (%d player, %d enemy)" % [
		get_unit_count(),
		get_player_unit_count(),
		get_enemy_unit_count()
	]
