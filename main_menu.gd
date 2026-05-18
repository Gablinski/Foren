extends CanvasLayer

@export var game_scene     : String = "res://node_3d.tscn"
@export var settings_scene : String = "res://settings_menu.tscn"

@onready var start_button    : Button = $Panel/StartButton
@onready var settings_button : Button = $Panel/SettingsButton
@onready var quit_button     : Button = $Panel/QuitButton

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	start_button.pressed.connect(_on_start)
	settings_button.pressed.connect(_on_settings)
	quit_button.pressed.connect(_on_quit)
	start_button.grab_focus()

func _on_start() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene_to_file(game_scene)

func _on_settings() -> void:
	get_tree().change_scene_to_file(settings_scene)

func _on_quit() -> void:
	get_tree().quit()
