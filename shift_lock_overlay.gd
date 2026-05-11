## shift_lock.gd
## Simple first-person crosshair. No shift-lock toggle, no 3rd person.
## Attach to a CanvasLayer called ShiftLockOverlay inside Camera3D.

extends CanvasLayer

# ─────────────────────────────────────────────
#  SETTINGS
# ─────────────────────────────────────────────
@export var crosshair_color : Color = Color(1, 1, 1, 0.85)
@export var crosshair_size  : float = 8.0
@export var crosshair_gap   : float = 3.0
@export var crosshair_thick : float = 1.5

# ─────────────────────────────────────────────
#  NODES
# ─────────────────────────────────────────────
var _draw_node : Control

func _ready() -> void:
	_draw_node = _CrosshairDraw.new()
	_draw_node.owner_ref = self
	_draw_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_draw_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_draw_node)


# ─────────────────────────────────────────────
#  INNER CLASS
# ─────────────────────────────────────────────
class _CrosshairDraw extends Control:
	var owner_ref : Node

	func _draw() -> void:
		if not owner_ref:
			return

		var center : Vector2 = size / 2.0
		var c   : Color = owner_ref.crosshair_color
		var arm : float = owner_ref.crosshair_size
		var gap : float = owner_ref.crosshair_gap
		var w   : float = owner_ref.crosshair_thick

		draw_line(center + Vector2(-arm - gap, 0), center + Vector2(-gap, 0), c, w)
		draw_line(center + Vector2(gap, 0), center + Vector2(arm + gap, 0), c, w)
		draw_line(center + Vector2(0, -arm - gap), center + Vector2(0, -gap), c, w)
		draw_line(center + Vector2(0, gap), center + Vector2(0, arm + gap), c, w)
		draw_circle(center, 1.2, c)
