extends Button

@export var hover_animate : bool  = true
@export var width_full_rot : float = 200.0  # reference width for rotation scaling

var tween : Tween

func _ready() -> void:
	mouse_entered.connect(hover)
	mouse_exited.connect(unhover)
	pressed.connect(on_press)

func hover() -> void:
	if disabled:
		return
	if not hover_animate:
		return

	pivot_offset = size / 2.0

	var scale_ratio : float = clampf(width_full_rot / size.x, 0.5, 1.0)
	var scale_target : float = 1.0 + (0.2 * scale_ratio)

	if tween and tween.is_running():
		tween.kill()

	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale:x", scale_target, 0.2)
	tween.parallel().tween_property(self, "scale:y", scale_target, 0.35)
	tween.parallel().tween_property(self, "rotation_degrees",
		5.0 * scale_ratio * [-1.0, 1.0].pick_random(), 0.1)
	tween.parallel().tween_property(self, "rotation_degrees",
		0.0, 0.1).set_delay(0.1)

func unhover() -> void:
	if disabled:
		return
	if not hover_animate:
		return

	pivot_offset = size / 2.0

	if tween and tween.is_running():
		tween.kill()

	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale:x", 1.0, 0.2)
	tween.parallel().tween_property(self, "scale:y", 1.0, 0.35)
	tween.parallel().tween_property(self, "rotation_degrees", 0.0, 0.1)

func on_press() -> void:
	if disabled:
		return

	pivot_offset = size / 2.0

	if tween and tween.is_running():
		tween.kill()

	# Squish down on click then spring back
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale:x", 1.2, 0.08)
	tween.parallel().tween_property(self, "scale:y", 0.85, 0.08)
	tween.chain().tween_property(self, "scale:x", 1.0, 0.15)
	tween.parallel().tween_property(self, "scale:y", 1.0, 0.15)
