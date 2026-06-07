extends CharacterBody3D

# ─────────────────────────────────────────────
#  TUNING KNOBS
# ─────────────────────────────────────────────

## Ground movement
@export var max_speed        : float = 8.0
@export var acceleration     : float = 60.0
@export var friction         : float = 55.0
@export var air_acceleration : float = 8.0

## Jump / gravity
@export var jump_height      : float = 1.1
@export var gravity_scale    : float = 3.0
@export var fall_multiplier  : float = 1.8
@export var short_hop_div    : float = 2.5
@export var coyote_time      : float = 0.10
@export var jump_buffer_time : float = 0.12
@export var max_fall_speed   : float = 32.0

## Dash
@export var dash_speed       : float = 24.0
@export var dash_duration    : float = 0.16
@export var dash_cooldown    : float = 0.5

## Ladder
@export var climb_speed         : float = 5.0
@export var climb_boost         : float = 9.0
@export var dismount_upward     : float = 8.0   # upward force on ladder jump
@export var dismount_backward   : float = 6.0   # backward push away from ladder
@export var dismount_lock_time  : float = 0.25  # seconds before ladder can reattach
@export var climb_boost_duration : float = 0.15  # how long the boost lasts before reattaching

## Mouse look
@export var mouse_sensitivity : float = 0.18
@export var pitch_clamp       : float = 88.0

## Head-bob
@export var bob_enabled : bool  = true
@export var bob_freq    : float = 9.0
@export var bob_amp     : float = 0.018

# ─────────────────────────────────────────────
#  NODE REFERENCES
# ─────────────────────────────────────────────
@onready var camera_rig : Node3D           = $CameraRig
@onready var camera     : Camera3D         = $CameraRig/Camera3D
@onready var collision  : CollisionShape3D = $CollisionShape3D

# ─────────────────────────────────────────────
#  INTERNAL STATE
# ─────────────────────────────────────────────
var _gravity      : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _jump_vel     : float

var _coyote_timer     : float = 0.0
var _buffer_timer     : float = 0.0
var _was_grounded     : bool  = false
var _jump_held        : bool  = false
var _jump_was_pressed : bool  = false

var _dashing       : bool    = false
var _dash_timer    : float   = 0.0
var _dash_cd_timer : float   = 0.0
var _dash_dir      : Vector3 = Vector3.ZERO

var _bob_t      : float = 0.0
var _cam_base_y : float = 0.0

var _yaw   : float = 0.0
var _pitch : float = 0.0

# Ladder state
var _on_ladder          : bool        = false
var _ladder_transform   : Transform3D = Transform3D()
var _dismount_lock_timer : float      = 0.0
var _ladder_boost_timer : float = 0.0

# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_jump_vel   = sqrt(2.0 * (_gravity * gravity_scale) * jump_height)
	_cam_base_y = camera_rig.position.y


# ─────────────────────────────────────────────
#  LADDER INTERFACE
# ─────────────────────────────────────────────
func enter_ladder(ladder_xform: Transform3D) -> void:
	if _dismount_lock_timer > 0.0:
		return
	_on_ladder        = true
	_ladder_transform = ladder_xform
	# Don't zero velocity — preserve upward momentum when jumping into ladder
	velocity.x = 0.0
	velocity.z = 0.0

# ─────────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw   -= event.relative.x * mouse_sensitivity * 0.01
		_pitch  = clamp(
			_pitch - event.relative.y * mouse_sensitivity * 0.01,
			deg_to_rad(-pitch_clamp),
			deg_to_rad( pitch_clamp)
		)
		rotation.y            = _yaw
		camera_rig.rotation.x = _pitch


# ─────────────────────────────────────────────
#  PHYSICS PROCESS
# ─────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	# Tick dismount lock
	if _dismount_lock_timer > 0.0:
		_dismount_lock_timer = max(_dismount_lock_timer - delta, 0.0)

	# Tick boost — gravity applies during boost, reattach when done
	if _ladder_boost_timer > 0.0:
		_ladder_boost_timer = max(_ladder_boost_timer - delta, 0.0)
		# Apply gravity during boost so arc feels natural
		var g := _gravity * gravity_scale
		velocity.y -= g * delta
		velocity.y = max(velocity.y, -max_fall_speed)
		move_and_slide()
		return

	if _on_ladder:
		_handle_ladder(delta)
		move_and_slide()
		return

	var grounded := is_on_floor()

	# ── Timers ──────────────────────────────
	_coyote_timer  = max(_coyote_timer  - delta, 0.0)
	_buffer_timer  = max(_buffer_timer  - delta, 0.0)
	_dash_cd_timer = max(_dash_cd_timer - delta, 0.0)

	if _was_grounded and not grounded:
		_coyote_timer = coyote_time
	if grounded:
		_coyote_timer = coyote_time

	# ── Jump buffering ───────────────────────
	var jump_pressed := Input.is_action_pressed("jump")
	if jump_pressed and not _jump_was_pressed:
		_buffer_timer = jump_buffer_time
	_jump_was_pressed = jump_pressed

	# ── Jump execution ───────────────────────
	var can_jump := grounded or _coyote_timer > 0.0
	if _buffer_timer > 0.0 and can_jump:
		velocity.y    = _jump_vel
		_coyote_timer = 0.0
		_buffer_timer = 0.0
		_jump_held    = true

	if _jump_held and Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y /= short_hop_div
		_jump_held  = false

	if grounded and velocity.y < 0.0:
		_jump_held = false

	# ── Gravity ─────────────────────────────
	if not grounded:
		var g := _gravity * gravity_scale
		if velocity.y < 0.0:
			g *= fall_multiplier
		velocity.y -= g * delta
		velocity.y = max(velocity.y, -max_fall_speed)

	# ── Dash ────────────────────────────────
	_handle_dash(delta)

	# ── Horizontal movement ──────────────────
	_handle_movement(delta, grounded)

	# ── Head-bob ────────────────────────────
	if bob_enabled:
		_update_bob(delta, grounded)

	move_and_slide()
	_was_grounded = grounded


func _handle_ladder(_delta: float) -> void:
	var jump_just := Input.is_action_just_pressed("jump")

	if jump_just:
		var look     := -global_transform.basis.z
		var backward := Vector3(look.x, 0.0, look.z)
		if backward.length_squared() > 0.001:
			backward = backward.normalized()

		if Input.is_action_pressed("move_forward"):
			# Boost jump — exit ladder state temporarily, preserve X/Z, inject Y
			var current_x := velocity.x
			var current_z := velocity.z
			_on_ladder          = false
			_ladder_boost_timer = climb_boost_duration
			_dismount_lock_timer = dismount_lock_time
			velocity.x = current_x
			velocity.z = current_z
			velocity.y = climb_boost
			return
		else:
			# Full dismount — launch backward away from ladder
			velocity.x           = -backward.x * dismount_backward
			velocity.z           = -backward.z * dismount_backward
			velocity.y           = dismount_upward
			_on_ladder           = false
			_dismount_lock_timer = dismount_lock_time
			return

	# Normal climb
	var vertical := Input.get_axis("move_back", "move_forward")
	velocity.x = 0.0
	velocity.z = 0.0
	velocity.y = vertical * climb_speed

# ─────────────────────────────────────────────
#  MOVEMENT
# ─────────────────────────────────────────────
func _handle_movement(delta: float, grounded: bool) -> void:
	var wish_dir := Vector3.ZERO
	wish_dir.x = Input.get_axis("move_left",    "move_right")
	wish_dir.z = Input.get_axis("move_forward", "move_back")

	if wish_dir.length_squared() > 1.0:
		wish_dir = wish_dir.normalized()

	wish_dir = (transform.basis * wish_dir).normalized() * wish_dir.length()
	wish_dir.y = 0.0

	var target_vel := wish_dir * max_speed

	if grounded:
		if wish_dir == Vector3.ZERO:
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)
			velocity.z = move_toward(velocity.z, 0.0, friction * delta)
		else:
			velocity.x = move_toward(velocity.x, target_vel.x, acceleration * delta)
			velocity.z = move_toward(velocity.z, target_vel.z, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, target_vel.x, air_acceleration * delta)
		velocity.z = move_toward(velocity.z, target_vel.z, air_acceleration * delta)


# ─────────────────────────────────────────────
#  DASH
# ─────────────────────────────────────────────
func _handle_dash(delta: float) -> void:
	if _dashing:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			_dashing   = false
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
		_bob_t = lerp(_bob_t, round(_bob_t / PI) * PI, delta * 8.0)

	camera_rig.position.y = _cam_base_y + sin(_bob_t) * bob_amp
