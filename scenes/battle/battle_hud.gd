# battle_hud.gd - 战斗 HUD 脚本
# 管理战斗界面的 UI 元素

extends CanvasLayer

## 回合更新信号
signal turn_updated(turn: int)

## 暂停按钮信号
signal pause_toggled()

## 速度切换信号
signal speed_changed(speed: float)

## 继续按钮信号
signal continue_pressed()


func _ready() -> void:
	pass


## 更新回合计数
func update_turn(turn: int) -> void:
	var label = get_node_or_null("TopBar/HBoxContainer/TurnLabel")
	if label:
		label.text = "回合: %d" % turn


## 更新暂停按钮文本
func update_pause_button(is_paused: bool) -> void:
	var btn = get_node_or_null("TopBar/HBoxContainer/PauseButton")
	if btn:
		btn.text = "▶ 继续" if is_paused else "⏸ 暂停"


## 更新速度按钮文本
func update_speed_button(speed: float) -> void:
	var btn = get_node_or_null("TopBar/HBoxContainer/SpeedButton")
	if btn:
		btn.text = "%dx" % int(speed)


## 显示战斗结果
func show_result(victory: bool, rewards: Dictionary) -> void:
	var panel = get_node_or_null("ResultPanel")
	if not panel:
		return

	var result_label = panel.get_node_or_null("VBoxContainer/ResultLabel")
	var reward_label = panel.get_node_or_null("VBoxContainer/RewardLabel")

	if result_label:
		result_label.text = "战斗胜利!" if victory else "战斗失败..."

	if reward_label:
		if victory:
			reward_label.text = "获得金币: %d" % rewards.get("gold", 0)
		else:
			reward_label.text = "再接再厉!"

	panel.visible = true


## 隐藏战斗结果
func hide_result() -> void:
	var panel = get_node_or_null("ResultPanel")
	if panel:
		panel.visible = false
