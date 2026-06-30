extends CanvasLayer

signal loading_screen_ready

@export var animation_player : AnimationPlayer
@export var progress_bar : ProgressBar
@export var percentage_label : Label
@export var spinner : TextureRect

var update_value : float = 0.0

func _ready() -> void:
	progress_bar.max_value = 1.0
	progress_bar.value = 0.0
	await animation_player.animation_finished
	loading_screen_ready.emit()

func _process(delta: float) -> void:
	spinner.rotation_degrees += 180.0 * delta
	var target : float = 0.5 if update_value >= 1.0 else clamp(update_value + (0.9 - progress_bar.value) * delta * 0.5, 0.0, 0.9)
	progress_bar.value = lerp(progress_bar.value, target, delta * 3.0)
	percentage_label.text = str(int(progress_bar.value * 100))

func on_progress_changed(value: float) -> void:
	if value > update_value:
		update_value = value

func on_load_finished() -> void:
	progress_bar.value = 1.0
	percentage_label.text = "100"
	animation_player.play_backwards("Transition")
	await animation_player.animation_finished
	queue_free()
