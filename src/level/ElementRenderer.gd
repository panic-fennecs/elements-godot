extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
