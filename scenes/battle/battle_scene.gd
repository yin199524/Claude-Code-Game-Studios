# battle_scene.gd - 战斗场景主脚本
# 管理 BattleManager 和 UI 的交互

extends Node2D

## 回合时长（秒）
const TURN_DURATION: float = 1.0

## 格子大小
const CELL_SIZE: int = 100

## 网格原点
var grid_origin: Vector2 = Vector2(50, 50)

## 战斗管理器
var battle_manager: BattleManager = null

## 网格布局
var grid_layout: GridLayout = null

## 当前关卡定义
var current_level: LevelDefinition = null

## 单位节点映射
var unit_nodes: Dictionary = {}

## 是否已初始化
var is_initialized: bool = false

## 战斗结果
var battle_victory: bool = false
var battle_rewards: Dictionary = {}


func _ready() -> void:
	# 加载关卡数据
	_load_level_data()

	# 初始化网格布局
	_setup_grid_layout()

	# 初始化战斗管理器
	_setup_battle_manager()

	# 连接 HUD 信号
	_connect_hud_signals()

	is_initialized = true

	# 加载布局并开始战斗
	start_battle()


func _process(delta: float) -> void:
	if battle_manager and battle_manager.is_battling:
		battle_manager.update(delta)


## 加载关卡数据
func _load_level_data() -> void:
	var level_id = GameManager.current_level_id
	if level_id.is_empty():
		level_id = "level_001"

	current_level = LevelDatabase.get_level(level_id)
	if current_level == null:
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


## 设置战斗管理器
func _setup_battle_manager() -> void:
	battle_manager = BattleManager.new()
	battle_manager.initialize(grid_layout)
	battle_manager.turn_duration = TURN_DURATION

	battle_manager.turn_completed.connect(_on_turn_completed)
	battle_manager.unit_attacked.connect(_on_unit_attacked)
	battle_manager.unit_died.connect(_on_unit_died)
	battle_manager.battle_ended.connect(_on_battle_ended)


## 连接 HUD 信号
func _connect_hud_signals() -> void:
	var hud = $HUD
	if hud.has_node("TopBar/HBoxContainer/PauseButton"):
		var pause_btn = hud.get_node("TopBar/HBoxContainer/PauseButton")
		pause_btn.pressed.connect(_on_pause_pressed)

	if hud.has_node("TopBar/HBoxContainer/SpeedButton"):
		var speed_btn = hud.get_node("TopBar/HBoxContainer/SpeedButton")
		speed_btn.pressed.connect(_on_speed_pressed)

	var result_panel = hud.get_node("ResultPanel")
	if result_panel.has_node("VBoxContainer/ContinueButton"):
		var continue_btn = result_panel.get_node("VBoxContainer/ContinueButton")
		continue_btn.pressed.connect(_on_continue_pressed)


## 开始战斗
func start_battle() -> void:
	# 清空现有单位
	grid_layout.clear()
	_clear_unit_nodes()

	# 加载玩家布局
	_load_player_layout()

	# 加载敌人
	_load_enemies()

	# 播放战斗开始音效
	SoundManager.play_sfx(SoundManager.SFX.BATTLE_START)

	# 开始战斗
	battle_manager.start_battle()


## 加载玩家布局
func _load_player_layout() -> void:
	# 尝试从 GameManager 获取保存的布局
	if GameManager.has_meta("battle_layout"):
		var saved_layout = GameManager.get_meta("battle_layout") as GridLayout
		if saved_layout:
			# 复制玩家单位
			for unit in saved_layout.get_player_units():
				grid_layout.place_unit(unit, unit.grid_position)
			return

	# 如果没有保存的布局，使用测试单位
	_create_test_player_units()


## 创建测试玩家单位
func _create_test_player_units() -> void:
	var player_units = [
		{"id": "unit_warrior", "pos": Vector2i(0, 2)},
		{"id": "unit_archer", "pos": Vector2i(1, 2)},
		{"id": "unit_mage", "pos": Vector2i(2, 2)}
	]

	for data in player_units:
		var def = UnitDatabase.get_unit(data["id"])
		if def:
			var instance = UnitInstance.create(def, data["pos"], true)
			grid_layout.place_unit(instance, data["pos"])


## 加载敌人
func _load_enemies() -> void:
	if current_level == null:
		_create_test_enemies()
		return

	for spawn in current_level.enemy_spawns:
		var unit_def = UnitDatabase.get_unit(spawn.unit_id)
		if unit_def == null:
			continue

		var instance = UnitInstance.create(unit_def, spawn.position, false)

		# 应用属性加成
		instance.definition = unit_def.duplicate()
		instance.definition.hp = int(unit_def.hp * spawn.level_modifier)
		instance.definition.attack = int(unit_def.attack * spawn.level_modifier)
		instance.current_hp = instance.get_max_hp()
		instance.definition.display_name = "敌人%s" % unit_def.display_name

		grid_layout.place_unit(instance, spawn.position)


## 创建测试敌人
func _create_test_enemies() -> void:
	var enemy_def = UnitDatabase.get_unit("unit_warrior")
	if enemy_def:
		var enemy1 = UnitInstance.create(enemy_def, Vector2i(0, 0), false)
		enemy1.definition = enemy_def.duplicate()
		enemy1.definition.display_name = "敌人战士"
		grid_layout.place_unit(enemy1, Vector2i(0, 0))

		var enemy2 = UnitInstance.create(enemy_def, Vector2i(2, 0), false)
		enemy2.definition = enemy_def.duplicate()
		enemy2.definition.display_name = "敌人战士"
		grid_layout.place_unit(enemy2, Vector2i(2, 0))


## 单位放置回调
func _on_unit_placed(unit: UnitInstance, position: Vector2i) -> void:
	_create_unit_node(unit)


## 单位移除回调
func _on_unit_removed(unit: UnitInstance, position: Vector2i) -> void:
	_remove_unit_node(unit)


## 回合完成回调
func _on_turn_completed(turn_number: int) -> void:
	var hud = $HUD
	if hud.has_node("TopBar/HBoxContainer/TurnLabel"):
		var label = hud.get_node("TopBar/HBoxContainer/TurnLabel")
		label.text = "回合: %d" % turn_number


## 单位攻击回调
func _on_unit_attacked(attacker: UnitInstance, target: UnitInstance, damage: int) -> void:
	_update_unit_node(target)
	_show_damage_number(target.grid_position, damage, attacker.get_class_type() == Global.ClassType.HEALER)

	# 攻击音效
	SoundManager.play_sfx(SoundManager.SFX.UNIT_ATTACK)

	# 攻击动画
	_play_attack_animation(attacker, target)


## 播放攻击动画
func _play_attack_animation(attacker: UnitInstance, target: UnitInstance) -> void:
	if not unit_nodes.has(attacker):
		return

	var attacker_node = unit_nodes[attacker]
	var original_pos = attacker_node.position

	# 计算攻击方向
	var target_screen_pos = grid_layout.grid_to_screen(target.grid_position, grid_origin)
	var direction = (target_screen_pos - original_pos).normalized()

	# 冲向目标
	var tween = create_tween()
	var attack_offset = direction * 20

	tween.tween_property(attacker_node, "position", original_pos + attack_offset, 0.1)
	tween.tween_property(attacker_node, "position", original_pos, 0.15)

	# 目标抖动
	if unit_nodes.has(target):
		var target_node = unit_nodes[target]
		var target_original_pos = target_node.position
		var shake_tween = create_tween()
		shake_tween.tween_property(target_node, "position", target_original_pos + Vector2(5, 0), 0.05)
		shake_tween.tween_property(target_node, "position", target_original_pos - Vector2(5, 0), 0.05)
		shake_tween.tween_property(target_node, "position", target_original_pos, 0.05)


## 单位死亡回调
func _on_unit_died(unit: UnitInstance) -> void:
	# 播放死亡音效
	SoundManager.play_sfx(SoundManager.SFX.UNIT_DEATH)

	if unit_nodes.has(unit):
		var node = unit_nodes[unit]
		var tween = create_tween()
		tween.tween_property(node, "modulate:a", 0.0, 0.5)
		tween.tween_callback(func(): _remove_unit_node(unit))


## 战斗结束回调
func _on_battle_ended(victory: bool, rewards: Dictionary) -> void:
	battle_victory = victory
	battle_rewards = rewards

	# 播放胜利/失败音效
	if victory:
		SoundManager.play_sfx(SoundManager.SFX.BATTLE_VICTORY)
	else:
		SoundManager.play_sfx(SoundManager.SFX.BATTLE_DEFEAT)

	# 添加关卡奖励
	var gold_reward = 0
	if victory and current_level:
		gold_reward = current_level.gold_reward
		rewards["gold"] = gold_reward
		SaveManager.add_gold(gold_reward)

		# 完成关卡
		LevelDatabase.complete_level(current_level.id)

		# 保存游戏
		SaveManager.save_game()

	# 更新 UI
	var hud = $HUD
	var result_panel = hud.get_node("ResultPanel")
	var icon_label = result_panel.get_node("VBoxContainer/IconLabel")
	var result_label = result_panel.get_node("VBoxContainer/ResultLabel")
	var reward_label = result_panel.get_node("VBoxContainer/RewardLabel")

	if victory:
		icon_label.text = "🏆"
		result_label.text = "战斗胜利!"
		result_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
		reward_label.text = "获得金币: %d" % rewards.get("gold", 0)
	else:
		icon_label.text = "💔"
		result_label.text = "战斗失败..."
		result_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4, 1))
		reward_label.text = "再接再厉!"

	# 弹出动画
	SceneTransition.popup_animation(result_panel)

	# 粒子效果
	var screen_center = Vector2(360, 640)
	if victory:
		ParticleEffects.create_victory_particles(self, screen_center)
	else:
		ParticleEffects.create_defeat_particles(self, screen_center)

	# 金币飘字动画
	if victory and gold_reward > 0:
		await get_tree().create_timer(0.3).timeout
		SoundManager.play_sfx(SoundManager.SFX.GOLD_GAIN)
		SceneTransition.show_gold_floating_text(self, gold_reward, screen_center)


## 创建单位节点
func _create_unit_node(unit: UnitInstance) -> void:
	var node = _create_unit_visual(unit)
	$UnitsContainer.add_child(node)
	unit_nodes[unit] = node


## 移除单位节点
func _remove_unit_node(unit: UnitInstance) -> void:
	if unit_nodes.has(unit):
		var node = unit_nodes[unit]
		node.queue_free()
		unit_nodes.erase(unit)


## 清空所有单位节点
func _clear_unit_nodes() -> void:
	for unit in unit_nodes.keys():
		_remove_unit_node(unit)


## 创建单位视觉节点
func _create_unit_visual(unit: UnitInstance) -> Node2D:
	var node = Node2D.new()
	node.position = grid_layout.grid_to_screen(unit.grid_position, grid_origin)

	var sprite = ColorRect.new()
	sprite.size = Vector2(80, 80)
	sprite.position = Vector2(-40, -40)
	sprite.color = _get_unit_color(unit)

	var hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(-35, -50)
	hp_bar.size = Vector2(70, 10)
	hp_bar.max_value = unit.get_max_hp()
	hp_bar.value = unit.current_hp
	hp_bar.show_percentage = false

	var name_label = Label.new()
	name_label.text = unit.definition.display_name
	name_label.position = Vector2(-30, 40)
	name_label.add_theme_font_size_override("font_size", 12)

	node.add_child(sprite)
	node.add_child(hp_bar)
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


## 更新单位节点
func _update_unit_node(unit: UnitInstance) -> void:
	if not unit_nodes.has(unit):
		return

	var node = unit_nodes[unit]
	var hp_bar = node.get_child(1) as ProgressBar
	if hp_bar:
		hp_bar.value = unit.current_hp


## 显示伤害数字
func _show_damage_number(position: Vector2i, damage: int, is_heal: bool) -> void:
	var screen_pos = grid_layout.grid_to_screen(position, grid_origin)

	var label = Label.new()
	label.text = str(damage)
	label.position = screen_pos + Vector2(-20, -80)
	label.add_theme_font_size_override("font_size", 24)

	if is_heal:
		label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	else:
		label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 50, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(label.queue_free)


## 暂停按钮回调
func _on_pause_pressed() -> void:
	var hud = $HUD
	var pause_btn = hud.get_node("TopBar/HBoxContainer/PauseButton")

	if battle_manager.is_paused:
		battle_manager.resume_battle()
		pause_btn.text = "⏸ 暂停"
	else:
		battle_manager.pause_battle()
		pause_btn.text = "▶ 继续"


## 速度按钮回调
func _on_speed_pressed() -> void:
	var hud = $HUD
	var speed_btn = hud.get_node("TopBar/HBoxContainer/SpeedButton")

	var new_speed: float
	var new_text: String

	if battle_manager.battle_speed == 1.0:
		new_speed = 2.0
		new_text = "2x"
	elif battle_manager.battle_speed == 2.0:
		new_speed = 3.0
		new_text = "3x"
	else:
		new_speed = 1.0
		new_text = "1x"

	battle_manager.set_battle_speed(new_speed)
	speed_btn.text = new_text


## 继续按钮回调
func _on_continue_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	if battle_victory:
		# 胜利后去商店
		SceneTransition.change_scene("res://scenes/shop/shop_scene.tscn")
	else:
		# 失败后回关卡选择
		SceneTransition.change_scene("res://scenes/level/level_select.tscn")
