extends Area3D
# ─────────────────────────────────────────────
#  CONFIGURATION
# ─────────────────────────────────────────────
@export var burger_id    : String = "burger_01"
@export var display_name : String = "Burger"
@export var animate      : bool   = true
@export var float_speed  : float  = 1.5
@export var float_height : float  = 0.15
@export var spin_speed   : float  = 90.0

# ─────────────────────────────────────────────
#  SIGNALS
# ─────────────────────────────────────────────
signal collected(burger_id: String)

# ─────────────────────────────────────────────
#  INTERNAL STATE
# ─────────────────────────────────────────────
var _base_y    : float
var _time      : float = 0.0
var _collected : bool  = false

# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	_base_y = position.y
	body_entered.connect(_on_body_entered)

# ─────────────────────────────────────────────
#  PROCESS
# ─────────────────────────────────────────────
func _process(delta: float) -> void:
	if not animate or _collected:
		return
	_time += delta
	position.y = _base_y + sin(_time * float_speed) * float_height
	rotation_degrees.y += spin_speed * delta

# ─────────────────────────────────────────────
#  COLLECTION
# ─────────────────────────────────────────────
func _on_body_entered(body: Node3D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	collected.emit(burger_id)
	visible = false
	set_deferred("monitoring", false)
	await get_tree().create_timer(0.1).timeout
	queue_free()
