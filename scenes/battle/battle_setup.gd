# battle_setup.gd - 布局阶段场景脚本
# 玩家在此放置单位

extends Control

## 格子大小
const CELL_SIZE: int = 100

## 网格原点
var grid_origin: Vector2 = Vector2(0, 0)

## 网格布局
var grid_layout: GridLayout = null

## 当前关卡定义
var current_level: LevelDefinition = null

## 当前选中的单位
var selected_unit_id: String = ""

## 单位节点映射
var unit_nodes: Dictionary = {}

## 已放置单位数量
var placed_count: int = 0


func _ready() -> void:
	_load_level_data()
	_setup_grid_layout()
	_create_unit_buttons()
	_connect_signals()
	_place_enemies()


## 加载关卡数据
func _load_level_data() -> void:
	var level_id = GameManager.current_level_id
	if level_id.is_empty():
		level_id = "level_001"  # 默认第一关

	current_level = LevelDatabase.get_level(level_id)
	if current_level == null:
		print("关卡未找到: %s, 使用默认配置" % level_id)
		current_level = LevelDatabase.get_first_level()


## 设置网格布局
func _setup_grid_layout() -> void:
	grid_layout = GridLayout.new()

	# 使用关卡配置
	if current_level:
		grid_layout.grid_width = current_level.grid_size.x
		grid_layout.grid_height = current_level.grid_size.y
		grid_layout.player_area_start = current_level.player_area_start
		grid_layout.enemy_area_end = current_level.enemy_area_end
	else:
		grid_layout.grid_width = 3
		grid_layout.grid_height = 3
		grid_layout.player_area_start = 2
		grid_layout.enemy_area_end = 1

	grid_layout.cell_size = CELL_SIZE

	grid_layout.unit_placed.connect(_on_unit_placed)
	grid_layout.unit_removed.connect(_on_unit_removed)


## 放置关卡敌人
func _place_enemies() -> void:
	if current_level == null:
		return

	for spawn in current_level.enemy_spawns:
		var unit_def = UnitDatabase.get_unit(spawn.unit_id)
		if unit_def == null:
			continue

		# 创建敌人实例
		var instance = UnitInstance.create(unit_def, spawn.position, false)

		# 应用属性加成
		instance.definition = unit_def.duplicate()
		instance.definition.hp = int(unit_def.hp * spawn.level_modifier)
		instance.definition.attack = int(unit_def.attack * spawn.level_modifier)
		instance.current_hp = instance.get_max_hp()
		instance.definition.display_name = "敌人%s" % unit_def.display_name

		grid_layout.place_unit(instance, spawn.position)


## 创建单位选择按钮
func _create_unit_buttons() -> void:
	var container = $UnitList/Units

	# 清空现有按钮
	for child in container.get_children():
		child.queue_free()

	# 获取玩家拥有的单位
	var owned = SaveManager.get_owned_units()

	for unit_data in owned:
		var unit_id = unit_data.get("unit_id", "")
		var def = UnitDatabase.get_unit(unit_id)
		if def:
			var btn = Button.new()
			btn.text = def.display_name
			btn.custom_minimum_size = Vector2(80, 40)
			btn.pressed.connect(_on_unit_button_pressed.bind(unit_id))
			container.add_child(btn)


## 连接信号
func _connect_signals() -> void:
	$BottomBar/ClearButton.pressed.connect(_on_clear_pressed)
	$BottomBar/StartButton.pressed.connect(_on_start_pressed)


## 绘制网格线
func _draw_grid() -> void:
	pass


func _draw() -> void:
	var grid_container = $GridContainer
	var rect = grid_container.get_rect()

	# 计算网格原点
	grid_origin = Vector2(rect.position.x + 50, rect.position.y + 50)

	var width = grid_layout.grid_width if grid_layout else 3
	var height = grid_layout.grid_height if grid_layout else 3

	# 绘制网格线
	for x in range(width + 1):
		var x_pos = grid_origin.x + x * CELL_SIZE
		draw_line(Vector2(x_pos, grid_origin.y), Vector2(x_pos, grid_origin.y + height * CELL_SIZE), Color.WHITE, 1)

	for y in range(height + 1):
		var y_pos = grid_origin.y + y * CELL_SIZE
		draw_line(Vector2(grid_origin.x, y_pos), Vector2(grid_origin.x + width * CELL_SIZE, y_pos), Color.WHITE, 1)


## 单位按钮按下
func _on_unit_button_pressed(unit_id: String) -> void:
	# 检查单位上限
	var limit = current_level.player_unit_limit if current_level else 5
	if placed_count >= limit:
		print("已达到单位上限: %d" % limit)
		return

	selected_unit_id = unit_id
	print("选中单位: %s" % unit_id)


## 网格点击
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_handle_grid_click(event.position)


## 处理网格点击
func _handle_grid_click(screen_pos: Vector2) -> void:
	var grid_pos = _screen_to_grid(screen_pos)

	if not grid_layout.is_valid_position(grid_pos):
		return

	# 如果有选中的单位，尝试放置
	if not selected_unit_id.is_empty():
		_place_selected_unit(grid_pos)
		selected_unit_id = ""
		return

	# 如果点击了已有单位，可以移除
	if grid_layout.has_unit_at(grid_pos):
		var unit = grid_layout.get_unit_at(grid_pos)
		if unit.is_player_unit:
			grid_layout.remove_unit(grid_pos)
			placed_count -= 1


## 放置选中的单位
func _place_selected_unit(grid_pos: Vector2i) -> void:
	# 检查是否在玩家区域
	if not grid_layout.is_player_area(grid_pos):
		print("只能放置在玩家区域")
		return

	# 检查位置是否已有单位
	if grid_layout.has_unit_at(grid_pos):
		print("该位置已有单位")
		return

	# 创建单位实例
	var def = UnitDatabase.get_unit(selected_unit_id)
	if def:
		var instance = UnitInstance.create(def, grid_pos, true)
		grid_layout.place_unit(instance, grid_pos)
		placed_count += 1


## 单位放置回调
func _on_unit_placed(unit: UnitInstance, position: Vector2i) -> void:
	_create_unit_node(unit)


## 单位移除回调
func _on_unit_removed(unit: UnitInstance, position: Vector2i) -> void:
	_remove_unit_node(unit)


## 创建单位节点
func _create_unit_node(unit: UnitInstance) -> void:
	var node = _create_unit_visual(unit)
	$GridContainer/UnitsContainer.add_child(node)
	unit_nodes[unit] = node


## 移除单位节点
func _remove_unit_node(unit: UnitInstance) -> void:
	if unit_nodes.has(unit):
		var node = unit_nodes[unit]
		node.queue_free()
		unit_nodes.erase(unit)


## 创建单位视觉节点
func _create_unit_visual(unit: UnitInstance) -> Node2D:
	var node = Node2D.new()
	node.position = grid_layout.grid_to_screen(unit.grid_position, grid_origin)

	var sprite = ColorRect.new()
	sprite.size = Vector2(80, 80)
	sprite.position = Vector2(-40, -40)
	sprite.color = _get_unit_color(unit)

	var name_label = Label.new()
	name_label.text = unit.definition.display_name
	name_label.position = Vector2(-30, 40)
	name_label.add_theme_font_size_override("font_size", 12)

	node.add_child(sprite)
	node.add_child(name_label)

	return node


## 获取单位颜色
func _get_unit_color(unit: UnitInstance) -> Color:
	if not unit.is_player_unit:
		return Color(0.8, 0.2, 0.2)

	match unit.get_class_type():
		Global.ClassType.WARRIOR:
			return Color(0.2, 0.6, 0.2)
		Global.ClassType.ARCHER:
			return Color(0.2, 0.4, 0.8)
		Global.ClassType.MAGE:
			return Color(0.6, 0.2, 0.8)
		Global.ClassType.KNIGHT:
			return Color(0.8, 0.6, 0.2)
		Global.ClassType.HEALER:
			return Color(0.2, 0.8, 0.8)

	return Color(0.5, 0.5, 0.5)


## 清空按钮
func _on_clear_pressed() -> void:
	grid_layout.clear_player_units()
	placed_count = 0


## 开始战斗按钮
func _on_start_pressed() -> void:
	# 检查是否至少有一个玩家单位
	if grid_layout.get_player_unit_count() == 0:
		print("请至少放置一个单位")
		return

	# 保存布局到全局（用于战斗场景）
	_store_layout_for_battle()

	# 切换到战斗场景
	get_tree().change_scene_to_file("res://scenes/battle/battle_scene.tscn")


## 保存布局供战斗使用
func _store_layout_for_battle() -> void:
	# 使用 GameManager 的自定义数据存储
	if not GameManager.has_meta("battle_layout"):
		GameManager.set_meta("battle_layout", grid_layout.duplicate_layout())
	else:
		GameManager.set_meta("battle_layout", grid_layout.duplicate_layout())


## 屏幕坐标转网格坐标
func _screen_to_grid(screen_pos: Vector2) -> Vector2i:
	var local_pos = screen_pos - grid_origin
	return Vector2i(
		int(local_pos.x / CELL_SIZE),
		int(local_pos.y / CELL_SIZE)
	)
