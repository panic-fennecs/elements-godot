extends Node2D

onready var start_time = OS.get_ticks_msec();

func _ready():
	pass

func _process(delta):
	var elapsed_time = (OS.get_ticks_msec() - start_time) / 1000.0; # seconds
	$Canvas.material.set_shader_param("elapsed_time", elapsed_time)

	var canvas_size = get_viewport().size
	var aspect_ratio = canvas_size.x / canvas_size.y
	
	$Canvas.rect_size = canvas_size
	$Canvas.material.set_shader_param("canvas_size", canvas_size)
	
	var elements = $"../FluidManager".fluids
	var img = Image.new()
	img.create(128, 1, false, Image.FORMAT_RGBAF)
	
	img.fill(Color.black)
	img.lock()
	var x = 0
	for element in elements:
		if x < 128:
			var pos = element.position / canvas_size * Vector2(aspect_ratio, 1)
			img.set_pixel(x, 0, Color(pos.x, pos.y, 1, 1))
			x = x + 1
	img.unlock()
	
	var tex = ImageTexture.new()
	tex.create_from_image(img, 0)
	$Canvas.material.set_shader_param("elements_tex", tex)
