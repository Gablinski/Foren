extends Area3D

@export var rise_speed = 0.5          # how fast it rises
@export var rise_every_minutes = 0.5  # how long it waits before rising again
@export var max_height = 10.0         # stops at this Y position
@export var pause_duration = 30.0     # how many seconds it pauses at the top

@export var start_delay: float = 3.0
@export var rise_on_start: bool = true

var timer = 0.0
var pause_timer = 0.0
var rising = false
var pausing = false

var _delay_t: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if rise_on_start:
		_delay_t = start_delay
	else:
		_delay_t = 0.0

func _process(delta: float) -> void:
	# initial delay before the whole cycle starts
	if _delay_t > 0.0:
		_delay_t -= delta
		return

	timer += delta

	if timer >= rise_every_minutes * 60.0 and not pausing and not rising:
		rising = true
		timer = 0.0

	if rising:
		position.y += rise_speed * delta

		if position.y >= max_height:
			position.y = max_height
			rising = false
			pausing = true
			pause_timer = 0.0

	if pausing:
		pause_timer += delta

		if pause_timer >= pause_duration:
			pausing = false
			timer = 0.0

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
	rising = true
	pausing = false

func stop_rising() -> void:
	rising = false



#extends Area3D


#
#@export var rise_speed    : float = 1.5
#@export var start_delay   : float = 3.0
#@export var rise_on_start : bool  = true
#
#var _rising  : bool  = false
#var _delay_t : float = 0.0
#
#
#
#
#func _ready() -> void:
	##sync_to_physics = true
	#body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)
	#if rise_on_start:
		#_delay_t = start_delay
#
#
#func _process(delta: float) -> void:
	#if _delay_t > 0.0:
		#_delay_t -= delta
		#if _delay_t <= 0.0:
			#_rising = true
		#return
#
	#if _rising:
		#position.y += rise_speed * delta
#
#
#func _on_body_entered(body: Node3D) -> void:
	#if not body.is_in_group("player"):
		#return
	#var health := body.get_node_or_null("PlayerHealth")
	#if health:
		#health.enter_grease()
#
#
#func _on_body_exited(body: Node3D) -> void:
	#if not body.is_in_group("player"):
		#return
	#var health := body.get_node_or_null("PlayerHealth")
	#if health:
		#health.exit_grease()
#
#
#func start_rising() -> void:
	#_rising = true
#
#func stop_rising() -> void:
	#_rising = false
