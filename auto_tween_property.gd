@tool
extends Control

@export var target_property : String = "text"

var tween : Tween

func _set(property: StringName, value: Variant) -> bool:
	if property == target_property:
		if get(property) == value:
			return false
		animate()
		return false
	return false

func animate() -> void:
	pivot_offset = size / 2.0
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale:x", 1.2, 0.1)
	tween.parallel().tween_property(self, "scale:y", 1.2, 0.15)
	tween.parallel().tween_property(self, "rotation_degrees",
		15.0 * [-1.0, 1.0].pick_random(), 0.1)
	tween.chain().tween_property(self, "scale:x", 1.0, 0.2).set_delay(0.25)
	tween.parallel().tween_property(self, "scale:y", 1.0, 0.3)
	tween.parallel().tween_property(self, "rotation_degrees", 0.0, 0.15)
