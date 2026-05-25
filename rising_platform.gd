extends AnimatableBody3D

@export var rise_speed    : float = 1.5
@export var start_delay   : float = 3.0
@export var rise_on_start : bool  = true

var _rising  : bool  = false
var _delay_t : float = 0.0

@onready var _detection_area : Area3D = $Area3D


func _ready() -> void:
	sync_to_physics = true
	_detection_area.body_entered.connect(_on_body_entered)
	_detection_area.body_exited.connect(_on_body_exited)
	if rise_on_start:
		_delay_t = start_delay


func _process(delta: float) -> void:
	if _delay_t > 0.0:
		_delay_t -= delta
		if _delay_t <= 0.0:
			_rising = true
		return

	if _rising:
		position.y += rise_speed * delta


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	var health := body.get_node_or_null("PlayerHealth")
	if health:
		health.enter_grease()


func _on_body_exited(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return
	var health := body.get_node_or_null("PlayerHealth")
	if health:
		health.exit_grease()


func start_rising() -> void:
	_rising = true

func stop_rising() -> void:
	_rising = false
