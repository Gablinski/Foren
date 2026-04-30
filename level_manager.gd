## level_manager.gd
## Attach to a plain Node in your main scene.
## This is the central brain — it listens to burger pickups
## and decides what happens in the level as a result.

extends Node

# ─────────────────────────────────────────────
#  TRACKING
# ─────────────────────────────────────────────

# Keeps track of which burgers have been collected this level
var collected_burgers : Array[String] = []

# ─────────────────────────────────────────────
#  READY — connect all pickups in the scene
# ─────────────────────────────────────────────
func _ready() -> void:
	# Finds every BurgerPickup in the scene automatically
	# so you don't have to manually connect each one
	var pickups := get_tree().get_nodes_in_group("burger_pickup")
	for pickup in pickups:
		pickup.collected.connect(_on_burger_collected)


# ─────────────────────────────────────────────
#  COLLECTED  (consume_on_collect = true)
#  Called once per pickup, then it disappears
# ─────────────────────────────────────────────
func _on_burger_collected(id: String) -> void:
	collected_burgers.append(id)
	print("Burger collected: ", id)

	match id:
		"burger_01":
			pass  # unlock door, load section, etc — fill in later
		"burger_02":
			pass
		_:
			pass  # fallback for any unrecognised id

	# Example: if all burgers collected, trigger something
	# if collected_burgers.size() >= 3:
	# 	_on_all_burgers_collected()


# ─────────────────────────────────────────────
#  ACTIVATED  (consume_on_collect = false)
#  Called every time the player re-enters
# ─────────────────────────────────────────────
func _on_burger_activated(id: String) -> void:
	print("Burger activated: ", id)

	match id:
		"burger_01":
			pass  # toggle something, etc
		_:
			pass


# ─────────────────────────────────────────────
#  OPTIONAL — fires when every burger is collected
# ─────────────────────────────────────────────
func _on_all_burgers_collected() -> void:
	print("All burgers collected!")
	# load next level, play cutscene, open final door, etc
