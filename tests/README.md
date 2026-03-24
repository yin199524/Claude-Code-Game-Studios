# 测试文档

## 测试框架

本项目使用 [GUT (Godot Unit Testing)](https://github.com/bitwes/Gut) 作为单元测试框架。

## 安装 GUT

### 方法 1: 从 GitHub 下载

1. 访问 [GUT Releases](https://github.com/bitwes/Gut/releases)
2. 下载最新版本的 `gut_x.x.x.zip`
3. 解压到项目的 `addons/gut/` 目录
4. 在 Godot 编辑器中: `Project -> Project Settings -> Plugins`
5. 启用 GUT 插件

### 方法 2: 使用 Git Submodule

```bash
git submodule add https://github.com/bitwes/Gut.git addons/gut
```

## 运行测试

### 在 Godot 编辑器中

1. 打开项目
2. 打开 GUT 面板: `Editor -> Editor Settings -> Gut`
3. 点击运行测试按钮

### 命令行运行

```bash
# 运行所有测试
godot --headless -s addons/gut/gut_cmdln.gd

# 运行特定测试文件
godot --headless -s addons/gut/gut_cmdln.gd -gselect=test_damage_calculator_gut.gd

# 运行特定测试方法
godot --headless -s addons/gut/gut_cmdln.gd -gselect=test_basic_damage -ginner_class=
```

### 独立测试脚本（无需 GUT）

如果 GUT 尚未安装，可以使用独立测试脚本：

```bash
godot --headless --script res://tests/unit/test_damage_calculator.gd
godot --headless --script res://tests/unit/test_target_selector.gd
```

## 测试文件说明

| 文件 | 描述 | 类型 |
|------|------|------|
| `test_damage_calculator_gut.gd` | 伤害计算系统测试 | GUT |
| `test_target_selector_gut.gd` | 目标选择 AI 测试 | GUT |
| `test_damage_calculator.gd` | 伤害计算系统测试（独立） | 独立脚本 |
| `test_target_selector.gd` | 目标选择 AI 测试（独立） | 独立脚本 |
| `run_tests.gd` | 测试运行入口 | 启动脚本 |

## 测试覆盖范围

### 伤害计算系统 (`DamageCalculator`)

- ✅ 基础伤害计算
- ✅ 护甲减伤（百分比 + 固定）
- ✅ 克制加成
- ✅ 随机波动范围
- ✅ 边界情况（攻击力为 0、极高护甲）
- ✅ 稀有度加成
- ✅ 伤害预览

### 目标选择 AI (`TargetSelector`)

- ✅ 基础目标选择（最近优先）
- ✅ 攻击范围过滤
- ✅ 距离计算（曼哈顿、欧几里得）
- ✅ 治疗单位特殊逻辑
- ✅ 目标切换规则
- ✅ 边界情况（空列表、全死亡）

## 编写新测试

### GUT 测试模板

```gdscript
# test_example_gut.gd
extends GutTest

var test_subject: MyClass

func before_each() -> void:
	test_subject = MyClass.new()

func after_each() -> void:
	test_subject = null

func test_something() -> void:
	assert_eq(test_subject.method(), expected, "描述")
```

### 独立测试模板

```gdscript
# test_example.gd
extends SceneTree

func _init() -> void:
	print("=== 测试名称 ===")
	test_something()
	print("=== 测试完成 ===")
	quit()

func test_something() -> void:
	# 测试代码
	assert(condition, "描述")

func assert(condition: bool, message: String) -> void:
	if not condition:
		print("  ✗ 失败: " + message)
	else:
		print("  ✓ 通过: " + message)
```

## 参考资料

- [GUT 官方文档](https://github.com/bitwes/Gut/wiki)
- [GUT API 参考](https://github.com/bitwes/Gut/wiki/Asserts)
- [设计文档](../design/gdd/)
