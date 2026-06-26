extends MeshInstance3D

@export var rise_speed = 0.5        # how fast it rises
@export var rise_every_minutes = 0.5 # how long it waits before rising again
@export var max_height = 10.0       # stops at this Y position
@export var pause_duration = 10  # how many seconds it pauses at the top

var timer = 0.0
var pause_timer = 0.0
var rising = false
var pausing = false

func _process(delta):
	timer += delta
	
	if timer >= rise_every_minutes * 60.0 and not pausing:
		rising = true
		timer = 0.0
	
	if rising:
		position.y += rise_speed * delta
		
		if position.y >= max_height:
			position.y = max_height
			rising = false
			pausing = true
			pause_timer = 0.0
	
	if pausing:
		pause_timer += delta
		
		if pause_timer >= pause_duration:
			pausing = false
			timer = 0.0
