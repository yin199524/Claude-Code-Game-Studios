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

## 战斗教程组件
var battle_tutorial: Control = null

## 快速提示组件
var quick_hint: Control = null


func _ready() -> void:
	# 加载关卡数据
	_load_level_data()

	# 初始化网格布局
	_setup_grid_layout()

	# 初始化战斗管理器
	_setup_battle_manager()

	# 连接 HUD 信号
	_connect_hud_signals()

	# 设置战斗教程
	_setup_tutorial()

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
	battle_manager.synergies_activated.connect(_on_synergies_activated)


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

	# 通知教程：战斗已开始
	if battle_tutorial and battle_tutorial.has_method("on_battle_started"):
		battle_tutorial.on_battle_started()


## 设置战斗教程
func _setup_tutorial() -> void:
	# 创建教程组件
	battle_tutorial = preload("res://scenes/tutorial/battle_tutorial.gd").new()
	battle_tutorial.name = "BattleTutorial"
	battle_tutorial.anchors_preset = Control.PRESET_FULL_RECT
	add_child(battle_tutorial)

	# 创建快速提示组件
	quick_hint = preload("res://scenes/tutorial/quick_hint.gd").new()
	quick_hint.name = "QuickHint"
	quick_hint.anchors_preset = Control.PRESET_FULL_RECT
	add_child(quick_hint)


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
			var unit_level = SaveManager.get_unit_level(data["id"])
			var instance = UnitInstance.create(def, data["pos"], true, unit_level)
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
func _on_unit_attacked(attacker: UnitInstance, target: UnitInstance, damage: int, counter_status: int) -> void:
	_update_unit_node(target)
	_show_damage_number(target.grid_position, damage, attacker.get_class_type() == Global.ClassType.HEALER, counter_status)

	# 攻击音效
	SoundManager.play_sfx(SoundManager.SFX.UNIT_ATTACK)

	# === 战斗动画增强 ===
	var is_heal = attacker.get_class_type() == Global.ClassType.HEALER
	var is_counter = counter_status == 1

	if is_heal:
		_play_heal_animation(attacker, target)
	else:
		_play_attack_animation_enhanced(attacker, target, is_counter)

	# 显示克制提示（仅玩家单位触发时）
	if counter_status == 1 and attacker.is_player_unit:
		# 检查是否应该显示
		if TutorialManager.should_show_tutorial(TutorialManager.TutorialID.COUNTER):
			if quick_hint and quick_hint.has_method("show_counter_hint"):
				quick_hint.show_counter_hint()
			# 更新提示计数
			TutorialManager.show_counter_hint()


## === 战斗动画增强: 攻击动画 ===
func _play_attack_animation_enhanced(attacker: UnitInstance, target: UnitInstance, is_counter: bool) -> void:
	if not unit_nodes.has(attacker):
		return

	var attacker_node = unit_nodes[attacker]
	var original_pos = attacker_node.position

	# 计算攻击方向
	var target_screen_pos = grid_layout.grid_to_screen(target.grid_position, grid_origin)
	var direction = (target_screen_pos - original_pos).normalized()

	# 增强的冲刺攻击：更远的距离，更快的速度
	var attack_offset = direction * 35  # 增加冲刺距离

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)

	# 冲刺
	tween.tween_property(attacker_node, "position", original_pos + attack_offset, 0.08)
	# 回弹
	tween.tween_property(attacker_node, "position", original_pos, 0.12)

	# 目标受击效果
	if unit_nodes.has(target):
		var target_node = unit_nodes[target]
		var target_original_pos = target_node.position

		# 克制攻击：金色闪光 + 更强抖动
		if is_counter:
			_play_counter_flash(target_node)

		# 命中特效
		_play_hit_effect(target, target_screen_pos)

		# 抖动动画
		var shake_tween = create_tween()
		var shake_amount = 8 if is_counter else 5
		shake_tween.tween_property(target_node, "position", target_original_pos + Vector2(shake_amount, 0), 0.04)
		shake_tween.tween_property(target_node, "position", target_original_pos - Vector2(shake_amount, 0), 0.04)
		shake_tween.tween_property(target_node, "position", target_original_pos + Vector2(shake_amount * 0.5, -shake_amount * 0.5), 0.03)
		shake_tween.tween_property(target_node, "position", target_original_pos, 0.03)


## === 战斗动画增强: 克制闪光 ===
func _play_counter_flash(node: Node2D) -> void:
	# 创建金色闪光层
	var flash = ColorRect.new()
	flash.color = Color(1.0, 0.9, 0.3, 0.6)
	flash.size = Vector2(90, 90)
	flash.position = Vector2(-45, -45)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.z_index = 10
	node.add_child(flash)

	# 闪光动画
	var flash_tween = create_tween()
	flash_tween.tween_property(flash, "modulate:a", 0.0, 0.25)
	flash_tween.tween_callback(flash.queue_free)


## === 战斗动画增强: 命中特效 ===
func _play_hit_effect(target: UnitInstance, position: Vector2) -> void:
	# 创建命中粒子
	for i in range(5):
		var particle = ColorRect.new()
		particle.color = Color(1.0, 0.8, 0.3, 1.0)  # 金黄色
		particle.size = Vector2(randf_range(3, 6), randf_range(3, 6))
		particle.position = position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
		particle.z_index = 50
		$UnitsContainer.add_child(particle)

		# 向外扩散动画
		var angle = randf() * PI * 2
		var distance = randf_range(20, 40)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", position + Vector2(cos(angle) * distance, sin(angle) * distance), 0.3)
		tween.tween_property(particle, "modulate:a", 0.0, 0.3)
		tween.chain().tween_callback(particle.queue_free)


## === 战斗动画增强: 治疗动画 ===
func _play_heal_animation(healer: UnitInstance, target: UnitInstance) -> void:
	if not unit_nodes.has(target):
		return

	var target_node = unit_nodes[target]
	var target_screen_pos = grid_layout.grid_to_screen(target.grid_position, grid_origin)

	# 创建绿色光环效果
	var aura = ColorRect.new()
	aura.color = Color(0.2, 1.0, 0.4, 0.4)  # 绿色半透明
	aura.size = Vector2(100, 100)
	aura.position = target_screen_pos - Vector2(50, 50)
	aura.z_index = 5
	aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$UnitsContainer.add_child(aura)

	# 光环扩散动画
	var aura_tween = create_tween()
	aura_tween.set_parallel(true)
	aura_tween.tween_property(aura, "size", Vector2(120, 120), 0.3)
	aura_tween.tween_property(aura, "position", target_screen_pos - Vector2(60, 60), 0.3)
	aura_tween.tween_property(aura, "modulate:a", 0.0, 0.3)
	aura_tween.chain().tween_callback(aura.queue_free)

	# 治疗粒子上升
	for i in range(4):
		var particle = Label.new()
		particle.text = "✚"
		particle.add_theme_font_size_override("font_size", 16)
		particle.add_theme_color_override("font_color", Color(0.2, 0.9, 0.4, 1.0))
		particle.position = target_screen_pos + Vector2(randf_range(-20, 20), randf_range(-10, 10))
		particle.z_index = 50
		$UnitsContainer.add_child(particle)

		var tween = create_tween()
		tween.tween_property(particle, "position:y", particle.position.y - 40, 0.5)
		tween.parallel().tween_property(particle, "modulate:a", 0.0, 0.5)
		tween.tween_callback(particle.queue_free)


## === 战斗动画增强: 原有攻击动画保留兼容 ===
func _play_attack_animation(attacker: UnitInstance, target: UnitInstance) -> void:
	_play_attack_animation_enhanced(attacker, target, false)


## 单位死亡回调
func _on_unit_died(unit: UnitInstance) -> void:
	# 播放死亡音效
	SoundManager.play_sfx(SoundManager.SFX.UNIT_DEATH)

	# 触发成就和任务事件：击败敌人
	if not unit.is_player_unit:
		# 更新累计击败敌人数
		if SaveManager.player_data != null:
			SaveManager.player_data.total_enemies_defeated += 1
		# 触发成就事件
		AchievementManager.trigger_event("enemy_defeated", {"count": 1})
		# 触发每日任务事件
		DailyMissionManager.trigger_event(Global.DailyMissionType.DEFEAT_ENEMIES, 1)

	if unit_nodes.has(unit):
		var node = unit_nodes[unit]
		var unit_screen_pos = grid_layout.grid_to_screen(unit.grid_position, grid_origin)

		# === 战斗动画增强: 死亡动画 ===
		_play_death_animation(node, unit_screen_pos, unit.is_player_unit)


## === 战斗动画增强: 死亡动画 ===
func _play_death_animation(node: Node2D, position: Vector2, is_player: bool) -> void:
	# 击飞效果
	var knockback_dir = Vector2(randf_range(-1, 1), -1).normalized()  # 向上击飞
	var knockback_dist = 30.0

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(node, "position", position + knockback_dir * knockback_dist, 0.2)
	tween.tween_property(node, "rotation", randf_range(-0.5, 0.5), 0.2)

	# 消散粒子
	_spawn_death_particles(position, is_player)

	# 淡出
	tween.chain().tween_property(node, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): _remove_unit_node_by_node(node))


## === 战斗动画增强: 死亡粒子 ===
func _spawn_death_particles(position: Vector2, is_player: bool) -> void:
	var particle_color = Color(0.8, 0.2, 0.2, 1.0) if not is_player else Color(0.3, 0.6, 0.8, 1.0)

	for i in range(8):
		var particle = ColorRect.new()
		particle.color = particle_color
		particle.size = Vector2(randf_range(4, 8), randf_range(4, 8))
		particle.position = position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		particle.z_index = 100
		$UnitsContainer.add_child(particle)

		# 向外消散
		var angle = randf() * PI * 2
		var distance = randf_range(30, 60)
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", position + Vector2(cos(angle) * distance, sin(angle) * distance - 20), 0.5)
		tween.tween_property(particle, "modulate:a", 0.0, 0.5)
		tween.tween_property(particle, "size", Vector2(2, 2), 0.4)
		tween.chain().tween_callback(particle.queue_free)


## 通过节点移除单位（用于死亡动画回调）
func _remove_unit_node_by_node(node: Node2D) -> void:
	# 查找对应的单位
	for unit in unit_nodes.keys():
		if unit_nodes[unit] == node:
			_remove_unit_node(unit)
			return
	node.queue_free()


## 战斗结束回调
func _on_battle_ended(victory: bool, rewards: Dictionary) -> void:
	battle_victory = victory
	battle_rewards = rewards

	# 通知教程：战斗已结束
	if battle_tutorial and battle_tutorial.has_method("on_battle_ended"):
		battle_tutorial.on_battle_ended(victory)

	# 播放胜利/失败音效
	if victory:
		SoundManager.play_sfx(SoundManager.SFX.BATTLE_VICTORY)
	else:
		SoundManager.play_sfx(SoundManager.SFX.BATTLE_DEFEAT)

	# 添加关卡奖励
	var gold_reward = 0
	var next_level: LevelDefinition = null
	var unlocked_new_level = false
	var stars = 0  # 星级评价

	if victory and current_level:
		gold_reward = current_level.gold_reward

		# 计算星级 (T12)
		stars = _calculate_stars()
		# 星级加成金币奖励
		var star_bonus = stars * 20  # 每星额外 20 金币
		gold_reward += star_bonus

		rewards["gold"] = gold_reward
		rewards["stars"] = stars
		SaveManager.add_gold(gold_reward)

		# 完成关卡并保存星级
		LevelDatabase.complete_level(current_level.id)
		SaveManager.set_level_stars(current_level.id, stars)

		# 检查并解锁下一关
		next_level = LevelDatabase.get_next_level(current_level.id)
		if next_level and not LevelDatabase.is_level_unlocked(next_level.id):
			LevelDatabase.unlock_level(next_level.id)
			unlocked_new_level = true

		# 保存游戏
		SaveManager.save_game()

		# 触发成就和任务事件：通关关卡
		AchievementManager.trigger_event("level_completed", {"level_id": current_level.id})
		DailyMissionManager.trigger_event(Global.DailyMissionType.WIN_LEVELS, 1)

	# 更新 UI
	var hud = $HUD
	var result_panel = hud.get_node("ResultPanel")
	var icon_label = result_panel.get_node("VBoxContainer/IconLabel")
	var result_label = result_panel.get_node("VBoxContainer/ResultLabel")
	var reward_label = result_panel.get_node("VBoxContainer/RewardLabel")

	if victory:
		# 显示星级
		icon_label.text = _get_star_display(stars)
		result_label.text = "战斗胜利!"
		result_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
		reward_label.text = "获得金币: %d (星级奖励: %d)" % [rewards.get("gold", 0), stars * 20]
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

	# 关卡解锁动画
	if victory and unlocked_new_level and next_level:
		await get_tree().create_timer(0.5).timeout
		SceneTransition.show_level_unlock_animation(self, next_level.display_name, Vector2(360, 500))


## 计算星级评价 (T12)
## 返回: 1-3 星
func _calculate_stars() -> int:
	var state = battle_manager.get_battle_state()
	var turns = state.current_turn
	var player_alive = state.player_units_alive

	# 星级规则：
	# 3星: 回合数 < 10 且存活单位 >= 2
	# 2星: 回合数 < 15 且存活单位 >= 1
	# 1星: 其他情况

	if turns < 10 and player_alive >= 2:
		return 3
	elif turns < 15 and player_alive >= 1:
		return 2
	else:
		return 1


## 获取星级显示文本
func _get_star_display(stars: int) -> String:
	match stars:
		3:
			return "⭐⭐⭐"
		2:
			return "⭐⭐"
		1:
			return "⭐"
	return ""


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

	# 职业图标
	var class_icon = Label.new()
	class_icon.text = _get_unit_class_icon(unit.get_class_type())
	class_icon.position = Vector2(-15, -30)
	class_icon.add_theme_font_size_override("font_size", 28)
	class_icon.z_index = 1
	node.add_child(class_icon)

	var hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(-35, -50)
	hp_bar.size = Vector2(70, 10)
	hp_bar.max_value = unit.get_max_hp()
	hp_bar.value = unit.current_hp
	hp_bar.show_percentage = false

	var name_label = Label.new()
	name_label.text = "%s Lv.%d" % [unit.definition.display_name, unit.level]
	name_label.position = Vector2(-35, 40)
	name_label.add_theme_font_size_override("font_size", 11)

	node.add_child(sprite)
	node.add_child(hp_bar)
	node.add_child(name_label)

	return node


## 获取单位职业图标
func _get_unit_class_icon(class_type: Global.ClassType) -> String:
	match class_type:
		Global.ClassType.WARRIOR:
			return "🗡"
		Global.ClassType.ARCHER:
			return "🏹"
		Global.ClassType.MAGE:
			return "🔮"
		Global.ClassType.KNIGHT:
			return "🛡"
		Global.ClassType.HEALER:
			return "💚"
	return "?"


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
## counter_status: 1=克制(金色), -1=被克制(灰色), 0=普通
func _show_damage_number(position: Vector2i, damage: int, is_heal: bool, counter_status: int = 0) -> void:
	var screen_pos = grid_layout.grid_to_screen(position, grid_origin)

	var label = Label.new()
	label.text = str(damage)
	label.position = screen_pos + Vector2(-20, -80)
	label.add_theme_font_size_override("font_size", 24)

	# 根据状态设置颜色
	if is_heal:
		# 治疗为绿色
		label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	elif counter_status == 1:
		# 克制为金色
		label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		label.add_theme_font_size_override("font_size", 28)  # 克制伤害数字更大
	elif counter_status == -1:
		# 被克制为灰色
		label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	else:
		# 普通伤害为红色
		label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))

	add_child(label)

	# 克制倍率标签
	if counter_status != 0 and not is_heal:
		var counter_label = Label.new()
		if counter_status == 1:
			counter_label.text = "+30%"
			counter_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		else:
			counter_label.text = "-20%"
			counter_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		counter_label.position = screen_pos + Vector2(25, -75)
		counter_label.add_theme_font_size_override("font_size", 14)
		add_child(counter_label)

		var counter_tween = create_tween()
		counter_tween.set_parallel(true)
		counter_tween.tween_property(counter_label, "position:y", counter_label.position.y - 50, 1.0)
		counter_tween.tween_property(counter_label, "modulate:a", 0.0, 1.0)
		counter_tween.chain().tween_callback(counter_label.queue_free)

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


## 协同激活回调
func _on_synergies_activated(synergy_names: Array[String]) -> void:
	# 更新累计协同触发次数
	if SaveManager.player_data != null:
		SaveManager.player_data.total_synergies_triggered += synergy_names.size()

	# === 战斗动画增强: 协同连线特效 ===
	_play_synergy_connection_effect()

	# 触发成就和任务事件
	for synergy_name in synergy_names:
		# 查找对应的协同ID
		var synergy_id = _get_synergy_id_by_name(synergy_name)
		AchievementManager.trigger_event("synergy_triggered", {"synergy_id": synergy_id})

		# 显示协同提示
		if TutorialManager.should_show_tutorial(TutorialManager.TutorialID.SYNERGY):
			if quick_hint and quick_hint.has_method("show_synergy_hint"):
				quick_hint.show_synergy_hint(synergy_name)
			# 更新提示计数
			TutorialManager.show_synergy_hint(synergy_name)

	DailyMissionManager.trigger_event(Global.DailyMissionType.TRIGGER_SYNERGY, synergy_names.size())


## === 战斗动画增强: 协同连线特效 ===
func _play_synergy_connection_effect() -> void:
	# 获取所有存活的玩家单位
	var player_units = grid_layout.get_player_units()
	var alive_units: Array[UnitInstance] = []
	for unit in player_units:
		if unit.is_alive:
			alive_units.append(unit)

	if alive_units.size() < 2:
		return

	# 在每对相邻单位之间创建连线
	for i in range(alive_units.size() - 1):
		var unit1 = alive_units[i]
		var unit2 = alive_units[i + 1]

		if not unit_nodes.has(unit1) or not unit_nodes.has(unit2):
			continue

		var pos1 = grid_layout.grid_to_screen(unit1.grid_position, grid_origin)
		var pos2 = grid_layout.grid_to_screen(unit2.grid_position, grid_origin)

		# 创建连线
		_create_synergy_line(pos1, pos2)


## 创建协同连线
func _create_synergy_line(from: Vector2, to: Vector2) -> void:
	var line = Line2D.new()
	line.add_point(from)
	line.add_point(to)
	line.width = 3.0
	line.default_color = Color(0.4, 0.8, 1.0, 0.8)  # 青蓝色
	line.z_index = 30
	$UnitsContainer.add_child(line)

	# 连线渐隐动画
	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 0.5)
	tween.tween_callback(line.queue_free)

	# 在连线中点创建闪光
	var mid_point = (from + to) / 2.0
	var flash = ColorRect.new()
	flash.color = Color(0.6, 1.0, 1.0, 0.8)
	flash.size = Vector2(12, 12)
	flash.position = mid_point - Vector2(6, 6)
	flash.z_index = 35
	$UnitsContainer.add_child(flash)

	var flash_tween = create_tween()
	flash_tween.set_parallel(true)
	flash_tween.tween_property(flash, "size", Vector2(24, 24), 0.3)
	flash_tween.tween_property(flash, "position", mid_point - Vector2(12, 12), 0.3)
	flash_tween.tween_property(flash, "modulate:a", 0.0, 0.3)
	flash_tween.chain().tween_callback(flash.queue_free)


## 根据名称获取协同ID
func _get_synergy_id_by_name(name: String) -> String:
	var name_to_id = {
		"战士兄弟": "warrior_brothers",
		"法术共鸣": "magic_resonance",
		"骑士荣耀": "knight_honor",
		"治愈之光": "healing_light",
		"箭雨风暴": "arrow_storm",
		"暗影突袭": "shadow_strike",
		"前排护卫": "front_guard",
		"后排输出": "back_fire",
		"攻守平衡": "balance",
		"魔武双修": "magic_martial"
	}
	return name_to_id.get(name, "")
