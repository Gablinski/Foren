## Scene expects:
##   - All BurgerPickup nodes tagged with "burger_pickup" group
##   - A WinZone node tagged with "win_zone" group (Area3D at top of map)
##   - A HUD node with hud.gd attached, tagged "hud" group

## Handles: burger collection count, stopwatch timer, win/lose state.
extends Node

@export var total_burgers : int = 8

signal burger_count_changed(current: int, total: int)
signal timer_updated(time_elapsed: float)
signal game_won(time_elapsed: float)
signal game_lost

var burgers_collected : int   = 0
var time_elapsed      : float = 0.0
var game_active       : bool  = false

func _ready() -> void:
	var pickups := get_tree().get_nodes_in_group("burger_pickup")
	for pickup in pickups:
		pickup.collected.connect(_on_burger_collected)
	
	var win_zones := get_tree().get_nodes_in_group("win_zone")
	print("Found win zones: ", win_zones.size())
	for zone in win_zones:
		print("Win zone found: ", zone.name)
		zone.body_entered.connect(_on_win_zone_entered)
	
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var health := player.get_node_or_null("PlayerHealth") as Node
		if health:
			health.connect("player_died", _trigger_lose)
	await get_tree().process_frame
	_start_game()

func _start_game() -> void:
	game_active = true
	emit_signal("burger_count_changed", burgers_collected, total_burgers)
	emit_signal("timer_updated", time_elapsed)

func _process(delta: float) -> void:
	if not game_active or get_tree().paused:
		return
	time_elapsed += delta
	emit_signal("timer_updated", time_elapsed)

func _on_burger_collected(_id: String) -> void:
	if not game_active:
		return
	burgers_collected += 1
	emit_signal("burger_count_changed", burgers_collected, total_burgers)

func _on_win_zone_entered(body: Node3D) -> void:
	print("body entered win zone: ", body.name, " game_active: ", game_active)
	if not game_active:
		return
	if body.is_in_group("player"):
		_trigger_win()

func _trigger_win() -> void:
	game_active = false
	emit_signal("game_won", time_elapsed)

func _trigger_lose() -> void:
	game_active = false
	emit_signal("game_lost")
