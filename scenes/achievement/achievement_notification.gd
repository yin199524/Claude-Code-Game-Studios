# achievement_notification.gd - 成就解锁通知弹窗
# 显示成就解锁动画和奖励

extends Control

## 显示时长（秒）
const DISPLAY_DURATION: float = 3.0

## 动画时长
const ANIM_DURATION: float = 0.5

## 当前显示的成就
var current_achievement: AchievementDefinition = null

## 计时器
var display_timer: float = 0.0

## 是否正在显示
var is_showing: bool = false

## 主面板
var panel: PanelContainer = null


func _ready() -> void:
	_setup_ui()
	_connect_signals()
	hide()


func _setup_ui() -> void:
	# 设置锚点：顶部居中
	anchors_preset = Control.PRESET_CENTER_TOP
	offset_top = -100
	offset_left = -200
	offset_right = 200
	offset_bottom = -20

	# 主面板
	panel = PanelContainer.new()
	panel.anchors_preset = Control.PRESET_FULL_RECT
	add_child(panel)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.18, 0.14, 0.95)
	style.border_color = Color(0.4, 0.8, 0.5, 1)
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 4)
	panel.add_theme_stylebox_override("panel", style)

	# 内容容器
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	panel.add_child(hbox)

	# 左侧边距
	var left_padding = Control.new()
	left_padding.custom_minimum_size.x = 10
	hbox.add_child(left_padding)

	# 图标
	var icon_container = PanelContainer.new()
	icon_container.custom_minimum_size = Vector2(50, 50)
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = Color(0.2, 0.5, 0.3, 1)
	icon_style.set_corner_radius_all(8)
	icon_container.add_theme_stylebox_override("panel", icon_style)
	hbox.add_child(icon_container)

	var icon_label = Label.new()
	icon_label.name = "IconLabel"
	icon_label.text = "🏆"
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 28)
	icon_container.add_child(icon_label)

	# 中间：标题和描述
	var info = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	hbox.add_child(info)

	var title_row = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	info.add_child(title_row)

	var unlock_label = Label.new()
	unlock_label.text = "成就解锁！"
	unlock_label.add_theme_font_size_override("font_size", 12)
	unlock_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.5, 1))
	title_row.add_child(unlock_label)

	var name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = ""
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95, 1))
	title_row.add_child(name_label)

	var desc_label = Label.new()
	desc_label.name = "DescLabel"
	desc_label.text = ""
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7, 1))
	info.add_child(desc_label)

	# 右侧：奖励
	var reward_container = HBoxContainer.new()
	reward_container.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_container.custom_minimum_size.x = 80
	hbox.add_child(reward_container)

	var gold_icon = Label.new()
	gold_icon.text = "🪙"
	gold_icon.add_theme_font_size_override("font_size", 20)
	reward_container.add_child(gold_icon)

	var reward_label = Label.new()
	reward_label.name = "RewardLabel"
	reward_label.text = "+0"
	reward_label.add_theme_font_size_override("font_size", 16)
	reward_label.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	reward_container.add_child(reward_label)

	# 右侧边距
	var right_padding = Control.new()
	right_padding.custom_minimum_size.x = 10
	hbox.add_child(right_padding)


func _connect_signals() -> void:
	AchievementManager.achievement_unlocked.connect(_on_achievement_unlocked)


func _process(delta: float) -> void:
	if is_showing:
		display_timer -= delta
		if display_timer <= 0:
			_hide_notification()


func show_notification(achievement: AchievementDefinition) -> void:
	if is_showing:
		# 如果正在显示，先隐藏
		_hide_notification()
		await get_tree().create_timer(0.3).timeout

	current_achievement = achievement
	_update_content()

	# 播放音效
	SoundManager.play_sfx(SoundManager.SFX.ACHIEVEMENT_UNLOCK if SoundManager.SFX.has("ACHIEVEMENT_UNLOCK") else SoundManager.SFX.PURCHASE_SUCCESS)

	# 显示动画
	is_showing = true
	display_timer = DISPLAY_DURATION
	show()

	# 从顶部滑入
	modulate.a = 0
	position.y = -120

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, ANIM_DURATION)
	tween.tween_property(self, "position:y", 20, ANIM_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _hide_notification() -> void:
	is_showing = false

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, ANIM_DURATION * 0.5)
	tween.tween_property(self, "position:y", -120, ANIM_DURATION * 0.5)

	await tween.finished
	hide()


func _update_content() -> void:
	if current_achievement == null:
		return

	var icon_label = panel.get_node("IconLabel") as Label
	if icon_label:
		icon_label.text = _get_category_icon(current_achievement.category)

	var name_label = panel.get_node("NameLabel") as Label
	if name_label:
		name_label.text = current_achievement.display_name

	var desc_label = panel.get_node("DescLabel") as Label
	if desc_label:
		desc_label.text = current_achievement.description

	var reward_label = panel.get_node("RewardLabel") as Label
	if reward_label:
		reward_label.text = "+%d" % current_achievement.reward_gold


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


func _on_achievement_unlocked(_achievement_id: String, achievement: AchievementDefinition) -> void:
	show_notification(achievement)
