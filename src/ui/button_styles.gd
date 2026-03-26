# button_styles.gd - 统一按钮样式管理
# 提供一致的按钮样式，确保 UI 一致性

class_name ButtonStyles
extends RefCounted

## 按钮类型枚举
enum ButtonType {
	PRIMARY,    ## 主要按钮（蓝色调）
	SECONDARY,  ## 次要按钮（灰色调）
	DANGER,     ## 危险按钮（红色调）
	SUCCESS,    ## 成功按钮（绿色调）
	DISABLED    ## 禁用状态
}

## 样式缓存
static var _style_cache: Dictionary = {}


## 获取普通状态样式
static func get_normal_style(button_type: ButtonType = ButtonType.SECONDARY) -> StyleBoxFlat:
	var cache_key = "normal_%d" % button_type
	if _style_cache.has(cache_key):
		return _style_cache[cache_key]

	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)

	match button_type:
		ButtonType.PRIMARY:
			style.bg_color = Color(0.2, 0.4, 0.5, 1)
			style.border_color = Color(0.35, 0.6, 0.75, 1)
		ButtonType.SECONDARY:
			style.bg_color = Color(0.2, 0.25, 0.35, 1)
			style.border_color = Color(0.4, 0.5, 0.65, 1)
		ButtonType.DANGER:
			style.bg_color = Color(0.45, 0.18, 0.18, 1)
			style.border_color = Color(0.65, 0.3, 0.3, 1)
		ButtonType.SUCCESS:
			style.bg_color = Color(0.18, 0.4, 0.25, 1)
			style.border_color = Color(0.3, 0.55, 0.35, 1)
		ButtonType.DISABLED:
			style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
			style.border_color = Color(0.35, 0.35, 0.35, 0.5)

	_style_cache[cache_key] = style
	return style


## 获取悬停状态样式
static func get_hover_style(button_type: ButtonType = ButtonType.SECONDARY) -> StyleBoxFlat:
	var cache_key = "hover_%d" % button_type
	if _style_cache.has(cache_key):
		return _style_cache[cache_key]

	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 6
	style.shadow_offset = Vector2(2, 3)

	match button_type:
		ButtonType.PRIMARY:
			style.bg_color = Color(0.28, 0.5, 0.62, 1)
			style.border_color = Color(0.45, 0.7, 0.85, 1)
		ButtonType.SECONDARY:
			style.bg_color = Color(0.3, 0.4, 0.55, 1)
			style.border_color = Color(0.5, 0.65, 0.85, 1)
		ButtonType.DANGER:
			style.bg_color = Color(0.55, 0.25, 0.25, 1)
			style.border_color = Color(0.8, 0.4, 0.4, 1)
		ButtonType.SUCCESS:
			style.bg_color = Color(0.25, 0.5, 0.32, 1)
			style.border_color = Color(0.4, 0.7, 0.5, 1)
		ButtonType.DISABLED:
			style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
			style.border_color = Color(0.35, 0.35, 0.35, 0.5)

	_style_cache[cache_key] = style
	return style


## 获取按下状态样式
static func get_pressed_style(button_type: ButtonType = ButtonType.SECONDARY) -> StyleBoxFlat:
	var cache_key = "pressed_%d" % button_type
	if _style_cache.has(cache_key):
		return _style_cache[cache_key]

	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(8)
	style.set_border_width_all(2)
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 2
	style.shadow_offset = Vector2(1, 1)

	match button_type:
		ButtonType.PRIMARY:
			style.bg_color = Color(0.15, 0.32, 0.42, 1)
			style.border_color = Color(0.28, 0.5, 0.62, 1)
		ButtonType.SECONDARY:
			style.bg_color = Color(0.22, 0.28, 0.38, 1)
			style.border_color = Color(0.38, 0.48, 0.62, 1)
		ButtonType.DANGER:
			style.bg_color = Color(0.35, 0.12, 0.12, 1)
			style.border_color = Color(0.5, 0.22, 0.22, 1)
		ButtonType.SUCCESS:
			style.bg_color = Color(0.12, 0.32, 0.18, 1)
			style.border_color = Color(0.22, 0.42, 0.28, 1)
		ButtonType.DISABLED:
			style.bg_color = Color(0.18, 0.18, 0.18, 0.5)
			style.border_color = Color(0.3, 0.3, 0.3, 0.5)

	_style_cache[cache_key] = style
	return style


## 获取字体颜色
static func get_font_color(button_type: ButtonType = ButtonType.SECONDARY) -> Color:
	match button_type:
		ButtonType.PRIMARY:
			return Color(0.9, 0.95, 1.0, 1)
		ButtonType.SECONDARY:
			return Color(0.95, 0.95, 0.95, 1)
		ButtonType.DANGER:
			return Color(1.0, 0.9, 0.9, 1)
		ButtonType.SUCCESS:
			return Color(0.95, 1.0, 0.97, 1)
		ButtonType.DISABLED:
			return Color(0.6, 0.6, 0.6, 1)
	return Color(0.95, 0.95, 0.95, 1)


## 应用样式到按钮
static func apply_style(button: Button, button_type: ButtonType = ButtonType.SECONDARY) -> void:
	button.add_theme_stylebox_override("normal", get_normal_style(button_type))
	button.add_theme_stylebox_override("hover", get_hover_style(button_type))
	button.add_theme_stylebox_override("pressed", get_pressed_style(button_type))
	button.add_theme_color_override("font_color", get_font_color(button_type))
	button.add_theme_color_override("font_hover_color", get_font_color(button_type))

	# 禁用状态
	var disabled_style = get_normal_style(ButtonType.DISABLED)
	button.add_theme_stylebox_override("disabled", disabled_style)
	button.add_theme_color_override("font_disabled_color", Color(0.6, 0.6, 0.6, 1))


## 快捷方法：应用主要按钮样式
static func apply_primary(button: Button) -> void:
	apply_style(button, ButtonType.PRIMARY)


## 快捷方法：应用次要按钮样式
static func apply_secondary(button: Button) -> void:
	apply_style(button, ButtonType.SECONDARY)


## 快捷方法：应用危险按钮样式
static func apply_danger(button: Button) -> void:
	apply_style(button, ButtonType.DANGER)


## 快捷方法：应用成功按钮样式
static func apply_success(button: Button) -> void:
	apply_style(button, ButtonType.SUCCESS)


## 创建带样式的按钮
static func create_button(text: String, button_type: ButtonType = ButtonType.SECONDARY, min_size: Vector2 = Vector2(80, 36)) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = min_size
	apply_style(button, button_type)
	return button


## 创建主要按钮
static func create_primary(text: String, min_size: Vector2 = Vector2(80, 36)) -> Button:
	return create_button(text, ButtonType.PRIMARY, min_size)


## 创建次要按钮
static func create_secondary(text: String, min_size: Vector2 = Vector2(80, 36)) -> Button:
	return create_button(text, ButtonType.SECONDARY, min_size)


## 创建危险按钮
static func create_danger(text: String, min_size: Vector2 = Vector2(80, 36)) -> Button:
	return create_button(text, ButtonType.DANGER, min_size)


## 创建成功按钮
static func create_success(text: String, min_size: Vector2 = Vector2(80, 36)) -> Button:
	return create_button(text, ButtonType.SUCCESS, min_size)


## 清除样式缓存
static func clear_cache() -> void:
	_style_cache.clear()
