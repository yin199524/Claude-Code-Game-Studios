# particle_effects.gd - 粒子效果管理器
# 提供简单的粒子效果（胜利/失败）
# 性能优化: 限制粒子数量，批量创建

extends Node

## === 性能优化: 粒子数量限制 ===
## 最大胜利粒子数
const MAX_VICTORY_PARTICLES: int = 20

## 最大失败粒子数
const MAX_DEFEAT_PARTICLES: int = 15

## 最大升级粒子数
const MAX_UPGRADE_PARTICLES: int = 15

## 最大购买粒子数
const MAX_PURCHASE_PARTICLES: int = 8


## 创建胜利粒子效果
static func create_victory_particles(parent: Node, position: Vector2, count: int = MAX_VICTORY_PARTICLES) -> void:
	# === 性能优化: 限制最大粒子数 ===
	count = mini(count, MAX_VICTORY_PARTICLES)

	for i in range(count):
		var particle = ColorRect.new()
		particle.color = Color(1.0, 0.85 + randf() * 0.15, 0.2, 1.0)
		particle.size = Vector2(randf_range(4, 10), randf_range(4, 10))

		# 随机位置偏移
		var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		particle.position = position + offset
		particle.z_index = 200

		parent.add_child(particle)

		# 飘散动画
		var tween = parent.create_tween()
		tween.set_parallel(true)

		var target_y = position.y - randf_range(100, 200)
		var target_x = position.x + randf_range(-80, 80)

		tween.tween_property(particle, "position", Vector2(target_x, target_y), randf_range(0.8, 1.5)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, randf_range(0.6, 1.0)).set_delay(0.3)
		tween.tween_property(particle, "rotation", randf_range(-PI, PI), randf_range(0.8, 1.5))

		tween.chain().tween_callback(particle.queue_free)


## 创建失败粒子效果
static func create_defeat_particles(parent: Node, position: Vector2, count: int = MAX_DEFEAT_PARTICLES) -> void:
	# === 性能优化: 限制最大粒子数 ===
	count = mini(count, MAX_DEFEAT_PARTICLES)

	for i in range(count):
		var particle = ColorRect.new()
		particle.color = Color(0.6 + randf() * 0.2, 0.2, 0.2, 1.0)
		particle.size = Vector2(randf_range(3, 8), randf_range(3, 8))

		# 随机位置偏移
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		particle.position = position + offset
		particle.z_index = 200

		parent.add_child(particle)

		# 下落动画
		var tween = parent.create_tween()
		tween.set_parallel(true)

		var target_y = position.y + randf_range(80, 150)
		var target_x = position.x + randf_range(-50, 50)

		tween.tween_property(particle, "position", Vector2(target_x, target_y), randf_range(1.0, 1.8)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(particle, "modulate:a", 0.0, randf_range(0.8, 1.2)).set_delay(0.4)

		tween.chain().tween_callback(particle.queue_free)


## 创建购买成功粒子效果
static func create_purchase_particles(parent: Node, position: Vector2) -> void:
	for i in range(MAX_PURCHASE_PARTICLES):
		var particle = ColorRect.new()
		particle.color = Color(0.3, 0.8, 0.4, 1.0)
		particle.size = Vector2(randf_range(4, 8), randf_range(4, 8))

		var angle = randf() * PI * 2
		var radius = randf_range(20, 50)
		particle.position = position + Vector2(cos(angle) * radius, sin(angle) * radius)
		particle.z_index = 200

		parent.add_child(particle)

		var tween = parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", position + Vector2(cos(angle) * (radius + 30), sin(angle) * (radius + 30)), 0.5)
		tween.tween_property(particle, "modulate:a", 0.0, 0.5)
		tween.chain().tween_callback(particle.queue_free)


## 创建升级粒子效果
static func create_upgrade_particles(parent: Node, position: Vector2, count: int = MAX_UPGRADE_PARTICLES) -> void:
	# === 性能优化: 限制最大粒子数 ===
	count = mini(count, MAX_UPGRADE_PARTICLES)

	for i in range(count):
		var particle = ColorRect.new()
		# 金色到黄色的渐变
		particle.color = Color(1.0, 0.8 + randf() * 0.2, randf() * 0.3, 1.0)
		particle.size = Vector2(randf_range(5, 12), randf_range(5, 12))

		# 从中心向外扩散
		var angle = randf() * PI * 2
		var start_radius = randf_range(5, 20)
		var end_radius = randf_range(60, 120)

		particle.position = position + Vector2(cos(angle) * start_radius, sin(angle) * start_radius)
		particle.z_index = 200

		parent.add_child(particle)

		var tween = parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", position + Vector2(cos(angle) * end_radius, sin(angle) * end_radius), randf_range(0.6, 1.0)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, randf_range(0.4, 0.8)).set_delay(0.2)
		tween.tween_property(particle, "rotation", randf_range(-PI/2, PI/2), randf_range(0.6, 1.0))
		tween.tween_property(particle, "size", Vector2(2, 2), randf_range(0.4, 0.8))

		tween.chain().tween_callback(particle.queue_free)
