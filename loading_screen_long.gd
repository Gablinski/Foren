extends CanvasLayer

signal loading_screen_ready

@export var animation_player : AnimationPlayer
@export var in_time : float = 0.5
@export var fade_in_time : float = 2.0
@export var pause_time : float = 3.0
@export var fade_out_time : float = 2.0
@export var out_time : float = 0.5
@export var splash_screen : TextureRect

func _ready() -> void:
	splash_screen.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_interval(in_time)
	tween.tween_property(splash_screen, "modulate:a", 1.0, fade_in_time)
	tween.tween_interval(pause_time)
	tween.tween_property(splash_screen, "modulate:a", 0.0, fade_out_time)
	tween.tween_interval(out_time)
	await tween.finished
	loading_screen_ready.emit()

func on_progress_changed(_value: float) -> void:
	pass

func on_load_finished() -> void:
	animation_player.play_backwards("Transition")
	await animation_player.animation_finished
	queue_free()
