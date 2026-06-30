## For now just a placeholder with a back button.
## Add sliders, toggles etc. here later.
extends CanvasLayer

@export var main_menu_scene : String = "res://main_menu.tscn"

@onready var back_button : Button = $Panel/BackButton

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	back_button.pressed.connect(_on_back)
	back_button.grab_focus()

func _on_back() -> void:
	SceneLoader.load_scene(main_menu_scene, "short")
