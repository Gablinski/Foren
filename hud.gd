extends CanvasLayer

@onready var burger_label  : Label       = $BurgerCounter
@onready var timer_label   : Label       = $TimerLabel
@onready var health_bar    : ProgressBar = $HealthBar
@onready var health_label  : Label       = $HealthLabel
@onready var damage_flash  : ColorRect   = $DamageFlash

const COLOR_NORMAL  : Color = Color(1.0, 1.0, 1.0, 1.0)
const COLOR_WARNING : Color = Color(1.0, 0.25, 0.25, 1.0)
const FLASH_COLOR   : Color = Color(1.0, 0.0, 0.0, 0.35)

var _last_health : float = 100.0


func _ready() -> void:
	# DamageFlash setup — full screen red overlay, starts invisible
	damage_flash.color = Color(1.0, 0.0, 0.0, 0.0)
	damage_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	damage_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE

	await get_tree().process_frame

	# Connect game manager
	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.burger_count_changed.connect(_on_burger_count_changed)
		gm.timer_updated.connect(_on_timer_updated)
		gm.game_won.connect(_on_game_won)
		gm.game_lost.connect(_on_game_lost)

	# Connect player health
	var player := get_tree().get_first_node_in_group("player")
	if player:
		var health := player.get_node_or_null("PlayerHealth")
		if health:
			health.health_changed.connect(_on_health_changed)
			health_bar.max_value = health.max_health
			health_bar.value     = health.current_health


# ─────────────────────────────────────────────
#  HEALTH
# ─────────────────────────────────────────────
func _on_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value     = current
	health_label.text    = str(int(current)) + "%"
	if current < _last_health:
		_flash_damage()
	_last_health = current


func _flash_damage() -> void:
	# Kill any existing flash tween first
	var tween := create_tween()
	tween.tween_property(damage_flash, "color:a", 0.35, 0.05) \
		.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(damage_flash, "color:a", 0.0, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


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

	if time_remaining <= 10.0:
		timer_label.modulate = COLOR_WARNING
	else:
		timer_label.modulate = COLOR_NORMAL


# ─────────────────────────────────────────────
#  WIN / LOSE
# ─────────────────────────────────────────────
func _on_game_won() -> void:
	burger_label.text     = "YOU WIN!"
	burger_label.modulate = Color(0.2, 1.0, 0.4, 1.0)
	timer_label.visible   = false

func _on_game_lost() -> void:
	timer_label.text      = "00"
	timer_label.modulate  = COLOR_WARNING
	burger_label.text     = "TIME'S UP"
	burger_label.modulate = COLOR_WARNING


# ─────────────────────────────────────────────
#  POP ANIMATION
# ─────────────────────────────────────────────
func _pop_label(label: Label) -> void:
	var tween := create_tween()
	tween.tween_property(label, "scale", Vector2(1.25, 1.25), 0.07) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
