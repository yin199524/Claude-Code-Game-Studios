# main_menu.gd - 主菜单场景脚本
extends Control

## 背景动画时间
var bg_time: float = 0.0

## 背景装饰节点
var decor_nodes: Array[Node] = []


func _ready() -> void:
	# 连接按钮信号
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

	# 创建背景装饰
	_create_background_decor()


func _process(delta: float) -> void:
	bg_time += delta
	_animate_decor(delta)


## 创建背景装饰
func _create_background_decor() -> void:
	# 创建浮动的光点效果
	for i in range(8):
		var decor = ColorRect.new()
		decor.color = Color(0.3, 0.5, 0.7, 0.08)
		decor.size = Vector2(randf_range(30, 80), randf_range(30, 80))
		decor.position = Vector2(randf_range(0, 720), randf_range(0, 1280))
		decor.rotation = randf_range(0, PI * 2)
		decor.z_index = -1
		add_child(decor)
		decor_nodes.append(decor)


## 动画装饰
func _animate_decor(delta: float) -> void:
	for i in range(decor_nodes.size()):
		var decor = decor_nodes[i]
		# 缓慢飘动
		var speed = 8.0 + i * 3.0
		var offset_y = sin(bg_time * 0.5 + i) * speed * delta
		var offset_x = cos(bg_time * 0.3 + i * 0.7) * speed * 0.5 * delta
		decor.position.y += offset_y
		decor.position.x += offset_x
		decor.rotation += sin(bg_time * 0.2 + i) * 0.005

		# 循环
		if decor.position.y > 1300:
			decor.position.y = -100
		if decor.position.x > 800:
			decor.position.x = -100
		elif decor.position.x < -100:
			decor.position.x = 800


func _on_start_pressed() -> void:
	# 进入关卡选择
	GameManager.enter_level_select()
	SceneTransition.change_scene("res://scenes/level/level_select.tscn")


func _on_settings_pressed() -> void:
	GameManager.enter_settings()


func _on_quit_pressed() -> void:
	get_tree().quit()
