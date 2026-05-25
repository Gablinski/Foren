extends Node

# ─────────────────────────────────────────────
#  SETTINGS
# ─────────────────────────────────────────────
@export var max_health       : float = 100.0
@export var damage_per_second: float = 25.0   # how fast health drains in grease
@export var heal_per_second  : float = 15.0

# ─────────────────────────────────────────────
#  SIGNALS
# ─────────────────────────────────────────────
signal health_changed(current: float, maximum: float)
signal player_died

# ─────────────────────────────────────────────
#  STATE
# ─────────────────────────────────────────────
var current_health : float = 100.0
var in_grease      : bool  = false
var _dead          : bool  = false

# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

# ─────────────────────────────────────────────
#  PROCESS — drain health while in grease
# ─────────────────────────────────────────────
func _process(delta: float) -> void:
	if _dead:
		return

	if in_grease:
		take_damage(damage_per_second * delta)
	elif current_health < max_health:
		current_health = min(current_health + heal_per_second * delta, max_health)
		emit_signal("health_changed", current_health, max_health)

# ─────────────────────────────────────────────
#  TAKE DAMAGE
# ─────────────────────────────────────────────
func take_damage(amount: float) -> void:
	if _dead:
		return

	current_health = max(current_health - amount, 0.0)
	emit_signal("health_changed", current_health, max_health)

	if current_health <= 0.0:
		_dead = true
		emit_signal("player_died")

# ─────────────────────────────────────────────
#  GREASE CONTACT
# ─────────────────────────────────────────────
func enter_grease() -> void:
	in_grease = true

func exit_grease() -> void:
	in_grease = false
