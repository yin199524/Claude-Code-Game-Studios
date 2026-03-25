# DailyMissionManager.gd - 每日任务管理器单例
# 管理: 每日任务的刷新、进度追踪和奖励发放
# 参考: design/gdd/daily-mission-system.md

extends Node

## 每日任务数量
const DAILY_MISSION_COUNT: int = 3

## 任务定义池 {mission_id: DailyMissionDefinition}
var _mission_pool: Dictionary = {}

## 当前激活的任务列表 [DailyMissionDefinition]
var _active_missions: Array[DailyMissionDefinition] = []

## 任务进度缓存 {mission_id: current_value}
var _progress_cache: Dictionary = {}

## 已完成（未领取）的任务
var _completed_missions: Array[String] = []

## 已领取奖励的任务
var _claimed_missions: Array[String] = []

## 上次刷新时间 (Unix timestamp)
var _last_refresh_time: int = 0

## 加载完成信号
signal missions_loaded()

## 任务刷新信号
signal missions_refreshed()

## 任务完成信号
signal mission_completed(mission_id: String)

## 奖励领取信号
signal reward_claimed(mission_id: String, gold: int)

## 任务进度更新信号
signal mission_progress_updated(mission_id: String, current: int, target: int)

## 是否已加载
var is_loaded: bool = false


func _ready() -> void:
	load_missions()


## 加载任务系统
func load_missions() -> void:
	_mission_pool.clear()
	_create_mission_pool()
	_load_state_from_save()
	_check_and_refresh()
	is_loaded = true
	missions_loaded.emit()


## 创建任务池
func _create_mission_pool() -> void:
	# 胜利者 - 通关 3 关
	var dm_win_3 = DailyMissionDefinition.new()
	dm_win_3.id = "dm_win_3"
	dm_win_3.display_name = "胜利者"
	dm_win_3.description = "通关 3 关"
	dm_win_3.mission_type = Global.DailyMissionType.WIN_LEVELS
	dm_win_3.target_value = 3
	dm_win_3.reward_gold = 100
	_mission_pool[dm_win_3.id] = dm_win_3

	# 强化部队 - 升级 1 个单位
	var dm_upgrade_1 = DailyMissionDefinition.new()
	dm_upgrade_1.id = "dm_upgrade_1"
	dm_upgrade_1.display_name = "强化部队"
	dm_upgrade_1.description = "升级 1 个单位"
	dm_upgrade_1.mission_type = Global.DailyMissionType.UPGRADE_UNITS
	dm_upgrade_1.target_value = 1
	dm_upgrade_1.reward_gold = 50
	_mission_pool[dm_upgrade_1.id] = dm_upgrade_1

	# 招募新兵 - 购买 1 个单位
	var dm_buy_unit = DailyMissionDefinition.new()
	dm_buy_unit.id = "dm_buy_unit"
	dm_buy_unit.display_name = "招募新兵"
	dm_buy_unit.description = "购买 1 个单位"
	dm_buy_unit.mission_type = Global.DailyMissionType.BUY_UNITS
	dm_buy_unit.target_value = 1
	dm_buy_unit.reward_gold = 50
	_mission_pool[dm_buy_unit.id] = dm_buy_unit

	# 清剿敌人 - 击败 20 个敌人
	var dm_defeat_20 = DailyMissionDefinition.new()
	dm_defeat_20.id = "dm_defeat_20"
	dm_defeat_20.display_name = "清剿敌人"
	dm_defeat_20.description = "击败 20 个敌人"
	dm_defeat_20.mission_type = Global.DailyMissionType.DEFEAT_ENEMIES
	dm_defeat_20.target_value = 20
	dm_defeat_20.reward_gold = 80
	_mission_pool[dm_defeat_20.id] = dm_defeat_20

	# 战术大师 - 触发协同效果 3 次
	var dm_use_synergy = DailyMissionDefinition.new()
	dm_use_synergy.id = "dm_use_synergy"
	dm_use_synergy.display_name = "战术大师"
	dm_use_synergy.description = "触发协同效果 3 次"
	dm_use_synergy.mission_type = Global.DailyMissionType.TRIGGER_SYNERGY
	dm_use_synergy.target_value = 3
	dm_use_synergy.reward_gold = 100
	_mission_pool[dm_use_synergy.id] = dm_use_synergy


## 从存档加载状态
func _load_state_from_save() -> void:
	if SaveManager.player_data == null:
		return

	var daily_data = SaveManager.player_data.daily_mission_data
	_active_missions.clear()
	_progress_cache.clear()
	_completed_missions.clear()
	_claimed_missions.clear()

	# 加载激活的任务
	var active_ids = daily_data.get("active_mission_ids", [])
	for mission_id in active_ids:
		if _mission_pool.has(mission_id):
			_active_missions.append(_mission_pool[mission_id])

	# 加载进度
	_progress_cache = daily_data.get("progress", {}).duplicate()

	# 加载已完成和已领取
	_completed_missions = daily_data.get("completed", []).duplicate()
	_claimed_missions = daily_data.get("claimed", []).duplicate()

	# 加载刷新时间
	_last_refresh_time = daily_data.get("last_refresh_time", 0)


## 保存状态到存档
func _save_state_to_save() -> void:
	if SaveManager.player_data == null:
		return

	var active_ids: Array[String] = []
	for mission in _active_missions:
		active_ids.append(mission.id)

	SaveManager.player_data.daily_mission_data = {
		"active_mission_ids": active_ids,
		"progress": _progress_cache.duplicate(),
		"completed": _completed_missions.duplicate(),
		"claimed": _claimed_missions.duplicate(),
		"last_refresh_time": _last_refresh_time
	}
	SaveManager.save_game()


## 检查并刷新任务
func _check_and_refresh() -> void:
	if _should_refresh():
		_refresh_missions()


## 判断是否需要刷新
func _should_refresh() -> bool:
	if _last_refresh_time == 0:
		return true

	var last_date = Time.get_date_dict_from_unix_time(_last_refresh_time)
	var current_date = Time.get_date_dict_from_unix_time(int(Time.get_unix_time_from_system()))

	return last_date.year != current_date.year or \
	       last_date.month != current_date.month or \
	       last_date.day != current_date.day


## 刷新任务
func _refresh_missions() -> void:
	# 清空旧数据
	_active_missions.clear()
	_progress_cache.clear()
	_completed_missions.clear()
	_claimed_missions.clear()

	# 从任务池随机选择任务
	var pool_ids = _mission_pool.keys()
	pool_ids.shuffle()

	for i in range(mini(DAILY_MISSION_COUNT, pool_ids.size())):
		var mission_id = pool_ids[i]
		_active_missions.append(_mission_pool[mission_id])
		_progress_cache[mission_id] = 0

	# 更新刷新时间
	_last_refresh_time = int(Time.get_unix_time_from_system())

	# 保存
	_save_state_to_save()

	# 发送刷新信号
	missions_refreshed.emit()


## 获取当前激活的任务
func get_active_missions() -> Array[DailyMissionDefinition]:
	return _active_missions.duplicate()


## 获取任务进度
func get_progress(mission_id: String) -> int:
	return _progress_cache.get(mission_id, 0)


## 检查任务是否已完成（未领取）
func is_mission_completed(mission_id: String) -> bool:
	return mission_id in _completed_missions


## 检查任务是否已领取奖励
func is_mission_claimed(mission_id: String) -> bool:
	return mission_id in _claimed_missions


## 触发事件（由各游戏系统调用）
func trigger_event(event_type: int, count: int = 1) -> void:
	for mission in _active_missions:
		# 跳过已完成的任务
		if is_mission_completed(mission.id) or is_mission_claimed(mission.id):
			continue

		# 检查事件类型是否匹配
		if mission.mission_type != event_type:
			continue

		# 更新进度
		_update_progress(mission.id, count)


## 更新任务进度
func _update_progress(mission_id: String, increment: int) -> void:
	var mission = _mission_pool.get(mission_id)
	if mission == null:
		return

	var current = _progress_cache.get(mission_id, 0)
	var new_value = current + increment

	_progress_cache[mission_id] = new_value

	# 发送进度更新信号
	mission_progress_updated.emit(mission_id, new_value, mission.target_value)

	# 检查是否完成
	if mission.is_completed(new_value) and not is_mission_completed(mission_id):
		_completed_missions.append(mission_id)
		mission_completed.emit(mission_id)

	# 保存
	_save_state_to_save()


## 领取奖励
func claim_reward(mission_id: String) -> bool:
	# 检查是否已完成且未领取
	if not is_mission_completed(mission_id):
		return false

	if is_mission_claimed(mission_id):
		return false

	var mission = _mission_pool.get(mission_id)
	if mission == null:
		return false

	# 发放奖励
	SaveManager.add_gold(mission.reward_gold)

	# 标记为已领取
	_completed_missions.erase(mission_id)
	_claimed_missions.append(mission_id)

	# 保存
	_save_state_to_save()

	# 发送领取信号
	reward_claimed.emit(mission_id, mission.reward_gold)

	return true


## 获取可领取的任务数量
func get_claimable_count() -> int:
	return _completed_missions.size()


## 获取距离下次刷新的时间（秒）
func get_time_until_refresh() -> int:
	var current_time = int(Time.get_unix_time_from_system())
	var current_date = Time.get_datetime_dict_from_unix_time(current_time)

	# 计算今天结束的时间（明天 0 点）
	var tomorrow = current_date.duplicate()
	tomorrow["day"] += 1
	# 处理月份边界
	var tomorrow_time = Time.get_unix_time_from_datetime_dict(tomorrow)

	return tomorrow_time - current_time


## 手动刷新（用于测试）
func force_refresh() -> void:
	_refresh_missions()
