# TutorialManager.gd - 引导管理器
# 管理游戏内所有引导流程，包括欢迎引导、商店引导、战斗引导等
# 参考: design/gdd/tutorial-system.md

extends Node

## 信号

## 引导开始
signal tutorial_started(tutorial_id: String)
## 引导步骤变化
signal tutorial_step_changed(tutorial_id: String, step: int)
## 引导完成
signal tutorial_completed(tutorial_id: String)
## 显示提示
signal show_hint(message: String, highlight_path: NodePath)
## 隐藏提示
signal hide_hint()

## 常量

## 引导 ID 枚举
enum TutorialID {
	WELCOME,     ## 欢迎引导
	SHOP,        ## 商店引导
	BATTLE,      ## 战斗引导
	COUNTER,     ## 克制提示
	SYNERGY,     ## 协同提示
}

## 引导步骤定义
const TUTORIAL_STEPS: Dictionary = {
	TutorialID.WELCOME: [
		{
			"message": "欢迎来到禅意军团！\n你将成为一位指挥官，带领你的部队征服五大世界。",
			"highlight": "",
		},
		{
			"message": "你的目标：组建强大的队伍，\n击败敌人，征服所有世界！",
			"highlight": "",
		},
		{
			"message": "准备好了吗？让我们开始吧！",
			"highlight": "",
		},
	],
	TutorialID.SHOP: [
		{
			"message": "这是商店，你可以在这里招募新的单位。",
			"highlight": "shop_button",
		},
		{
			"message": "每个单位有不同的职业和技能。\n点击查看详情。",
			"highlight": "unit_card",
		},
		{
			"message": "选择你想要的单位，点击购买。",
			"highlight": "buy_button",
		},
		{
			"message": "确认购买后，单位将加入你的队伍。",
			"highlight": "confirm_button",
		},
	],
	TutorialID.BATTLE: [
		{
			"message": "选择一个单位准备放置到战场。",
			"highlight": "unit_list",
		},
		{
			"message": "点击网格放置单位。\n注意：单位只能放在下方区域。",
			"highlight": "grid_area",
		},
		{
			"message": "放置完成后，点击开始战斗！",
			"highlight": "start_button",
		},
		{
			"message": "战斗自动进行，观察你的单位与敌人战斗。",
			"highlight": "",
		},
		{
			"message": "恭喜胜利！获得金币奖励。\n继续挑战更多关卡！",
			"highlight": "reward_panel",
		},
	],
	TutorialID.COUNTER: [
		{
			"message": "克制！你的单位对目标有优势！\n伤害 +50%",
			"highlight": "",
		},
	],
	TutorialID.SYNERGY: [
		{
			"message": "协同效果触发！\n特定单位组合获得额外加成！",
			"highlight": "",
		},
	],
}

## 最大提示重复次数
const MAX_HINT_REPEAT: int = 3

## 变量

## 当前引导 ID
var current_tutorial: TutorialID = TutorialID.WELCOME

## 当前步骤
var current_step: int = 0

## 是否正在引导中
var is_active: bool = false

## 引导队列
var _tutorial_queue: Array[TutorialID] = []


## 公共方法

## 检查是否应该显示引导
func should_show_tutorial(tutorial_id: TutorialID) -> bool:
	var player_data = SaveManager.player_data
	if player_data == null:
		return false

	# 检查是否已启用引导
	if not player_data.settings.get("tutorial_enabled", true):
		return false

	# 检查是否已完成
	if TutorialID.keys()[tutorial_id] in player_data.completed_tutorials:
		return false

	# 检查触发条件
	match tutorial_id:
		TutorialID.WELCOME:
			return player_data.is_first_launch
		TutorialID.SHOP:
			return player_data.is_first_shop_visit
		TutorialID.BATTLE:
			return player_data.is_first_battle
		TutorialID.COUNTER:
			return player_data.counter_hint_count < MAX_HINT_REPEAT
		TutorialID.SYNERGY:
			return player_data.synergy_hint_count < MAX_HINT_REPEAT

	return false


## 开始引导
func start_tutorial(tutorial_id: TutorialID) -> void:
	if is_active:
		# 添加到队列
		if tutorial_id not in _tutorial_queue:
			_tutorial_queue.append(tutorial_id)
		return

	if not should_show_tutorial(tutorial_id):
		return

	current_tutorial = tutorial_id
	current_step = _get_saved_step(tutorial_id)
	is_active = true

	tutorial_started.emit(TutorialID.keys()[tutorial_id])
	_show_current_step()


## 推进到下一步
func advance_step() -> void:
	if not is_active:
		return

	var steps = TUTORIAL_STEPS.get(current_tutorial, [])
	current_step += 1

	# 保存进度
	_save_progress()

	if current_step >= steps.size():
		# 引导完成
		complete_tutorial()
	else:
		tutorial_step_changed.emit(TutorialID.keys()[current_tutorial], current_step)
		_show_current_step()


## 跳过当前引导
func skip_tutorial() -> void:
	if not is_active:
		return

	complete_tutorial()


## 完成当前引导
func complete_tutorial() -> void:
	var tutorial_name = TutorialID.keys()[current_tutorial]

	# 标记完成
	var player_data = SaveManager.player_data
	if player_data != null:
		if tutorial_name not in player_data.completed_tutorials:
			player_data.completed_tutorials.append(tutorial_name)
		player_data.tutorial_progress.erase(tutorial_name)

		# 更新首次标记
		match current_tutorial:
			TutorialID.WELCOME:
				player_data.is_first_launch = false
			TutorialID.SHOP:
				player_data.is_first_shop_visit = false
			TutorialID.BATTLE:
				player_data.is_first_battle = false

		SaveManager.save_game()

	hide_hint.emit()
	tutorial_completed.emit(tutorial_name)

	is_active = false
	current_step = 0

	# 处理队列中的下一个引导
	if _tutorial_queue.size() > 0:
		var next_tutorial = _tutorial_queue.pop_front()
		start_tutorial(next_tutorial)


## 重置所有引导（用于设置）
func reset_all_tutorials() -> void:
	var player_data = SaveManager.player_data
	if player_data == null:
		return

	player_data.completed_tutorials = []
	player_data.tutorial_progress = {}
	player_data.is_first_launch = true
	player_data.is_first_shop_visit = true
	player_data.is_first_battle = true
	player_data.counter_hint_count = 0
	player_data.synergy_hint_count = 0

	SaveManager.save_game()


## 显示克制提示
func show_counter_hint() -> void:
	if not should_show_tutorial(TutorialID.COUNTER):
		return

	var player_data = SaveManager.player_data
	if player_data != null:
		player_data.counter_hint_count += 1
		SaveManager.save_game()

	# 短暂显示提示
	var step_data = TUTORIAL_STEPS[TutorialID.COUNTER][0]
	show_hint.emit(step_data.message, NodePath(""))

	# 3秒后自动隐藏
	await get_tree().create_timer(3.0).timeout
	hide_hint.emit()


## 显示协同提示
func show_synergy_hint(synergy_name: String) -> void:
	if not should_show_tutorial(TutorialID.SYNERGY):
		return

	var player_data = SaveManager.player_data
	if player_data != null:
		player_data.synergy_hint_count += 1
		SaveManager.save_game()

	var step_data = TUTORIAL_STEPS[TutorialID.SYNERGY][0]
	var message = step_data.message + "\n[%s]" % synergy_name
	show_hint.emit(message, NodePath(""))

	# 3秒后自动隐藏
	await get_tree().create_timer(3.0).timeout
	hide_hint.emit()


## 获取当前步骤数据
func get_current_step_data() -> Dictionary:
	var steps = TUTORIAL_STEPS.get(current_tutorial, [])
	if current_step >= 0 and current_step < steps.size():
		return steps[current_step]
	return {}


## 获取当前步骤消息
func get_current_message() -> String:
	var step_data = get_current_step_data()
	return step_data.get("message", "")


## 获取当前高亮节点路径
func get_current_highlight() -> NodePath:
	var step_data = get_current_step_data()
	var path = step_data.get("highlight", "")
	return NodePath(path)


## 私有方法

## 获取保存的步骤
func _get_saved_step(tutorial_id: TutorialID) -> int:
	var player_data = SaveManager.player_data
	if player_data == null:
		return 0

	var tutorial_name = TutorialID.keys()[tutorial_id]
	return player_data.tutorial_progress.get(tutorial_name, 0)


## 保存进度
func _save_progress() -> void:
	var player_data = SaveManager.player_data
	if player_data == null:
		return

	var tutorial_name = TutorialID.keys()[current_tutorial]
	player_data.tutorial_progress[tutorial_name] = current_step
	SaveManager.save_game()


## 显示当前步骤
func _show_current_step() -> void:
	var step_data = get_current_step_data()
	var message = step_data.get("message", "")
	var highlight = step_data.get("highlight", "")
	show_hint.emit(message, NodePath(highlight))


## 生命周期

func _ready() -> void:
	# 连接存档加载完成信号
	SaveManager.data_loaded.connect(_on_data_loaded)


func _on_data_loaded() -> void:
	# 检查是否需要显示欢迎引导
	if should_show_tutorial(TutorialID.WELCOME):
		start_tutorial(TutorialID.WELCOME)
