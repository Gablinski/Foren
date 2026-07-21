extends CanvasLayer

@export var animation_player : AnimationPlayer
@export var display_duration : float = 2.0

func _ready() -> void:
	animation_player.play("FadeIn")
	await animation_player.animation_finished
	await get_tree().create_timer(display_duration).timeout
	animation_player.play("FadeOut")
	await animation_player.animation_finished
	SceneLoader.load_scene("res://main_menu.tscn", "long")
