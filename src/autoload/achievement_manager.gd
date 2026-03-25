# AchievementManager.gd - 成就管理器单例
# 管理: 成就定义、进度追踪和解锁检测
# 参考: design/gdd/achievement-system.md

extends Node

## 成就定义字典 {achievement_id: AchievementDefinition}
var _achievements: Dictionary = {}

## 成就进度缓存 {achievement_id: current_value}
var _progress_cache: Dictionary = {}

## 加载完成信号
signal achievements_loaded()

## 成就解锁信号
signal achievement_unlocked(achievement_id: String, achievement: AchievementDefinition)

## 成就进度更新信号
signal achievement_progress_updated(achievement_id: String, current_value: int, target_value: int)

## 是否已加载
var is_loaded: bool = false


func _ready() -> void:
	load_achievements()


## 加载所有成就定义
func load_achievements() -> void:
	_achievements.clear()
	_create_achievements()
	_load_progress_from_save()
	is_loaded = true
	achievements_loaded.emit()


## 创建所有成就定义
func _create_achievements() -> void:
	# === 进度类成就 ===

	# 初战告捷 - 通关第一关
	var ach_first_victory = AchievementDefinition.new()
	ach_first_victory.id = "ach_first_victory"
	ach_first_victory.display_name = "初战告捷"
	ach_first_victory.description = "通关第一关"
	ach_first_victory.category = Global.AchievementCategory.PROGRESS
	ach_first_victory.target_value = 1
	ach_first_victory.reward_gold = 100
	ach_first_victory.trigger_event = "level_completed"
	ach_first_victory.condition_params = {"level_id": "level_001"}
	_achievements[ach_first_victory.id] = ach_first_victory

	# 森林征服者 - 通关森林世界 (level_001-005)
	var ach_forest_master = AchievementDefinition.new()
	ach_forest_master.id = "ach_forest_master"
	ach_forest_master.display_name = "森林征服者"
	ach_forest_master.description = "通关森林世界的所有关卡"
	ach_forest_master.category = Global.AchievementCategory.PROGRESS
	ach_forest_master.target_value = 5
	ach_forest_master.reward_gold = 200
	ach_forest_master.trigger_event = "level_completed"
	ach_forest_master.condition_params = {"world": "forest"}
	_achievements[ach_forest_master.id] = ach_forest_master

	# 沙漠征服者
	var ach_desert_master = AchievementDefinition.new()
	ach_desert_master.id = "ach_desert_master"
	ach_desert_master.display_name = "沙漠征服者"
	ach_desert_master.description = "通关沙漠世界的所有关卡"
	ach_desert_master.category = Global.AchievementCategory.PROGRESS
	ach_desert_master.target_value = 4
	ach_desert_master.reward_gold = 300
	ach_desert_master.trigger_event = "level_completed"
	ach_desert_master.condition_params = {"world": "desert"}
	_achievements[ach_desert_master.id] = ach_desert_master

	# 冰原征服者
	var ach_ice_master = AchievementDefinition.new()
	ach_ice_master.id = "ach_ice_master"
	ach_ice_master.display_name = "冰原征服者"
	ach_ice_master.description = "通关冰原世界的所有关卡"
	ach_ice_master.category = Global.AchievementCategory.PROGRESS
	ach_ice_master.target_value = 4
	ach_ice_master.reward_gold = 400
	ach_ice_master.trigger_event = "level_completed"
	ach_ice_master.condition_params = {"world": "ice"}
	_achievements[ach_ice_master.id] = ach_ice_master

	# 火山征服者
	var ach_volcano_master = AchievementDefinition.new()
	ach_volcano_master.id = "ach_volcano_master"
	ach_volcano_master.display_name = "火山征服者"
	ach_volcano_master.description = "通关火山世界的所有关卡"
	ach_volcano_master.category = Global.AchievementCategory.PROGRESS
	ach_volcano_master.target_value = 4
	ach_volcano_master.reward_gold = 500
	ach_volcano_master.trigger_event = "level_completed"
	ach_volcano_master.condition_params = {"world": "volcano"}
	_achievements[ach_volcano_master.id] = ach_volcano_master

	# 暗影终结者
	var ach_shadow_master = AchievementDefinition.new()
	ach_shadow_master.id = "ach_shadow_master"
	ach_shadow_master.display_name = "暗影终结者"
	ach_shadow_master.description = "通关暗影世界的所有关卡"
	ach_shadow_master.category = Global.AchievementCategory.PROGRESS
	ach_shadow_master.target_value = 4
	ach_shadow_master.reward_gold = 1000
	ach_shadow_master.trigger_event = "level_completed"
	ach_shadow_master.condition_params = {"world": "shadow"}
	_achievements[ach_shadow_master.id] = ach_shadow_master

	# === 收集类成就 ===

	# 初收集者 - 收集 5 个不同单位
	var ach_unit_collector_5 = AchievementDefinition.new()
	ach_unit_collector_5.id = "ach_unit_collector_5"
	ach_unit_collector_5.display_name = "初收集者"
	ach_unit_collector_5.description = "收集 5 个不同的单位"
	ach_unit_collector_5.category = Global.AchievementCategory.COLLECTION
	ach_unit_collector_5.target_value = 5
	ach_unit_collector_5.reward_gold = 150
	ach_unit_collector_5.trigger_event = "unit_collected"
	_achievements[ach_unit_collector_5.id] = ach_unit_collector_5

	# 收藏家 - 收集 10 个不同单位
	var ach_unit_collector_10 = AchievementDefinition.new()
	ach_unit_collector_10.id = "ach_unit_collector_10"
	ach_unit_collector_10.display_name = "收藏家"
	ach_unit_collector_10.description = "收集 10 个不同的单位"
	ach_unit_collector_10.category = Global.AchievementCategory.COLLECTION
	ach_unit_collector_10.target_value = 10
	ach_unit_collector_10.reward_gold = 300
	ach_unit_collector_10.trigger_event = "unit_collected"
	_achievements[ach_unit_collector_10.id] = ach_unit_collector_10

	# === 升级类成就 ===

	# 初次升级 - 升级任意单位 1 次
	var ach_first_upgrade = AchievementDefinition.new()
	ach_first_upgrade.id = "ach_first_upgrade"
	ach_first_upgrade.display_name = "初次升级"
	ach_first_upgrade.description = "升级任意单位 1 次"
	ach_first_upgrade.category = Global.AchievementCategory.UPGRADE
	ach_first_upgrade.target_value = 1
	ach_first_upgrade.reward_gold = 100
	ach_first_upgrade.trigger_event = "unit_upgraded"
	_achievements[ach_first_upgrade.id] = ach_first_upgrade

	# 满级大师 - 将单位升到满级
	var ach_max_upgrade = AchievementDefinition.new()
	ach_max_upgrade.id = "ach_max_upgrade"
	ach_max_upgrade.display_name = "满级大师"
	ach_max_upgrade.description = "将任意单位升到满级"
	ach_max_upgrade.category = Global.AchievementCategory.UPGRADE
	ach_max_upgrade.target_value = 1
	ach_max_upgrade.reward_gold = 500
	ach_max_upgrade.trigger_event = "unit_max_level"
	_achievements[ach_max_upgrade.id] = ach_max_upgrade

	# === 战斗类成就 ===

	# 百人斩 - 累计击败 100 个敌人
	var ach_kill_100 = AchievementDefinition.new()
	ach_kill_100.id = "ach_kill_100"
	ach_kill_100.display_name = "百人斩"
	ach_kill_100.description = "累计击败 100 个敌人"
	ach_kill_100.category = Global.AchievementCategory.COMBAT
	ach_kill_100.target_value = 100
	ach_kill_100.reward_gold = 200
	ach_kill_100.trigger_event = "enemy_defeated"
	_achievements[ach_kill_100.id] = ach_kill_100

	# 千人斩 - 累计击败 1000 个敌人
	var ach_kill_1000 = AchievementDefinition.new()
	ach_kill_1000.id = "ach_kill_1000"
	ach_kill_1000.display_name = "千人斩"
	ach_kill_1000.description = "累计击败 1000 个敌人"
	ach_kill_1000.category = Global.AchievementCategory.COMBAT
	ach_kill_1000.target_value = 1000
	ach_kill_1000.reward_gold = 1000
	ach_kill_1000.trigger_event = "enemy_defeated"
	_achievements[ach_kill_1000.id] = ach_kill_1000

	# === 协同类成就 ===

	# 战士兄弟 - 触发战士协同效果
	var ach_warrior_synergy = AchievementDefinition.new()
	ach_warrior_synergy.id = "ach_warrior_synergy"
	ach_warrior_synergy.display_name = "战士兄弟"
	ach_warrior_synergy.description = "触发战士协同效果"
	ach_warrior_synergy.category = Global.AchievementCategory.SYNERGY
	ach_warrior_synergy.target_value = 1
	ach_warrior_synergy.reward_gold = 100
	ach_warrior_synergy.trigger_event = "synergy_triggered"
	ach_warrior_synergy.condition_params = {"synergy_id": "warrior_brothers"}
	_achievements[ach_warrior_synergy.id] = ach_warrior_synergy

	# 法术共鸣 - 触发法师协同效果
	var ach_mage_synergy = AchievementDefinition.new()
	ach_mage_synergy.id = "ach_mage_synergy"
	ach_mage_synergy.display_name = "法术共鸣"
	ach_mage_synergy.description = "触发法师协同效果"
	ach_mage_synergy.category = Global.AchievementCategory.SYNERGY
	ach_mage_synergy.target_value = 1
	ach_mage_synergy.reward_gold = 100
	ach_mage_synergy.trigger_event = "synergy_triggered"
	ach_mage_synergy.condition_params = {"synergy_id": "magic_resonance"}
	_achievements[ach_mage_synergy.id] = ach_mage_synergy


## 从存档加载进度
func _load_progress_from_save() -> void:
	if SaveManager.player_data == null:
		return

	_progress_cache = SaveManager.player_data.achievement_progress.duplicate()


## 通过 ID 获取成就定义
func get_achievement(achievement_id: String) -> AchievementDefinition:
	if _achievements.has(achievement_id):
		return _achievements[achievement_id]
	return null


## 获取所有成就定义
func get_all_achievements() -> Array[AchievementDefinition]:
	var result: Array[AchievementDefinition] = []
	for ach in _achievements.values():
		result.append(ach)
	return result


## 获取成就进度
func get_progress(achievement_id: String) -> int:
	return _progress_cache.get(achievement_id, 0)


## 检查成就是否已解锁
func is_achievement_unlocked(achievement_id: String) -> bool:
	if SaveManager.player_data == null:
		return false
	return achievement_id in SaveManager.player_data.unlocked_achievements


## 获取已解锁成就数量
func get_unlocked_count() -> int:
	if SaveManager.player_data == null:
		return 0
	return SaveManager.player_data.unlocked_achievements.size()


## 获取总成就数量
func get_total_count() -> int:
	return _achievements.size()


## 获取完成率 (0.0 - 1.0)
func get_completion_rate() -> float:
	if _achievements.is_empty():
		return 0.0
	return float(get_unlocked_count()) / float(_achievements.size())


## 触发事件（由各游戏系统调用）
## event_name: 事件名称
## params: 事件参数
func trigger_event(event_name: String, params: Dictionary = {}) -> void:
	for achievement_id in _achievements.keys():
		var achievement = _achievements[achievement_id]

		# 跳过已解锁的成就
		if is_achievement_unlocked(achievement_id):
			continue

		# 检查事件是否匹配
		if achievement.trigger_event != event_name:
			continue

		# 更新进度
		var should_update = false
		var increment = 1  # 默认增量

		match event_name:
			"level_completed":
				should_update = _check_level_completed(achievement, params)
			"unit_collected":
				should_update = true
				increment = params.get("count", 1)
			"unit_upgraded":
				should_update = true
			"unit_max_level":
				should_update = true
			"enemy_defeated":
				should_update = true
				increment = params.get("count", 1)
			"synergy_triggered":
				should_update = _check_synergy_triggered(achievement, params)

		if should_update:
			_update_progress(achievement_id, increment)


## 检查关卡完成事件
func _check_level_completed(achievement: AchievementDefinition, params: Dictionary) -> bool:
	var level_id = params.get("level_id", "")
	var condition = achievement.condition_params

	# 特定关卡成就
	if condition.has("level_id"):
		return level_id == condition.level_id

	# 世界成就
	if condition.has("world"):
		var world = condition.world
		return _is_level_in_world(level_id, world)

	return false


## 检查关卡是否属于指定世界
func _is_level_in_world(level_id: String, world: String) -> bool:
	var level_num = level_id.replace("level_", "").to_int()
	match world:
		"forest":
			return level_num >= 1 and level_num <= 5
		"desert":
			return level_num >= 6 and level_num <= 9
		"ice":
			return level_num >= 10 and level_num <= 13
		"volcano":
			return level_num >= 14 and level_num <= 17
		"shadow":
			return level_num >= 18 and level_num <= 21
	return false


## 检查协同触发事件
func _check_synergy_triggered(achievement: AchievementDefinition, params: Dictionary) -> bool:
	var synergy_id = params.get("synergy_id", "")
	var condition = achievement.condition_params

	if condition.has("synergy_id"):
		return synergy_id == condition.synergy_id

	return true


## 更新成就进度
func _update_progress(achievement_id: String, increment: int = 1) -> void:
	var achievement = _achievements.get(achievement_id)
	if achievement == null:
		return

	var current = _progress_cache.get(achievement_id, 0)
	var new_value = current + increment

	_progress_cache[achievement_id] = new_value

	# 保存进度到存档
	if SaveManager.player_data != null:
		SaveManager.player_data.achievement_progress[achievement_id] = new_value

	# 发送进度更新信号
	achievement_progress_updated.emit(achievement_id, new_value, achievement.target_value)

	# 检查是否解锁
	if achievement.is_completed(new_value) and not is_achievement_unlocked(achievement_id):
		_unlock_achievement(achievement_id)


## 解锁成就
func _unlock_achievement(achievement_id: String) -> void:
	var achievement = _achievements.get(achievement_id)
	if achievement == null:
		return

	# 添加到已解锁列表
	if SaveManager.player_data != null:
		if achievement_id not in SaveManager.player_data.unlocked_achievements:
			SaveManager.player_data.unlocked_achievements.append(achievement_id)
			SaveManager.player_data.achievement_unlock_times[achievement_id] = int(Time.get_unix_time_from_system())

	# 发放奖励
	SaveManager.add_gold(achievement.reward_gold)

	# 保存
	SaveManager.save_game()

	# 发送解锁信号
	achievement_unlocked.emit(achievement_id, achievement)


## 按类别获取成就列表
func get_achievements_by_category(category: int) -> Array[AchievementDefinition]:
	var result: Array[AchievementDefinition] = []
	for achievement in _achievements.values():
		if achievement.category == category:
			result.append(achievement)
	return result


## 验证所有成就定义
func validate_all() -> Array:
	var all_valid: bool = true
	var errors: Array[String] = []

	for achievement_id in _achievements.keys():
		var achievement = _achievements[achievement_id]
		var result = achievement.validate()
		if not result[0]:
			all_valid = false
			errors.append("成就 %s 验证失败: %s" % [achievement_id, result[1]])

	return [all_valid, "\n".join(errors)]


## 重置所有进度（用于测试）
func reset_progress() -> void:
	_progress_cache.clear()
	if SaveManager.player_data != null:
		SaveManager.player_data.achievement_progress.clear()
		SaveManager.player_data.unlocked_achievements.clear()
		SaveManager.player_data.achievement_unlock_times.clear()
