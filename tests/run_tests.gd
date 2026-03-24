# run_tests.gd - 测试运行脚本
# 运行方式: godot --headless --script res://tests/run_tests.gd
#
# 注意: 需要先安装 GUT 插件
# 下载地址: https://github.com/bitwes/Gut/releases
# 解压到 addons/gut/ 目录

extends SceneTree

func _init() -> void:
	print("=== 禅意军团 单元测试 ===")
	print("")

	# 检查 GUT 是否安装
	if not _check_gut_installed():
		print("错误: GUT 插件未安装")
		print("")
		print("安装步骤:")
		print("1. 从 https://github.com/bitwes/Gut/releases 下载最新版本")
		print("2. 解压到项目的 addons/gut/ 目录")
		print("3. 在 Godot 编辑器中启用 GUT 插件 (Project -> Project Settings -> Plugins)")
		print("")
		print("或者使用独立测试脚本:")
		print("  godot --headless --script res://tests/unit/test_damage_calculator.gd")
		print("  godot --headless --script res://tests/unit/test_target_selector.gd")
		quit(1)
		return

	# 运行 GUT 测试
	var gut = _create_gut_instance()
	if gut:
		gut.run_tests()
		quit(gut.get_summary().get_totals().get_failed())
	else:
		print("错误: 无法创建 GUT 实例")
		quit(1)


func _check_gut_installed() -> bool:
	# 检查 GUT 主要文件是否存在
	return ResourceLoader.exists("res://addons/gut/gut.gd")


func _create_gut_instance():
	var Gut = load("res://addons/gut/gut.gd")
	return Gut.new()
