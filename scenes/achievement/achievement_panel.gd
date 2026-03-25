# achievement_panel.gd - 成就面板场景脚本
# 显示所有成就及其进度

extends Control

## 分类按钮组
var category_buttons: Array[Button] = []

## 当前选中的分类
var current_category: int = -1  # -1 表示全部

## 成就列表容器
var achievement_list: VBoxContainer = null

## 滚动容器
var scroll_container: ScrollContainer = null


func _ready() -> void:
	_setup_ui()
	_connect_signals()
	_populate_achievements()


func _setup_ui() -> void:
	# 背景
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0.12, 0.14, 0.18, 1)
	bg.anchors_preset = Control.PRESET_FULL_RECT
	add_child(bg)

	# 主容器
	var main_vbox = VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.anchors_preset = Control.PRESET_FULL_RECT
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)

	# 顶部栏
	var header = _create_header()
	main_vbox.add_child(header)

	# 分类标签栏
	var category_bar = _create_category_bar()
	main_vbox.add_child(category_bar)

	# 进度统计
	var stats_bar = _create_stats_bar()
	main_vbox.add_child(stats_bar)

	# 滚动容器
	scroll_container = ScrollContainer.new()
	scroll_container.name = "ScrollContainer"
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	main_vbox.add_child(scroll_container)

	# 成就列表
	achievement_list = VBoxContainer.new()
	achievement_list.name = "AchievementList"
	achievement_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	achievement_list.add_theme_constant_override("separation", 8)
	scroll_container.add_child(achievement_list)


func _create_header() -> Control:
	var header = PanelContainer.new()
	header.name = "Header"
	header.custom_minimum_size.y = 60

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.18, 0.25, 1)
	style.border_color = Color(0.25, 0.3, 0.4, 1)
	style.set_border_width_all(0)
	style.border_width_bottom = 2
	header.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	header.add_child(hbox)

	# 返回按钮
	var back_button = Button.new()
	back_button.text = "← 返回"
	back_button.custom_minimum_size.x = 80
	back_button.pressed.connect(_on_back_pressed)
	hbox.add_child(back_button)

	# 标题
	var title = Label.new()
	title.text = "🏆 成就"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7, 1))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(title)

	# 占位
	var spacer = Control.new()
	spacer.custom_minimum_size.x = 80
	hbox.add_child(spacer)

	return header


func _create_category_bar() -> Control:
	var bar = HBoxContainer.new()
	bar.name = "CategoryBar"
	bar.custom_minimum_size.y = 44
	bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bar.add_theme_constant_override("separation", 8)

	# 添加左右边距
	var left_spacer = Control.new()
	left_spacer.custom_minimum_size.x = 10
	bar.add_child(left_spacer)

	# 全部按钮
	var all_btn = _create_category_button("全部", -1)
	bar.add_child(all_btn)
	category_buttons.append(all_btn)

	# 各分类按钮
	var categories = ["进度", "收集", "战斗", "升级", "协同"]
	for i in range(categories.size()):
		var btn = _create_category_button(categories[i], i)
		bar.add_child(btn)
		category_buttons.append(btn)

	var right_spacer = Control.new()
	right_spacer.custom_minimum_size.x = 10
	bar.add_child(right_spacer)

	return bar


func _create_category_button(text: String, category: int) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.toggle_mode = true
	btn.custom_minimum_size = Vector2(60, 32)
	btn.button_group = _get_or_create_button_group()
	btn.pressed.connect(_on_category_pressed.bind(category))

	if category == -1:
		btn.button_pressed = true

	return btn


var _button_group: ButtonGroup = null

func _get_or_create_button_group() -> ButtonGroup:
	if _button_group == null:
		_button_group = ButtonGroup.new()
	return _button_group


func _create_stats_bar() -> Control:
	var bar = PanelContainer.new()
	bar.name = "StatsBar"
	bar.custom_minimum_size.y = 40

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.16, 1)
	bar.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 20)
	bar.add_child(hbox)

	var unlocked = AchievementManager.get_unlocked_count()
	var total = AchievementManager.get_total_count()
	var rate = AchievementManager.get_completion_rate() * 100

	var progress_label = Label.new()
	progress_label.text = "已解锁: %d / %d" % [unlocked, total]
	progress_label.add_theme_font_size_override("font_size", 14)
	progress_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8, 1))
	hbox.add_child(progress_label)

	var rate_label = Label.new()
	rate_label.text = "(%.1f%%)" % rate
	rate_label.add_theme_font_size_override("font_size", 14)
	rate_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	hbox.add_child(rate_label)

	return bar


func _connect_signals() -> void:
	# 监听成就解锁事件
	AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)
	AchievementManager.achievement_progress_updated.connect(_on_progress_updated)


func _populate_achievements() -> void:
	# 清空列表
	for child in achievement_list.get_children():
		child.queue_free()

	await get_tree().process_frame

	# 获取成就列表
	var achievements: Array[AchievementDefinition]
	if current_category == -1:
		achievements = AchievementManager.get_all_achievements()
	else:
		achievements = AchievementManager.get_achievements_by_category(current_category)

	# 创建成就项
	for achievement in achievements:
		var item = _create_achievement_item(achievement)
		achievement_list.add_child(item)


func _create_achievement_item(achievement: AchievementDefinition) -> Control:
	var is_unlocked = AchievementManager.is_achievement_unlocked(achievement.id)
	var progress = AchievementManager.get_progress(achievement.id)

	var panel = PanelContainer.new()
	panel.custom_minimum_size.y = 90

	var style = StyleBoxFlat.new()
	if is_unlocked:
		style.bg_color = Color(0.15, 0.2, 0.18, 1)
		style.border_color = Color(0.3, 0.7, 0.4, 1)
	else:
		style.bg_color = Color(0.15, 0.18, 0.22, 1)
		style.border_color = Color(0.3, 0.35, 0.45, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)

	# 左侧：图标
	var icon_container = PanelContainer.new()
	icon_container.custom_minimum_size = Vector2(70, 70)
	var icon_style = StyleBoxFlat.new()
	if is_unlocked:
		icon_style.bg_color = Color(0.2, 0.5, 0.3, 1)
	else:
		icon_style.bg_color = Color(0.2, 0.22, 0.28, 1)
	icon_style.set_corner_radius_all(8)
	icon_container.add_theme_stylebox_override("panel", icon_style)
	hbox.add_child(icon_container)

	var icon_label = Label.new()
	icon_label.text = _get_category_icon(achievement.category)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 32)
	icon_container.add_child(icon_label)

	# 中间：信息
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	hbox.add_child(info)

	# 名称
	var name_label = Label.new()
	name_label.text = achievement.display_name
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1) if is_unlocked else Color(0.6, 0.65, 0.7, 1))
	info.add_child(name_label)

	# 描述
	var desc_label = Label.new()
	desc_label.text = achievement.description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7, 1))
	info.add_child(desc_label)

	# 进度条
	if not is_unlocked and achievement.target_value > 1:
		var progress_bar = ProgressBar.new()
		progress_bar.max_value = achievement.target_value
		progress_bar.value = progress
		progress_bar.custom_minimum_size.y = 12
		progress_bar.show_percentage = false
		info.add_child(progress_bar)

		var progress_text = Label.new()
		progress_text.text = achievement.get_progress_text(progress)
		progress_text.add_theme_font_size_override("font_size", 10)
		progress_text.add_theme_color_override("font_color", Color(0.5, 0.55, 0.6, 1))
		info.add_child(progress_text)

	# 右侧：奖励
	var reward_container = VBoxContainer.new()
	reward_container.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_container.custom_minimum_size.x = 80
	hbox.add_child(reward_container)

	var reward_icon = Label.new()
	reward_icon.text = "🪙"
	reward_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_icon.add_theme_font_size_override("font_size", 20)
	reward_container.add_child(reward_icon)

	var reward_label = Label.new()
	reward_label.text = "%d" % achievement.reward_gold
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_label.add_theme_font_size_override("font_size", 16)
	if is_unlocked:
		reward_label.add_theme_color_override("font_color", Color(0.5, 0.55, 0.5, 1))
		reward_label.text = "已领取"
	else:
		reward_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	reward_container.add_child(reward_label)

	return panel


func _get_category_icon(category: int) -> String:
	match category:
		Global.AchievementCategory.PROGRESS:
			return "🗺"
		Global.AchievementCategory.COLLECTION:
			return "📦"
		Global.AchievementCategory.COMBAT:
			return "⚔"
		Global.AchievementCategory.UPGRADE:
			return "⬆"
		Global.AchievementCategory.SYNERGY:
			return "🔗"
		Global.AchievementCategory.SPECIAL:
			return "⭐"
	return "🏆"


func _on_category_pressed(category: int) -> void:
	current_category = category
	_populate_achievements()


func _on_back_pressed() -> void:
	SoundManager.play_sfx(SoundManager.SFX.BUTTON_CLICK)
	SceneTransition.change_scene("res://scenes/main_menu.tscn")


func _on_achievement_unlocked(achievement_id: String, _achievement: AchievementDefinition) -> void:
	_populate_achievements()


func _on_progress_updated(_achievement_id: String, _current: int, _target: int) -> void:
	# 可以选择只更新特定项目，而不是全部刷新
	_populate_achievements()
