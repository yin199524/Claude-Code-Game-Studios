# SaveManager.gd - 存档管理单例
# 管理: 玩家数据的保存和加载
# 参考: design/gdd/player-data.md

extends Node

## 存档文件路径
const SAVE_PATH: String = "user://save_data.tres"

## 玩家数据
var player_data: PlayerData = null

## 存档变化信号
signal data_changed()

## 加载完成信号
signal data_loaded()


func _ready() -> void:
	load_game()


## 创建新存档
func create_new_save() -> void:
	player_data = PlayerData.create_default()
	data_changed.emit()


## 加载游戏
func load_game() -> bool:
	# 检查存档文件是否存在
	if not FileAccess.file_exists(SAVE_PATH):
		# 创建新存档
		create_new_save()
		data_loaded.emit()
		return true

	# 加载存档
	var loaded = load(SAVE_PATH)
	if loaded is PlayerData:
		player_data = loaded
		# 验证数据
		var result = player_data.validate()
		if not result[0]:
			push_warning("存档数据验证警告: " + result[1])
		# 更新游玩时间
		player_data.update_play_time()
		data_loaded.emit()
		return true
	else:
		# 存档损坏，创建新存档
		push_warning("存档文件损坏，创建新存档")
		create_new_save()
		data_loaded.emit()
		return false


## 保存游戏
func save_game() -> bool:
	if player_data == null:
		return false

	# 更新游玩时间
	player_data.update_play_time()

	var result = ResourceSaver.save(player_data, SAVE_PATH)
	if result == OK:
		return true
	else:
		push_error("保存失败: " + str(result))
		return false


## 添加金币
func add_gold(amount: int) -> void:
	player_data.add_gold(amount)
	data_changed.emit()


## 花费金币
func spend_gold(amount: int) -> bool:
	if player_data.spend_gold(amount):
		data_changed.emit()
		return true
	return false


## 检查是否拥有足够金币
func can_afford(amount: int) -> bool:
	return player_data.can_afford(amount)


## 获取当前金币
func get_gold() -> int:
	return player_data.gold


## 添加单位到拥有列表
func add_unit(unit_id: String, level: int = 1) -> void:
	player_data.add_unit(unit_id, level)
	data_changed.emit()
	save_game()


## 检查是否拥有单位
func has_unit(unit_id: String) -> bool:
	return player_data.has_unit(unit_id)


## 获取单位等级
func get_unit_level(unit_id: String) -> int:
	return player_data.get_unit_level(unit_id)


## 升级单位
func upgrade_unit(unit_id: String) -> bool:
	if player_data.upgrade_unit(unit_id):
		data_changed.emit()
		save_game()
		return true
	return false


## 尝试升级单位（包含金币检查和扣除）
## unit_id: 单位ID
## cost: 升级费用
## 返回: [success: bool, message: String]
func try_upgrade_unit(unit_id: String, cost: int) -> Array:
	# 检查是否拥有该单位
	if not has_unit(unit_id):
		return [false, "未拥有该单位"]

	# 检查等级上限
	var current_level = get_unit_level(unit_id)
	if current_level >= Global.MAX_UNIT_LEVEL:
		return [false, "已达到最高等级"]

	# 检查金币
	if not can_afford(cost):
		return [false, "金币不足"]

	# 扣除金币
	spend_gold(cost)

	# 升级单位
	upgrade_unit(unit_id)

	return [true, "升级成功"]


## 解锁关卡
func unlock_level(level_id: String) -> void:
	player_data.unlock_level(level_id)
	data_changed.emit()
	save_game()


## 完成关卡
func complete_level(level_id: String) -> void:
	player_data.complete_level(level_id)
	data_changed.emit()
	save_game()


## 设置关卡星级
func set_level_stars(level_id: String, stars: int) -> void:
	player_data.set_level_stars(level_id, stars)
	data_changed.emit()
	save_game()


## 获取关卡星级
func get_level_stars(level_id: String) -> int:
	return player_data.get_level_stars(level_id)


## 检查关卡是否解锁
func is_level_unlocked(level_id: String) -> bool:
	return player_data.is_level_unlocked(level_id)


## 检查关卡是否完成
func is_level_completed(level_id: String) -> bool:
	return player_data.is_level_completed(level_id)


## 获取已解锁关卡列表
func get_unlocked_levels() -> Array[String]:
	return player_data.unlocked_levels.duplicate()


## 获取已完成的关卡列表
func get_completed_levels() -> Array[String]:
	return player_data.completed_levels.duplicate()


## 获取拥有的单位列表
func get_owned_units() -> Array[Dictionary]:
	return player_data.owned_units.duplicate()


## 获取拥有单位数量
func get_unit_count() -> int:
	return player_data.get_unit_count()


## 重置存档
func reset_save() -> void:
	player_data.reset()
	data_changed.emit()
	save_game()


## 获取设置
func get_setting(key: String, default: Variant = null) -> Variant:
	if player_data.settings.has(key):
		return player_data.settings[key]
	return default


## 设置
func set_setting(key: String, value: Variant) -> void:
	player_data.settings[key] = value
	data_changed.emit()
	save_game()


## 自动保存（在场景切换时调用）
func auto_save() -> void:
	save_game()
