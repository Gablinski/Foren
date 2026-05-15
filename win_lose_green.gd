extends CanvasLayer

# ─────────────────────────────────────────────
#  SETTINGS
# ─────────────────────────────────────────────

@export var main_menu_scene : String = "res://main_menu.tscn"

# ─────────────────────────────────────────────
#  COLOURS
# ─────────────────────────────────────────────

const COLOR_WIN  : Color = Color(0.2, 1.0, 0.45, 1.0)
const COLOR_LOSE : Color = Color(1.0, 0.25, 0.25, 1.0)

# ─────────────────────────────────────────────
#  NODE REFERENCES
# ─────────────────────────────────────────────

@onready var panel          : Panel  = $Panel
@onready var title_label    : Label  = $Panel/TitleLabel
@onready var sub_label      : Label = $Panel/SubLabel
@onready var restart_button : Button = $Panel/RestartButton
@onready var quit_button    : Button = $Panel/QuitButton

# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────

func _ready() -> void:
	panel.visible = false

	#restart_button.pressed.connect(_on_restart)
	quit_button.pressed.connect(_on_quit)

	await get_tree().process_frame

	var gm := get_tree().get_first_node_in_group("game_manager")

	if gm:
		gm.game_won.connect(_on_game_won)
		gm.game_lost.connect(_on_game_lost)

# ─────────────────────────────────────────────
#  WIN / LOSE
# ─────────────────────────────────────────────

func _on_game_won() -> void:
	title_label.text     = "YOU WIN!"
	sub_label.text       = "You made it to the top."
	title_label.modulate = COLOR_WIN
	_show_screen()

func _on_game_lost() -> void:
	title_label.text     = "YOU LOSE"
	sub_label.text       = "The grease got you."
	title_label.modulate = COLOR_LOSE
	_show_screen()

# ─────────────────────────────────────────────
#  SHOW
# ─────────────────────────────────────────────

func _show_screen() -> void:
	panel.visible = true

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	restart_button.grab_focus()

	panel.modulate.a = 0.0

	var tween := create_tween()

	tween.tween_property(panel, "modulate:a", 1.0, 0.4) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

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
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	get_tree().change_scene_to_file(main_menu_scene)
