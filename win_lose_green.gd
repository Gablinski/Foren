extends CanvasLayer

@export var main_menu_scene : String = "res://main_menu.tscn"

const COLOR_WIN  : Color = Color(0.2, 1.0, 0.45, 1.0)
const COLOR_LOSE : Color = Color(1.0, 0.25, 0.25, 1.0)

@onready var panel          : Panel  = $Panel
@onready var title_label    : Label  = $Panel/TitleLabel
@onready var restart_button : Button = $Panel/RestartButton
@onready var quit_button    : Button = $Panel/QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	restart_button.pressed.connect(_on_restart)
	quit_button.pressed.connect(_on_quit)
	restart_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quit_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	quit_button.process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().process_frame
	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.game_won.connect(_on_game_won)
		gm.game_lost.connect(_on_game_lost)

func _on_game_won() -> void:
	title_label.text     = "YOU WIN!"
	title_label.modulate = COLOR_WIN
	_animate_title()
	_show_screen()

func _on_game_lost() -> void:
	title_label.text     = "YOU LOSE"
	title_label.modulate = COLOR_LOSE
	_animate_title()
	_show_screen()

func _animate_title() -> void:
	title_label.pivot_offset = title_label.size / 2.0
	var t := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(title_label, "scale:x", 1.2, 0.1)
	t.parallel().tween_property(title_label, "scale:y", 1.2, 0.15)
	t.parallel().tween_property(title_label, "rotation_degrees", 15.0 * [-1.0, 1.0].pick_random(), 0.1)
	t.chain().tween_property(title_label, "scale:x", 1.0, 0.2).set_delay(0.25)
	t.parallel().tween_property(title_label, "scale:y", 1.0, 0.3)
	t.parallel().tween_property(title_label, "rotation_degrees", 0.0, 0.15)

func _show_screen() -> void:
	get_tree().paused = true
	var pm := get_tree().get_first_node_in_group("pause_menu")
	if pm:
		pm.set_game_over()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
	quit_button.mouse_filter = Control.MOUSE_FILTER_STOP
	var buttons := [restart_button, quit_button]
	for i in buttons.size():
		var btn : Button = buttons[i]
		btn.modulate.a = 0.0
		var t := create_tween()
		t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		t.tween_interval(0.15 + i * 0.08)
		t.tween_property(btn, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	panel.visible = true
	await get_tree().create_timer(0.4, false, false, true).timeout
	restart_button.grab_focus()

func _on_restart() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()

func _on_quit() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(main_menu_scene)
