## Handles: burger collection count, countdown timer, win/lose state.
##
## Scene expects:
##   - All BurgerPickup nodes tagged with "burger_pickup" group
##   - A WinZone node tagged with "win_zone" group (Area3D at top of map)
##   - A HUD node with hud.gd attached, tagged "hud" group

extends Node

# ─────────────────────────────────────────────
#  SETTINGS
# ─────────────────────────────────────────────
@export var total_burgers   : int   = 5      # total burgers in the level
@export var countdown_time  : float = 60.0   # seconds on the clock

# ─────────────────────────────────────────────
#  SIGNALS
# ─────────────────────────────────────────────
signal burger_count_changed(current: int, total: int)
signal timer_updated(time_left: float)
signal game_won
signal game_lost

# ─────────────────────────────────────────────
#  STATE
# ─────────────────────────────────────────────
var burgers_collected : int   = 0
var time_left         : float = 0.0
var game_active       : bool  = false

# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	time_left = countdown_time

	# Connect all burger pickups
	var pickups := get_tree().get_nodes_in_group("burger_pickup")
	for pickup in pickups:
		pickup.collected.connect(_on_burger_collected)

	# Connect win zone
	var win_zones := get_tree().get_nodes_in_group("win_zone")
	for zone in win_zones:
		zone.body_entered.connect(_on_win_zone_entered)

	# Small delay so the HUD is ready before we push first state
	await get_tree().process_frame
	_start_game()


# ─────────────────────────────────────────────
#  GAME FLOW
# ─────────────────────────────────────────────
func _start_game() -> void:
	game_active = true
	emit_signal("burger_count_changed", burgers_collected, total_burgers)
	emit_signal("timer_updated", time_left)


func _process(delta: float) -> void:
	if not game_active or get_tree().paused:
		return

	time_left -= delta
	emit_signal("timer_updated", time_left)

	if time_left <= 0.0:
		time_left = 0.0
		_trigger_lose()


# ─────────────────────────────────────────────
#  BURGER COLLECTED
# ─────────────────────────────────────────────
func _on_burger_collected(_id: String) -> void:
	if not game_active:
		return
	burgers_collected += 1
	emit_signal("burger_count_changed", burgers_collected, total_burgers)

# ─────────────────────────────────────────────
#  WIN / LOSE
# ─────────────────────────────────────────────
func _on_win_zone_entered(body: Node3D) -> void:
	if not game_active:
		return
	if body.is_in_group("player"):
		_trigger_win()


func _trigger_win() -> void:
	game_active = false
	emit_signal("game_won")
	print("YOU WIN")   # replace with scene transition / UI later


func _trigger_lose() -> void:
	game_active = false
	emit_signal("game_lost")
	print("YOU LOSE")  # replace with scene transition / UI later
