extends CanvasLayer

@export var main_menu_scene : String = "res://main_menu.tscn"

var _paused    : bool = false
var _game_over : bool = false

@onready var panel          : Panel  = $Panel
@onready var resume_button  : Button = $Panel/VBoxContainer/ResumeButton
@onready var restart_button : Button = $Panel/VBoxContainer/RestartButton
@onready var quit_button    : Button = $Panel/VBoxContainer/QuitButton

func _ready() -> void:
	panel.modulate.a = 0.0  # hide visually but keep in tree
	resume_button.pressed.connect(_on_resume)
	restart_button.pressed.connect(_on_restart)
	quit_button.pressed.connect(_on_quit)

func set_game_over() -> void:
	_game_over = true

func _input(event: InputEvent) -> void:
	if _game_over:
		return
	if event is InputEventMouseMotion:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			if _paused:
				_on_resume()
			else:
				_pause()

func _pause() -> void:
	_paused = true
	panel.modulate.a = 0.0
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	resume_button.grab_focus()
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.2) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_resume() -> void:
	_paused = false
	panel.modulate.a = 0.0
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_restart() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()

func _on_quit() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(main_menu_scene)
