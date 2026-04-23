extends CharacterBody3D

# ─────────────────────────────────────────────
#  TUNING KNOBS  (adjust these to feel right)
# ─────────────────────────────────────────────

## Ground movement
@export var max_speed        : float = 7.0      # m/s walk
@export var run_speed        : float = 12.0     # m/s when shift held
@export var acceleration     : float = 18.0     # how quickly speed builds
@export var friction         : float = 22.0     # how quickly it bleeds off
@export var air_acceleration : float = 6.0      # control while airborne

## Jump / gravity
@export var jump_height      : float = 1.2      # peak height in metres
@export var gravity_scale    : float = 2.4      # multiplier on project gravity
@export var fall_multiplier  : float = 1.6      # extra gravity on the way down
@export var short_hop_div    : float = 2.5      # vy divided by this on early release
@export var coyote_time      : float = 0.12     # seconds of grace after walking off edge
@export var jump_buffer_time : float = 0.14     # seconds the jump input is "remembered"
@export var max_fall_speed   : float = 28.0     # terminal velocity

## Dash
@export var dash_speed       : float = 22.0
@export var dash_duration    : float = 0.18
@export var dash_cooldown    : float = 0.6

## Mouse look
@export var mouse_sensitivity : float = 0.18   # degrees per pixel
@export var pitch_clamp       : float = 88.0   # max look up/down

## Head-bob (subtle, 1st-person feel)
@export var bob_enabled  : bool  = true
@export var bob_freq     : float = 8.0
@export var bob_amp      : float = 0.022

# ─────────────────────────────────────────────
#  NODE REFERENCES
# ─────────────────────────────────────────────
@onready var camera_rig : Node3D   = $CameraRig
@onready var camera     : Camera3D = $CameraRig/Camera3D

# ─────────────────────────────────────────────
#  INTERNAL STATE
# ─────────────────────────────────────────────
var _gravity      : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _jump_vel     : float                    # computed from jump_height

var _coyote_timer  : float = 0.0
var _buffer_timer  : float = 0.0
var _was_grounded  : bool  = false
var _jump_held     : bool  = false

var _dashing       : bool  = false
var _dash_timer    : float = 0.0
var _dash_cd_timer : float = 0.0
var _dash_dir      : Vector3 = Vector3.ZERO

var _bob_t         : float = 0.0
var _cam_base_y    : float = 0.0   # camera's rest local Y

var _yaw   : float = 0.0   # horizontal look (applied to root)
var _pitch : float = 0.0   # vertical look   (applied to camera_rig)


# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_jump_vel  = sqrt(2.0 * (_gravity * gravity_scale) * jump_height)
	_cam_base_y = camera_rig.position.y


# ─────────────────────────────────────────────
#  INPUT  (mouse look + shift-lock toggle)
# ─────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	# Mouse look — always active in 1st-person (shift-lock is moot here,
	# but the toggle is wired so you can extend it to 3rd-person later)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw   -= event.relative.x * mouse_sensitivity * 0.01
		_pitch  = clamp(
			_pitch - event.relative.y * mouse_sensitivity * 0.01,
			deg_to_rad(-pitch_clamp),
			deg_to_rad( pitch_clamp)
		)
		# Rotate the CharacterBody3D for yaw so the movement basis stays correct
		rotation.y = _yaw
		camera_rig.rotation.x = _pitch

	# Escape / pause releases cursor
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ─────────────────────────────────────────────
#  PHYSICS PROCESS
# ─────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	var grounded := is_on_floor()

	# ── Timers ──────────────────────────────
	_coyote_timer  = max(_coyote_timer  - delta, 0.0)
	_buffer_timer  = max(_buffer_timer  - delta, 0.0)
	_dash_cd_timer = max(_dash_cd_timer - delta, 0.0)

	if _was_grounded and not grounded:
		_coyote_timer = coyote_time    # fell off edge — grace window starts

	if grounded:
		_coyote_timer = coyote_time    # refresh while standing

	# ── Jump buffering ───────────────────────
	if Input.is_action_just_pressed("jump"):
		_buffer_timer = jump_buffer_time

	# ── Jump execution ───────────────────────
	var can_jump := grounded or _coyote_timer > 0.0
	if _buffer_timer > 0.0 and can_jump:
		velocity.y    = _jump_vel
		_coyote_timer = 0.0
		_buffer_timer = 0.0
		_jump_held    = true

	# Short-hop: early release cuts vertical speed
	if _jump_held and Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y /= short_hop_div
		_jump_held  = false

	if grounded and velocity.y < 0.0:
		_jump_held = false

	# ── Gravity ─────────────────────────────
	if not grounded:
		var g := _gravity * gravity_scale
		if velocity.y < 0.0:
			g *= fall_multiplier         # heavier fall
		velocity.y -= g * delta
		velocity.y = max(velocity.y, -max_fall_speed)

	# ── Dash ────────────────────────────────
	_handle_dash(delta)

	# ── Horizontal movement ──────────────────
	if not _dashing:
		_handle_movement(delta, grounded)

	# ── Head-bob ────────────────────────────
	if bob_enabled:
		_update_bob(delta, grounded)

	move_and_slide()
	_was_grounded = grounded


# ─────────────────────────────────────────────
#  MOVEMENT  (WASD / analogue, run modifier)
# ─────────────────────────────────────────────
func _handle_movement(delta: float, grounded: bool) -> void:
	var wish_dir := Vector3.ZERO
	wish_dir.x = Input.get_axis("move_left",    "move_right")
	wish_dir.z = Input.get_axis("move_forward", "move_back")

	# Clamp diagonal so you don't move faster than max_speed at 45°
	if wish_dir.length_squared() > 1.0:
		wish_dir = wish_dir.normalized()

	# Transform relative to where we're looking (horizontal plane only)
	wish_dir = (transform.basis * wish_dir).normalized() * wish_dir.length()
	wish_dir.y = 0.0

	var target_speed := run_speed if Input.is_action_pressed("run") else max_speed
	var target_vel   := wish_dir * target_speed

	var accel := acceleration if grounded else air_acceleration

	if wish_dir == Vector3.ZERO and grounded:
		# Friction: blend towards zero
		var horizontal := Vector3(velocity.x, 0.0, velocity.z)
		horizontal = horizontal.move_toward(Vector3.ZERO, friction * delta)
		velocity.x = horizontal.x
		velocity.z = horizontal.z
	else:
		velocity.x = move_toward(velocity.x, target_vel.x, accel * delta)
		velocity.z = move_toward(velocity.z, target_vel.z, accel * delta)


# ─────────────────────────────────────────────
#  DASH  (8-directional, horizontal only)
# ─────────────────────────────────────────────
func _handle_dash(delta: float) -> void:
	if _dashing:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			_dashing = false
			# Bleed off dash speed so it doesn't feel snappy
			velocity.x *= 0.35
			velocity.z *= 0.35
		else:
			velocity.x = _dash_dir.x * dash_speed
			velocity.z = _dash_dir.z * dash_speed
		return

	if Input.is_action_just_pressed("dash") and _dash_cd_timer <= 0.0:
		var raw := Vector3(
			Input.get_axis("move_left", "move_right"),
			0.0,
			Input.get_axis("move_forward", "move_back")
		)
		# Dash in look direction if no input held
		if raw.length_squared() < 0.1:
			raw = Vector3(0, 0, -1)

		_dash_dir      = (transform.basis * raw).normalized()
		_dash_dir.y    = 0.0
		_dashing       = true
		_dash_timer    = dash_duration
		_dash_cd_timer = dash_cooldown


# ─────────────────────────────────────────────
#  HEAD-BOB
# ─────────────────────────────────────────────
func _update_bob(delta: float, grounded: bool) -> void:
	var horizontal_speed := Vector3(velocity.x, 0.0, velocity.z).length()
	if grounded and horizontal_speed > 0.5:
		_bob_t += delta * bob_freq * (horizontal_speed / max_speed)
	else:
		# Smoothly return to rest
		_bob_t = lerp(_bob_t, round(_bob_t / PI) * PI, delta * 8.0)

	camera_rig.position.y = _cam_base_y + sin(_bob_t) * bob_amp
