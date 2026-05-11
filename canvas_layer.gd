extends CanvasLayer

# ─────────────────────────────────────────────
#  STATE
# ─────────────────────────────────────────────
var _paused : bool = false

# ─────────────────────────────────────────────
#  NODE REFERENCES
# ─────────────────────────────────────────────
@onready var panel          : Panel       = $Panel
@onready var resume_button  : Button      = $Panel/ResumeButton
@onready var restart_button : Button      = $Panel/RestartButton

# IllustrationRect is optional — only used if you add one
@onready var illustration   : TextureRect = $Panel/IllustrationRect if has_node("Panel/IllustrationRect") else null


# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	panel.visible = false
	resume_button.pressed.connect(_on_resume)
	restart_button.pressed.connect(_on_restart)


# ─────────────────────────────────────────────
#  INPUT — Escape toggles pause
# ─────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if _paused:
				_on_resume()
			else:
				_pause()


# ─────────────────────────────────────────────
#  PAUSE
# ─────────────────────────────────────────────
func _pause() -> void:
	_paused = true
	panel.visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Fade in
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.2) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


# ─────────────────────────────────────────────
#  RESUME
# ─────────────────────────────────────────────
func _on_resume() -> void:
	_paused = false
	panel.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ─────────────────────────────────────────────
#  RESTART
# ─────────────────────────────────────────────
func _on_restart() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()


# ─────────────────────────────────────────────
#  ILLUSTRATION  (call this to swap image at runtime if needed)
# ─────────────────────────────────────────────
func set_illustration(texture: Texture2D) -> void:
	if illustration:
		illustration.texture = texture
