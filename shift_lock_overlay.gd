## shift_lock.gd
## Roblox-style shift-lock:
## - Cursor is always captured during play
## - Left Shift toggles shift-lock ON/OFF
## - Shift-lock ON  → crosshair visible, body rotates with camera (1st-person coupled)
## - Shift-lock OFF → crosshair hidden, cursor free (for future 3rd-person use)

extends CanvasLayer

# ─────────────────────────────────────────────
#  SETTINGS
# ─────────────────────────────────────────────
@export var crosshair_color : Color = Color(1, 1, 1, 0.85)
@export var crosshair_size  : float = 8.0
@export var crosshair_gap   : float = 3.0
@export var crosshair_thick : float = 1.5

# ─────────────────────────────────────────────
#  STATE
# ─────────────────────────────────────────────
var shift_locked : bool = true

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
	_apply_lock_state()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return

	# Left Shift toggles shift-lock (tap, not hold — matches Roblox behaviour)
	if event is InputEventKey and event.keycode == KEY_SHIFT and event.pressed and not event.echo:
		shift_locked = !shift_locked
		_apply_lock_state()


func _apply_lock_state() -> void:
	# Cursor always stays captured — shift-lock only affects crosshair
	# and whether the body couples to the camera (handled in player.gd)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if _draw_node:
		_draw_node.queue_redraw()


# ─────────────────────────────────────────────
#  INNER CLASS
# ─────────────────────────────────────────────
class _CrosshairDraw extends Control:
	var owner_ref : Node

	func _draw() -> void:
		if not owner_ref or not owner_ref.shift_locked:
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
