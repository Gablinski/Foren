extends Node

func _ready() -> void:
	var pickups := get_tree().get_nodes_in_group("burger_pickup")
	print("Found ", pickups.size(), " burgers")
	for pickup in pickups:
		pickup.collected.connect(_on_burger_collected)

func _on_burger_collected(id: String) -> void:
	print("Burger collected: ", id)
	var group_name : String = "platform_" + id
	var platforms := get_tree().get_nodes_in_group(group_name)
	print("Unlocking group: ", group_name, " found ", platforms.size(), " platforms")
	for platform in platforms:
		platform.visible = true
		for child in platform.get_children():
			if child is CollisionShape3D:
				child.disabled = false
