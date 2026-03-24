# test_grid_layout.gd - 网格布局系统单元测试
# 参考: design/gdd/grid-layout-system.md
# 运行: godot --headless --script res://tests/unit/test_grid_layout.gd

extends SceneTree

func _init() -> void:
	print("=== 网格布局系统测试 ===")
	print("")

	# 测试 1: 基础放置
	test_basic_placement()

	# 测试 2: 位置验证
	test_position_validation()

	# 测试 3: 移除单位
	test_remove_unit()

	# 测试 4: 区域检查
	test_area_check()

	# 测试 5: 边界情况
	test_edge_cases()

	# 测试 6: 坐标转换
	test_coordinate_conversion()

	print("")
	print("=== 测试完成 ===")
	quit()


## 测试基础放置
func test_basic_placement() -> void:
	print("测试 1: 基础放置")

	var layout = GridLayout.new()
	var unit = _create_test_unit("warrior", Vector2i(-1, -1))

	# 放置单位
	var success = layout.place_unit(unit, Vector2i(0, 2))
	assert(success, "应该成功放置单位")
	assert(layout.has_unit_at(Vector2i(0, 2)), "位置应该有单位")
	assert(layout.get_unit_count() == 1, "单位数量应为 1")
	print("  ✓ 成功放置单位到 (0, 2)")

	# 同一位置不能再放
	var unit2 = _create_test_unit("archer", Vector2i(-1, -1))
	success = layout.place_unit(unit2, Vector2i(0, 2))
	assert(not success, "同一位置不应能放置第二个单位")
	print("  ✓ 同一位置不能放置第二个单位")

	# 放置第二个单位
	success = layout.place_unit(unit2, Vector2i(1, 2))
	assert(success, "应该成功放置第二个单位")
	assert(layout.get_unit_count() == 2, "单位数量应为 2")
	print("  ✓ 成功放置第二个单位")


## 测试位置验证
func test_position_validation() -> void:
	print("测试 2: 位置验证")

	var layout = GridLayout.new()

	# 有效位置
	assert(layout.is_valid_position(Vector2i(0, 0)), "(0,0) 应该有效")
	assert(layout.is_valid_position(Vector2i(2, 2)), "(2,2) 应该有效")
	print("  ✓ 有效位置检查通过")

	# 无效位置
	assert(not layout.is_valid_position(Vector2i(-1, 0)), "(-1,0) 应该无效")
	assert(not layout.is_valid_position(Vector2i(3, 0)), "(3,0) 应该无效")
	assert(not layout.is_valid_position(Vector2i(0, 3)), "(0,3) 应该无效")
	print("  ✓ 无效位置检查通过")


## 测试移除单位
func test_remove_unit() -> void:
	print("测试 3: 移除单位")

	var layout = GridLayout.new()
	var unit = _create_test_unit("warrior", Vector2i(-1, -1))
	layout.place_unit(unit, Vector2i(1, 2))

	# 移除单位
	var removed = layout.remove_unit(Vector2i(1, 2))
	assert(removed != null, "应该返回被移除的单位")
	assert(removed == unit, "返回的单位应该是同一个")
	assert(not layout.has_unit_at(Vector2i(1, 2)), "位置应该为空")
	print("  ✓ 成功移除单位")

	# 移除空位置
	removed = layout.remove_unit(Vector2i(0, 0))
	assert(removed == null, "空位置应该返回 null")
	print("  ✓ 移除空位置返回 null")


## 测试区域检查
func test_area_check() -> void:
	print("测试 4: 区域检查")

	var layout = GridLayout.new()
	layout.player_area_start = 2
	layout.enemy_area_end = 1

	# 玩家区域
	assert(layout.is_player_area(Vector2i(0, 2)), "(0,2) 应该在玩家区域")
	assert(layout.is_player_area(Vector2i(2, 2)), "(2,2) 应该在玩家区域")
	assert(not layout.is_player_area(Vector2i(0, 0)), "(0,0) 不应在玩家区域")
	print("  ✓ 玩家区域检查通过")

	# 敌人区域
	assert(layout.is_enemy_area(Vector2i(0, 0)), "(0,0) 应该在敌人区域")
	assert(not layout.is_enemy_area(Vector2i(0, 2)), "(0,2) 不应在敌人区域")
	print("  ✓ 敌人区域检查通过")


## 测试边界情况
func test_edge_cases() -> void:
	print("测试 5: 边界情况")

	var layout = GridLayout.new()

	# 空布局
	assert(layout.get_unit_count() == 0, "空布局单位数应为 0")
	assert(layout.get_all_units().size() == 0, "空布局单位列表应为空")
	print("  ✓ 空布局正确")

	# 获取空位置
	var empty = layout.get_empty_positions()
	assert(empty.size() == 9, "空布局应有 9 个空位置")
	print("  ✓ 空位置数量正确")

	# 填满所有位置
	for y in range(3):
		for x in range(3):
			var unit = _create_test_unit("unit_%d_%d" % [x, y], Vector2i(-1, -1))
			layout.place_unit(unit, Vector2i(x, y))

	empty = layout.get_empty_positions()
	assert(empty.size() == 0, "满布局应有 0 个空位置")
	print("  ✓ 满布局正确")

	# 清空
	layout.clear()
	assert(layout.get_unit_count() == 0, "清空后单位数应为 0")
	print("  ✓ 清空正确")


## 测试坐标转换
func test_coordinate_conversion() -> void:
	print("测试 6: 坐标转换")

	var layout = GridLayout.new()
	layout.cell_size = 64
	var origin = Vector2(100, 50)

	# 网格转屏幕
	var screen_pos = layout.grid_to_screen(Vector2i(0, 0), origin)
	assert(screen_pos.x == 132.0, "屏幕坐标 X 应为 132")
	assert(screen_pos.y == 82.0, "屏幕坐标 Y 应为 82")
	print("  ✓ 网格转屏幕坐标正确")

	# 屏幕转网格
	var grid_pos = layout.screen_to_grid(Vector2(132, 82), origin)
	assert(grid_pos == Vector2i(0, 0), "网格坐标应为 (0,0)")
	print("  ✓ 屏幕转网格坐标正确")


## 创建测试单位
func _create_test_unit(id: String, position: Vector2i) -> UnitInstance:
	var def = UnitDefinition.new()
	def.id = id
	def.display_name = id
	def.class_type = Global.ClassType.WARRIOR
	def.rarity = Global.Rarity.COMMON
	def.hp = 100
	def.attack = 20
	def.armor = 0
	def.attack_speed = 1.0
	def.attack_range = 1
	def.move_speed = 1.0
	def.base_price = 50

	var instance = UnitInstance.create(def, position, true)
	return instance


## 简单断言
func assert(condition: bool, message: String) -> void:
	if not condition:
		print("  ✗ 断言失败: " + message)
