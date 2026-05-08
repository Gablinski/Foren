extends StaticBody3D

# ─────────────────────────────────────────────
#  SETTINGS
# ─────────────────────────────────────────────
@export var rise_speed      : float = 1.5    # units per second upward
@export var start_delay     : float = 3.0    # seconds before it starts rising
@export var rise_on_start   : bool  = true   # set false to trigger manually

# ─────────────────────────────────────────────
#  STATE
# ─────────────────────────────────────────────
var _rising  : bool  = false
var _delay_t : float = 0.0

@onready var _detection_area : Area3D = $Area3D


# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	_detection_area.body_entered.connect(_on_body_entered)
	if rise_on_start:
		_delay_t = start_delay


# ─────────────────────────────────────────────
#  PROCESS
# ─────────────────────────────────────────────
func _process(delta: float) -> void:
	if _delay_t > 0.0:
		_delay_t -= delta
		if _delay_t <= 0.0:
			_rising = true
		return

	if _rising:
		position.y += rise_speed * delta


# ─────────────────────────────────────────────
#  PLAYER CONTACT — trigger lose
# ─────────────────────────────────────────────
func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm and gm.game_active:
		gm._trigger_lose()


# ─────────────────────────────────────────────
#  MANUAL CONTROL (call from game_manager if needed)
# ─────────────────────────────────────────────
func start_rising() -> void:
	_rising = true

func stop_rising() -> void:
	_rising = false
