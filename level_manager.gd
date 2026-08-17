extends Node

func _ready() -> void:
	await get_tree().process_frame
	var pickups := get_tree().get_nodes_in_group("burger_pickup")
	print("Found ", pickups.size(), " burgers")
	for pickup in pickups:
		pickup.collected.connect(_on_burger_collected)

func _on_burger_collected(id: String) -> void:
	print("Burger collected: ", id)

	# existing platform logic unchanged
	var platform_group : String = "platform_" + id
	var platforms := get_tree().get_nodes_in_group(platform_group)
	print("Unlocking group: ", platform_group, " found ", platforms.size(), " platforms")
	for platform in platforms:
		platform.visible = true
		for child in platform.get_children():
			if child is CollisionShape3D:
				child.disabled = false

	# new door logic
	var door_group : String = "door_" + id
	var doors := get_tree().get_nodes_in_group(door_group)
	print("Opening doors: ", door_group, " found ", doors.size(), " doors")
	for door in doors:
		if door.has_method("open"):
			door.open()
