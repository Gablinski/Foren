extends Node

enum ANIM_TYPE { SCALE, SLIDE_IN_LEFT, SLIDE_IN_RIGHT }
enum ORDER { START_TOP, START_BOTTOM }
enum ANIM_WHEN { READY, TRIGGER }

@export var target : Control
@export var anim_when : ANIM_WHEN = ANIM_WHEN.READY
@export var anim_type : ANIM_TYPE = ANIM_TYPE.SLIDE_IN_LEFT
@export var order_type : ORDER = ORDER.START_TOP
@export var scale_from : Vector2 = Vector2.ZERO
@export var duration : float = 0.2
@export var delay_appear : float = 0.2
@export var delay_between_elements : float = 0.05
@export var change_visible : bool = false

signal show_finished

var tween : Tween

func _ready() -> void:
	if not target:
		target = get_parent()

	match anim_type:
		ANIM_TYPE.SCALE:
			for c in target.get_children():
				if not c is Control:
					continue
				c.scale = Vector2.ZERO
				c.modulate.a = 0.0
		ANIM_TYPE.SLIDE_IN_LEFT, ANIM_TYPE.SLIDE_IN_RIGHT:
			for c in target.get_children():
				if not c is Control:
					continue
				c.modulate.a = 0.0

	if anim_when == ANIM_WHEN.READY:
		await target.ready
		appear()

func appear() -> void:
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)

	if delay_appear > 0.0:
		tween.tween_interval(delay_appear)
		tween.chain().tween_interval(0.01)

	var children : Array = target.get_children()
	if order_type == ORDER.START_BOTTOM:
		children.reverse()

	var idx : int = 0
	for c in children:
		if not c is Control:
			idx += 1
			continue
		match anim_type:
			ANIM_TYPE.SCALE:
				tween.tween_property(c, "scale", Vector2.ONE, duration) \
					.from(Vector2.ZERO).set_delay(delay_between_elements * idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.01) \
					.set_delay(delay_between_elements * idx)
			ANIM_TYPE.SLIDE_IN_LEFT:
				tween.tween_property(c, "position:x", c.position.x, duration) \
					.from(c.position.x - c.size.x).set_delay(delay_between_elements * idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05) \
					.set_delay(delay_between_elements * idx)
			ANIM_TYPE.SLIDE_IN_RIGHT:
				tween.tween_property(c, "position:x", c.position.x, duration) \
					.from(c.position.x + c.size.x).set_delay(delay_between_elements * idx)
				tween.tween_property(c, "modulate:a", 1.0, 0.05) \
					.set_delay(delay_between_elements * idx)
		idx += 1

	tween.chain().tween_callback(show_finished.emit)
