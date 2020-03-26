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
	$Canvas.rect_size = canvas_size
	$Canvas.material.set_shader_param("canvas_size", canvas_size)
	
	var elements = get_parent().elements
	var img = Image.new()
	img.create(128, 128, false, Image.FORMAT_RGBA8)
	
	img.fill(Color.black)
	img.lock()
	for element in get_parent().elements:
		print(element)
	img.set_pixel(0, 0, Color.white)
	img.set_pixel(2, 0, Color.white)
	img.unlock()
	
	var tex = ImageTexture.new()
	var a = tex.create_from_image(img)
	$Canvas.material.set_shader_param("elements", tex)
