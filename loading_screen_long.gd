extends CanvasLayer

signal loading_screen_ready

@export var animation_player : AnimationPlayer
@export var progress_bar : ProgressBar
@export var percentage_label : Label
@export var min_display_time : float = 3.0

var update_value : float = 0.0
var is_loading : bool = false

func _ready() -> void:
	progress_bar.max_value = 1.0
	progress_bar.value = 0.0
	await animation_player.animation_finished
	await get_tree().create_timer(min_display_time).timeout
	is_loading = true
	loading_screen_ready.emit()

func on_progress_changed(value: float) -> void:
	if value > update_value:
		update_value = value

func _process(delta: float) -> void:
	if not is_loading:
		return
	if progress_bar.value < update_value:
		progress_bar.value = lerp(progress_bar.value, update_value, delta)
	progress_bar.value += delta * 0.2 * \
		(0.5 if update_value >= 1.0 else clamp(0.9 - progress_bar.value, 0.0, 1.0))
	percentage_label.text = str(int(progress_bar.value * 100.0)) + " %"

func on_load_finished() -> void:
	progress_bar.value = 1.0
	percentage_label.text = "100 %"
	animation_player.play_backwards("Transition")
	await animation_player.animation_finished
	queue_free()
