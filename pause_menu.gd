extends CanvasLayer

# ─────────────────────────────────────────────
#  SETTINGS
# ─────────────────────────────────────────────

@export var main_menu_scene : String = "res://scenes/main_menu.tscn"

# ─────────────────────────────────────────────
#  STATE
# ─────────────────────────────────────────────

var _paused : bool = false

# ─────────────────────────────────────────────
#  NODE REFERENCES
# ─────────────────────────────────────────────

@onready var panel          : Panel  = $Panel
@onready var title_label    : Label  = $Panel/TitleLabel
@onready var resume_button  : Button = $Panel/ResumeButton
@onready var restart_button : Button = $Panel/RestartButton
#@onready var settings_button : Button = $Panel/SettingsButton
@onready var quit_button    : Button = $Panel/QuitButton

# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────

func _ready() -> void:
	panel.visible = false

	resume_button.pressed.connect(_on_resume)
	restart_button.pressed.connect(_on_restart)

	# quit_button.pressed.connect(_on_quit)

# ─────────────────────────────────────────────
#  INPUT
# ─────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()

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

	resume_button.grab_focus()

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
#  QUIT TO MAIN MENU
# ─────────────────────────────────────────────

func _on_quit() -> void:
	get_tree().paused = false

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	get_tree().change_scene_to_file(main_menu_scene)
