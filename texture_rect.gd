extends TextureRect

func _ready():
	var tex = AnimatedTexture.new()
	var frame_count = 50
	tex.frames = frame_count
	for i in range(frame_count):
		var frame_path = "res://ezgif-split-png/frame_%02d_delay-0.1s.png" % i
		tex.set_frame_texture(i, load(frame_path))
		tex.set_frame_duration(i, 0.1)
	texture = tex
