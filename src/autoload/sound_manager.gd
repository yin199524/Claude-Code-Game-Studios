# sound_manager.gd - 音效管理器
# 提供全局音效播放接口
# 当前为占位实现，可替换为真实音频文件

extends Node

## 音效启用状态
var sound_enabled: bool = true

## 音效音量（0.0 - 1.0）
var sound_volume: float = 0.7

## 音效总线名称
const BUS_MASTER = "Master"
const BUS_SFX = "SFX"

## 音效类型枚举
enum SFX {
	BUTTON_CLICK,      ## 按钮点击
	BUTTON_HOVER,      ## 按钮悬停
	PURCHASE_SUCCESS,  ## 购买成功
	PURCHASE_FAIL,     ## 购买失败
	BATTLE_START,      ## 战斗开始
	UNIT_ATTACK,       ## 单位攻击
	UNIT_HIT,          ## 单位受击
	UNIT_DEATH,        ## 单位死亡
	BATTLE_VICTORY,    ## 战斗胜利
	BATTLE_DEFEAT,     ## 战斗失败
	GOLD_GAIN,         ## 获得金币
	LEVEL_UNLOCK,      ## 关卡解锁
}


func _ready() -> void:
	# 初始化音频总线
	_ensure_audio_buses()
	# 加载保存的音量设置
	_load_volume_settings()


## 加载保存的音量设置
func _load_volume_settings() -> void:
	if SaveManager.player_data != null:
		var saved_bgm = SaveManager.get_setting("bgm_volume", 1.0)
		var saved_sfx = SaveManager.get_setting("sfx_volume", 0.7)
		sound_volume = saved_sfx
		set_volume(sound_volume)


## 确保音频总线存在
func _ensure_audio_buses() -> void:
	var bus_idx = AudioServer.get_bus_index(BUS_SFX)
	if bus_idx == -1:
		# SFX 总线不存在，使用 Master
		pass


## 播放音效
func play_sfx(sfx_type: SFX) -> void:
	if not sound_enabled:
		return

	var sfx_name = _get_sfx_name(sfx_type)
	var audio_path = "res://assets/audio/sfx/%s.wav" % sfx_name

	# 检查音频文件是否存在
	if not ResourceLoader.exists(audio_path):
		# 音频文件不存在，使用占位实现
		print("[SFX] %s (placeholder)" % sfx_name)
		return

	# 加载并播放音频
	var player = AudioStreamPlayer.new()
	player.stream = load(audio_path)
	player.volume_db = linear_to_db(sound_volume)
	player.bus = BUS_SFX
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)


## 获取音效名称
func _get_sfx_name(sfx_type: SFX) -> String:
	match sfx_type:
		SFX.BUTTON_CLICK:
			return "button_click"
		SFX.BUTTON_HOVER:
			return "button_hover"
		SFX.PURCHASE_SUCCESS:
			return "purchase_success"
		SFX.PURCHASE_FAIL:
			return "purchase_fail"
		SFX.BATTLE_START:
			return "battle_start"
		SFX.UNIT_ATTACK:
			return "unit_attack"
		SFX.UNIT_HIT:
			return "unit_hit"
		SFX.UNIT_DEATH:
			return "unit_death"
		SFX.BATTLE_VICTORY:
			return "battle_victory"
		SFX.BATTLE_DEFEAT:
			return "battle_defeat"
		SFX.GOLD_GAIN:
			return "gold_gain"
		SFX.LEVEL_UNLOCK:
			return "level_unlock"
	return "unknown"


## 切换音效开关
func toggle_sound() -> void:
	sound_enabled = not sound_enabled
	print("[SFX] Sound %s" % ("enabled" if sound_enabled else "disabled"))


## 设置音量
func set_volume(volume: float) -> void:
	sound_volume = clampf(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(BUS_MASTER)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sound_volume))


## 预加载音效（优化性能）
func preload_sfx(sfx_types: Array[SFX]) -> void:
	# 占位实现
	for sfx_type in sfx_types:
		var sfx_name = _get_sfx_name(sfx_type)
		print("[SFX] Preloading: %s" % sfx_name)
