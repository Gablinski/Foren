extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("enter_ladder"):
		body.enter_ladder(global_transform)

func _on_body_exited(body: Node3D) -> void:
	if body.has_method("exit_ladder"):
		body.exit_ladder()
