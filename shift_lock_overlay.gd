## shift_lock.gd
## Attach to a CanvasLayer node called ShiftLockOverlay (child of Camera3D).
##
## In 1st-person the crosshair is always visible.
## Shift-lock (cursor locked/centred to the screen) is effectively always "on"
## in 1st-person, but this node exposes the toggle so you can extend it to
## a 3rd-person over-the-shoulder mode later without rearchitecting.

extends CanvasLayer

# ─────────────────────────────────────────────
#  SETTINGS
# ─────────────────────────────────────────────
@export var crosshair_color  : Color = Color(1, 1, 1, 0.85)
@export var crosshair_size   : float = 8.0    # arm length in px
@export var crosshair_gap    : float = 3.0    # gap around centre
@export var crosshair_thick  : float = 1.5    # line width

# ─────────────────────────────────────────────
#  STATE
# ─────────────────────────────────────────────
var shift_locked : bool = true   # starts locked (1st-person default)

# ─────────────────────────────────────────────
#  NODES
# ─────────────────────────────────────────────
var _draw_node : Control

func _ready() -> void:
	_draw_node = _CrosshairDraw.new()
	_draw_node.owner_ref  = self
	_draw_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_draw_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_draw_node)

	_apply_lock_state()


func _input(event: InputEvent) -> void:
	# Toggle shift-lock with the "shift_lock" action (map it in project settings,
	# e.g. to Middle Mouse or a dedicated key)
	if event.is_action_just_pressed("shift_lock"):
		shift_locked = !shift_locked
		_apply_lock_state()


func _apply_lock_state() -> void:
	if shift_locked:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		# In a future 3rd-person mode you'd switch to MOUSE_MODE_VISIBLE here
		# and let the camera follow a separate orbit rig instead.
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if _draw_node:
		_draw_node.queue_redraw()


# ─────────────────────────────────────────────
#  INNER CLASS — draws the crosshair via _draw()
#  This avoids needing a separate scene file.
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
