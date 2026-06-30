extends Node

signal progress_changed(value: float)
signal load_finished

const LOADING_SHORT : PackedScene = preload("res://loading_screen_short.tscn")
const LOADING_LONG  : PackedScene = preload("res://loading_screen_long.tscn")

var scene_path : String = ""
var previous_scene : String = ""
var progress : Array = []
var use_sub_threads : bool = true

func _ready() -> void:
	set_process(false)

func load_scene(_scene_path: String, long_transition: bool = false) -> void:
	previous_scene = get_tree().current_scene.scene_file_path
	scene_path = _scene_path
	var loading_screen : PackedScene = LOADING_LONG if long_transition else LOADING_SHORT
	var new_load_screen := loading_screen.instantiate()
	add_child(new_load_screen)
	progress_changed.connect(new_load_screen.on_progress_changed)
	load_finished.connect(new_load_screen.on_load_finished)
	await new_load_screen.loading_screen_ready
	_start_load()

func go_to_previous() -> void:
	if previous_scene != "":
		load_scene(previous_scene)

func _start_load() -> void:
	var state := ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta: float) -> void:
	var status := ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match status:
		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			var resource = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(resource)
			load_finished.emit()
