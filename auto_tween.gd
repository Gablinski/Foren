extends Node

enum ANIM_TYPE { FADE, SCALE }
enum ANIM_WHEN { READY, VISIBLE, TRIGGER }
enum SCALE_FROM { CENTER, TOP_LEFT, TOP_CENTER }

@export var target : Control
@export var anim_when : ANIM_WHEN = ANIM_WHEN.VISIBLE
@export var anim_type : ANIM_TYPE = ANIM_TYPE.SCALE
@export var scale_from : SCALE_FROM = SCALE_FROM.CENTER
@export var duration : float = 0.2
@export var start_delay : float = 0.0
@export var auto_hide_after : float = -1.0
@export var change_visible : bool = false
@export var force_from : bool = false

signal show_started
signal hide_started

var tween : Tween
var ignore_visibility_change : bool = false

func _ready() -> void:
	if not target:
		target = get_parent()

	match anim_type:
		ANIM_TYPE.FADE:
			target.modulate.a = 0.0
		ANIM_TYPE.SCALE:
			target.scale = Vector2.ZERO

	if anim_type == ANIM_TYPE.SCALE:
		set_pivot(scale_from)

	match anim_when:
		ANIM_WHEN.READY:
			await target.ready
			show()
		ANIM_WHEN.VISIBLE:
			target.visibility_changed.connect(_on_target_visibility_changed)
		ANIM_WHEN.TRIGGER:
			if not get_parent().has_signal("show_started"):
				printerr("Autotween set to trigger but no autotween_trigger defined")
				return

func _on_target_visibility_changed() -> void:
	if ignore_visibility_change:
		return
	if target.visible:
		show()
	else:
		hide()

func show() -> void:
	show_started.emit()
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	if start_delay > 0.0:
		tween.tween_interval(start_delay)
	match anim_type:
		ANIM_TYPE.FADE:
			tween.tween_property(target, "modulate:a", 1.0, duration)
		ANIM_TYPE.SCALE:
			set_pivot(scale_from)
			if force_from:
				target.scale = Vector2.ZERO
			tween.tween_property(target, "scale", Vector2.ONE, duration).from(Vector2.ZERO)
	tween.chain().tween_callback(func():
		target.pivot_offset = Vector2.ZERO
	)
	if auto_hide_after > 0.0:
		tween.chain().tween_interval(auto_hide_after)
		tween.chain().tween_callback(hide)

func hide() -> void:
	hide_started.emit()
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

	match anim_type:
		ANIM_TYPE.FADE:
			tween.tween_property(target, "modulate:a", 0.0, duration)
		ANIM_TYPE.SCALE:
			set_pivot(scale_from)
			tween.tween_property(target, "scale", Vector2.ZERO, duration)

	if change_visible:
		tween.chain().tween_callback(func(): 
			ignore_visibility_change = true
			target.visible = false
			ignore_visibility_change = false
		)

func set_pivot(pivot: SCALE_FROM) -> void:
	match pivot:
		SCALE_FROM.CENTER:
			target.pivot_offset = target.size / 2.0
		SCALE_FROM.TOP_LEFT:
			target.pivot_offset = Vector2(0.0, 0.0)
		SCALE_FROM.TOP_CENTER:
			target.pivot_offset = Vector2(target.size.x / 2.0, 0.0)
