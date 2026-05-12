extends CanvasLayer

# ─────────────────────────────────────────────
#  SETTINGS
# ─────────────────────────────────────────────

## Path to your actual game scene
@export var game_scene : String = "res://node_3d.tscn"

# ─────────────────────────────────────────────
#  NODE REFERENCES
# ─────────────────────────────────────────────
@onready var start_button : Button = $Panel/StartButton
@onready var quit_button  : Button = $Panel/QuitButton


# ─────────────────────────────────────────────
#  READY
# ─────────────────────────────────────────────
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	start_button.pressed.connect(_on_start)
	quit_button.pressed.connect(_on_quit)
	# Focus start button so keyboard/gamepad works immediately
	start_button.grab_focus()


# ─────────────────────────────────────────────
#  ACTIONS
# ─────────────────────────────────────────────
func _on_start() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene_to_file(game_scene)


func _on_quit() -> void:
	get_tree().quit()
