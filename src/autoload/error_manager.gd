# error_manager.gd - 错误管理器
# 统一处理游戏中的错误，提供友好的用户提示和恢复机制

extends Node

## 错误类型枚举
enum ErrorType {
	SAVE_FAILED,      ## 存档保存失败
	SAVE_CORRUPTED,   ## 存档损坏
	LOAD_FAILED,      ## 加载失败
	RESOURCE_MISSING, ## 资源缺失
	NETWORK_ERROR,    ## 网络错误
	PURCHASE_FAILED,  ## 购买失败
	INVALID_DATA,     ## 数据无效
	UNKNOWN           ## 未知错误
}

## 恢复选项枚举
enum RecoveryOption {
	RETRY,            ## 重试
	RESTORE_DEFAULT,  ## 恢复默认
	IGNORE,           ## 忽略
	RESTART,          ## 重启游戏
	NONE              ## 无可用选项
}

## 错误信息结构
class ErrorInfo:
	var type: ErrorType
	var title: String
	var message: String
	var technical_detail: String
	var recovery_options: Array[RecoveryOption] = []
	var recovery_callback: Callable = Callable()

	func _init(p_type: ErrorType, p_title: String, p_message: String, p_detail: String = "", p_options: Array[RecoveryOption] = [], p_callback: Callable = Callable()) -> void:
		type = p_type
		title = p_title
		message = p_message
		technical_detail = p_detail
		recovery_options = p_options
		recovery_callback = p_callback

## 信号

## 错误发生信号
signal error_occurred(error_info: ErrorInfo)

## 配置

## 错误通知场景
var _notification_scene: PackedScene

## 错误日志（最近 50 条）
var _error_log: Array[Dictionary] = []
const MAX_LOG_SIZE: int = 50


func _ready() -> void:
	_notification_scene = preload("res://scenes/notification/error_notification.tscn")


## 报告错误（主入口）
func report_error(error_info: ErrorInfo) -> void:
	# 记录日志
	_log_error(error_info)

	# 输出到控制台
	if error_info.technical_detail != "":
		push_error("[%s] %s: %s" % [_get_type_name(error_info.type), error_info.message, error_info.technical_detail])
	else:
		push_error("[%s] %s" % [_get_type_name(error_info.type), error_info.message])

	# 发送信号
	error_occurred.emit(error_info)

	# 显示通知
	_show_error_notification(error_info)


## 显示错误通知
func _show_error_notification(error_info: ErrorInfo) -> void:
	var canvas = _get_canvas_layer()
	if canvas == null:
		print("[ErrorManager] 无法显示错误通知：CanvasLayer 不存在")
		return

	var notification = _notification_scene.instantiate()
	notification.setup(error_info)
	canvas.add_child(notification)


## 获取 CanvasLayer
func _get_canvas_layer() -> CanvasLayer:
	var tree = Engine.get_main_loop()
	if tree is SceneTree and tree.root:
		for child in tree.root.get_children():
			if child is CanvasLayer:
				return child
		# 如果不存在 CanvasLayer，创建一个临时的
		var canvas = CanvasLayer.new()
		canvas.layer = 1000
		tree.root.add_child(canvas)
		return canvas
	return null


## 记录错误日志
func _log_error(error_info: ErrorInfo) -> void:
	var log_entry = {
		"timestamp": Time.get_datetime_string_from_system(),
		"type": _get_type_name(error_info.type),
		"message": error_info.message,
		"detail": error_info.technical_detail
	}
	_error_log.append(log_entry)

	# 限制日志大小
	if _error_log.size() > MAX_LOG_SIZE:
		_error_log.pop_front()


## 获取错误类型名称
func _get_type_name(error_type: ErrorType) -> String:
	match error_type:
		ErrorType.SAVE_FAILED:
			return "存档失败"
		ErrorType.SAVE_CORRUPTED:
			return "存档损坏"
		ErrorType.LOAD_FAILED:
			return "加载失败"
		ErrorType.RESOURCE_MISSING:
			return "资源缺失"
		ErrorType.NETWORK_ERROR:
			return "网络错误"
		ErrorType.PURCHASE_FAILED:
			return "购买失败"
		ErrorType.INVALID_DATA:
			return "数据无效"
		_:
			return "未知错误"


## ==================== 便捷方法 ====================

## 报告存档保存失败
func report_save_failed(detail: String = "") -> void:
	var error = ErrorInfo.new(
		ErrorType.SAVE_FAILED,
		"存档保存失败",
		"游戏进度保存失败，请检查存储空间是否充足。",
		detail,
		[RecoveryOption.RETRY, RecoveryOption.IGNORE],
		Callable(SaveManager, "save_game")
	)
	report_error(error)


## 报告存档损坏
func report_save_corrupted(detail: String = "") -> void:
	var error = ErrorInfo.new(
		ErrorType.SAVE_CORRUPTED,
		"存档损坏",
		"游戏存档已损坏，将尝试恢复或创建新存档。",
		detail,
		[RecoveryOption.RESTORE_DEFAULT],
		Callable(_restore_default_save)
	)
	report_error(error)


## 报告加载失败
func report_load_failed(resource_name: String, detail: String = "") -> void:
	var error = ErrorInfo.new(
		ErrorType.LOAD_FAILED,
		"加载失败",
		"无法加载「%s」，请尝试重启游戏。" % resource_name,
		detail,
		[RecoveryOption.RETRY, RecoveryOption.RESTART]
	)
	report_error(error)


## 报告资源缺失
func report_resource_missing(resource_path: String) -> void:
	var error = ErrorInfo.new(
		ErrorType.RESOURCE_MISSING,
		"资源缺失",
		"游戏资源文件缺失，请重新安装游戏。",
		"Path: %s" % resource_path,
		[RecoveryOption.RESTART]
	)
	report_error(error)


## 报告购买失败
func report_purchase_failed(reason: String, detail: String = "") -> void:
	var error = ErrorInfo.new(
		ErrorType.PURCHASE_FAILED,
		"购买失败",
		reason,
		detail,
		[RecoveryOption.IGNORE]
	)
	report_error(error)


## 报告数据无效
func report_invalid_data(context: String, detail: String = "") -> void:
	var error = ErrorInfo.new(
		ErrorType.INVALID_DATA,
		"数据异常",
		"检测到异常数据：%s。游戏将尝试自动修复。" % context,
		detail,
		[RecoveryOption.RESTORE_DEFAULT, RecoveryOption.IGNORE]
	)
	report_error(error)


## 恢复默认存档
func _restore_default_save() -> void:
	SaveManager.player_data = PlayerData.create_default()
	SaveManager.save_game()
	print("[ErrorManager] 已恢复默认存档")


## 获取错误日志
func get_error_log() -> Array[Dictionary]:
	return _error_log.duplicate()


## 清空错误日志
func clear_error_log() -> void:
	_error_log.clear()
