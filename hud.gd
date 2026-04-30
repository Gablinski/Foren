## hud.gd
## Attach to a CanvasLayer node called HUD in your main scene.
## Draws the burger counter (top left) and countdown timer (top right).
## Connects to game_manager.gd signals automatically.
##
## Scene structure:
##   HUD (CanvasLayer)  ← this script
##   ├── BurgerCounter (Label)
##   └── TimerLabel (Label)

extends CanvasLayer

# ─────────────────────────────────────────────
#  NODE REFERENCES
# ─────────────────────────────────────────────
@onready var burger_label : Label = $BurgerCounter
@onready var timer_label  : Label = $TimerLabel

# ─────────────────────────────────────────────
#  COLOURS
# ─────────────────────────────────────────────
const COLOR_NORMAL  : Color = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_WARNING : Color = Color(1.0, 0.25, 0.25, 1.0)   # red under 10s

# ─────────────────────────────────────────────
#  READY — connect to game manager
# ─────────────────────────────────────────────
func _ready() -> void:
	# Wait a frame so game_manager is also ready
	await get_tree().process_frame

	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.burger_count_changed.connect(_on_burger_count_changed)
		gm.timer_updated.connect(_on_timer_updated)
		gm.game_won.connect(_on_game_won)
		gm.game_lost.connect(_on_game_lost)


# ─────────────────────────────────────────────
#  BURGER COUNTER
# ─────────────────────────────────────────────
func _on_burger_count_changed(current: int, total: int) -> void:
	burger_label.text = "Burgers: %d / %d" % [current, total]
	_pop_label(burger_label)


# ─────────────────────────────────────────────
#  TIMER
# ─────────────────────────────────────────────
func _on_timer_updated(time_remaining: float) -> void:
	var seconds := ceili(time_remaining)
	timer_label.text = "%02d" % seconds

	# Turn red and pulse when under 10 seconds
	if time_remaining <= 10.0:
		timer_label.modulate = COLOR_WARNING
		# Pulse scale on every whole second tick
		if seconds != ceili(time_remaining + 0.016):  # ~1 frame lookahead
			_pop_label(timer_label)
	else:
		timer_label.modulate = COLOR_NORMAL


# ─────────────────────────────────────────────
#  WIN / LOSE
# ─────────────────────────────────────────────
func _on_game_won() -> void:
	burger_label.text = "YOU WIN!"
	burger_label.modulate = Color(0.2, 1.0, 0.4, 1.0)
	timer_label.visible = false


func _on_game_lost() -> void:
	timer_label.text = "00"
	timer_label.modulate = COLOR_WARNING
	burger_label.text = "TIME'S UP"
	burger_label.modulate = COLOR_WARNING


# ─────────────────────────────────────────────
#  POP ANIMATION  (FE2-style number bump)
# ─────────────────────────────────────────────
func _pop_label(label: Label) -> void:
	var tween := create_tween()
	tween.tween_property(label, "scale", Vector2(1.25, 1.25), 0.07) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
