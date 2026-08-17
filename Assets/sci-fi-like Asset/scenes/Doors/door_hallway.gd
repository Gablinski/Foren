extends MeshInstance3D

@onready var animation : AnimationPlayer = $AnimationPlayer

func open() -> void:
	animation.play("Open")
