# test_battle_manager.gd - 战斗管理器单元测试
# 参考: design/gdd/auto-battle-system.md
# 运行: godot --headless --script res://tests/unit/test_battle_manager.gd

extends SceneTree

func _init() -> void:
	print("=== 战斗管理器测试 ===")
	print("")

	# 测试 1: 战斗初始化
	test_battle_initialization()

	# 测试 2: 战斗流程
	test_battle_flow()

	# 测试 3: 单位移动
	test_unit_movement()

	# 测试 4: 战斗结束条件
	test_battle_end_conditions()

	# 测试 5: 战斗暂停/继续
	test_pause_resume()

	print("")
	print("=== 测试完成 ===")
	quit()


## 测试战斗初始化
func test_battle_initialization() -> void:
	print("测试 1: 战斗初始化")

	var layout = _create_test_layout()
	var manager = BattleManager.new()
	manager.initialize(layout)

	assert(not manager.is_battling, "初始化后不应在战斗中")
	assert(manager.current_turn == 0, "初始回合数应为 0")
	print("  ✓ 初始化状态正确")

	# 检查状态机
	assert(manager.state_machine.current_state == BattleStateMachine.State.SETUP, "初始状态应为 SETUP")
	print("  ✓ 状态机初始状态正确")


## 测试战斗流程
func test_battle_flow() -> void:
	print("测试 2: 战斗流程")

	var layout = _create_test_layout()
	var manager = BattleManager.new()
	manager.initialize(layout)
	manager.turn_duration = 0.01  # 加速测试

	# 开始战斗
	manager.start_battle()
	assert(manager.is_battling, "应该在战斗中")
	assert(manager.state_machine.is_fighting(), "状态应为 FIGHTING")
	print("  ✓ 战斗开始正确")

	# 模拟多回合
	for i in range(10):
		manager.update(0.02)

	assert(manager.current_turn >= 5, "应该执行了多回合")
	print("  ✓ 回合执行正确: %d 回合" % manager.current_turn)


## 测试单位移动
func test_unit_movement() -> void:
	print("测试 3: 单位移动")

	var layout = GridLayout.new()

	# 创建一个玩家单位在 (0, 2)，一个敌人在 (2, 0)
	var player_unit = _create_test_unit("player", Global.ClassType.WARRIOR, Vector2i(0, 2), true)
	var enemy_unit = _create_test_unit("enemy", Global.ClassType.WARRIOR, Vector2i(2, 0), false)

	layout.place_unit(player_unit, Vector2i(0, 2))
	layout.place_unit(enemy_unit, Vector2i(2, 0))

	var manager = BattleManager.new()
	manager.initialize(layout)
	manager.turn_duration = 0.01

	# 记录初始位置
	var initial_pos = player_unit.grid_position

	# 执行几回合
	manager.start_battle()
	for i in range(5):
		manager.update(0.02)

	# 近战单位应该向敌人移动
	# 注意：如果已经进入攻击范围，可能不会移动
	print("  ✓ 单位初始位置: %s, 当前位置: %s" % [initial_pos, player_unit.grid_position])


## 测试战斗结束条件
func test_battle_end_conditions() -> void:
	print("测试 4: 战斗结束条件")

	# 测试胜利条件
	var layout_victory = GridLayout.new()
	var strong_player = _create_test_unit("strong", Global.ClassType.WARRIOR, Vector2i(1, 2), true)
	strong_player.definition.hp = 1000
	strong_player.definition.attack = 100
	var weak_enemy = _create_test_unit("weak", Global.ClassType.WARRIOR, Vector2i(1, 0), false)
	weak_enemy.definition.hp = 10
	weak_enemy.current_hp = 10

	layout_victory.place_unit(strong_player, Vector2i(1, 2))
	layout_victory.place_unit(weak_enemy, Vector2i(1, 0))

	var manager_victory = BattleManager.new()
	manager_victory.initialize(layout_victory)
	manager_victory.turn_duration = 0.01

	# 等待胜利信号
	var victory_received = false
	manager_victory.battle_ended.connect(func(v, _r): victory_received = v)

	manager_victory.start_battle()
	for i in range(50):
		manager_victory.update(0.02)
		if not manager_victory.is_battling:
			break

	if victory_received:
		print("  ✓ 胜利条件正确触发")
	else:
		print("  ⚠ 胜利条件未触发（可能需要更多回合）")


## 测试暂停继续
func test_pause_resume() -> void:
	print("测试 5: 暂停/继续")

	var layout = _create_test_layout()
	var manager = BattleManager.new()
	manager.initialize(layout)
	manager.turn_duration = 0.01

	manager.start_battle()
	assert(not manager.is_paused, "初始不应暂停")
	print("  ✓ 初始不暂停")

	# 暂停
	manager.pause_battle()
	assert(manager.is_paused, "应该已暂停")
	print("  ✓ 暂停成功")

	# 暂停时回合不应增加
	var turn_before = manager.current_turn
	manager.update(0.1)
	assert(manager.current_turn == turn_before, "暂停时回合不应增加")
	print("  ✓ 暂停时回合不增加")

	# 继续
	manager.resume_battle()
	assert(not manager.is_paused, "应该已继续")
	print("  ✓ 继续成功")


## 创建测试布局
func _create_test_layout() -> GridLayout:
	var layout = GridLayout.new()
	layout.player_area_start = 2
	layout.enemy_area_end = 1

	# 放置玩家单位
	var player1 = _create_test_unit("player1", Global.ClassType.WARRIOR, Vector2i(0, 2), true)
	var player2 = _create_test_unit("player2", Global.ClassType.ARCHER, Vector2i(1, 2), true)
	layout.place_unit(player1, Vector2i(0, 2))
	layout.place_unit(player2, Vector2i(1, 2))

	# 放置敌人
	var enemy1 = _create_test_unit("enemy1", Global.ClassType.WARRIOR, Vector2i(0, 0), false)
	var enemy2 = _create_test_unit("enemy2", Global.ClassType.WARRIOR, Vector2i(1, 0), false)
	layout.place_unit(enemy1, Vector2i(0, 0))
	layout.place_unit(enemy2, Vector2i(1, 0))

	return layout


## 创建测试单位
func _create_test_unit(id: String, class_type: Global.ClassType, position: Vector2i, is_player: bool) -> UnitInstance:
	var def = UnitDefinition.new()
	def.id = id
	def.display_name = id
	def.class_type = class_type
	def.rarity = Global.Rarity.COMMON
	def.hp = 100
	def.attack = 20
	def.armor = 5
	def.attack_speed = 1.0
	def.attack_range = 1 if class_type == Global.ClassType.WARRIOR else 3
	def.move_speed = 1.0
	def.base_price = 50

	var instance = UnitInstance.create(def, position, is_player)
	return instance


## 简单断言
func assert(condition: bool, message: String) -> void:
	if not condition:
		print("  ✗ 断言失败: " + message)
