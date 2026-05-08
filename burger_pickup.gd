extends Area3D

# ─────────────────────────────────────────────
#  CONFIGURATION
# ─────────────────────────────────────────────

## Unique ID for this burger — used by the level manager to know which
## doors/sections to unlock. Set this in the Inspector per-instance.
@export var burger_id : String = "burger_01"

## Label shown in the UI when the player picks this up (optional)
@export var display_name : String = "Burger"

## If true, the pickup floats and rotates (visual polish)
@export var animate : bool = true

@export var float_speed  : float = 1.5
@export var float_height : float = 0.15
@export var spin_speed   : float = 90.0   # degrees per second

# ─────────────────────────────────────────────
#  SIGNALS
# ─────────────────────────────────────────────

## Emitted when a player walks into this pickup.
## Connect this in your level scene to unlock doors, spawn things, etc.
signal collected(burger_id: String)

# ─────────────────────────────────────────────
#  INTERNAL STATE
# ─────────────────────────────────────────────
var _base_y     : float
var _time       : float = 0.0
var _collected  : bool  = false

# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	_base_y = position.y
	# Connect the Area3D body_entered signal to our handler
	body_entered.connect(_on_body_entered)


# ─────────────────────────────────────────────
#  PROCESS  (animation only)
# ─────────────────────────────────────────────
func _process(delta: float) -> void:
	if not animate or _collected:
		return

	_time += delta
	# Float up and down
	position.y = _base_y + sin(_time * float_speed) * float_height
	# Spin
	rotation_degrees.y += spin_speed * delta


# ─────────────────────────────────────────────
#  COLLECTION
# ─────────────────────────────────────────────
func _on_body_entered(body: Node3D) -> void:
	print("body entered: ", body.name, " groups: ", body.get_groups())
	if not body.is_in_group("player"):
		return
	# Only react to the player, and only once
	if _collected:
		return
	if not body.is_in_group("player"):
		return

	_collected = true

	# Emit the signal — your level manager listens for this
	collected.emit(burger_id)

	# Hide immediately; add your own effect here later (sound, particles etc.)
	visible = false
	set_deferred("monitoring", false)

	# Remove from scene after a short delay so any effects can finish
	await get_tree().create_timer(0.1).timeout
	queue_free()
