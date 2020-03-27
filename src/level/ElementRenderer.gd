extends Node2D

onready var start_time = OS.get_ticks_msec();

func _ready():
	pass

func _process(delta):
	var world_size = $"/root/Main/Level".WORLD_SIZE
	
	var elapsed_time = (OS.get_ticks_msec() - start_time) / 1000.0; # seconds
	$Canvas.material.set_shader_param("elapsed_time", elapsed_time)

	var fluid_manager = $"../FluidManager"
	var fluid_grid = fluid_manager.create_grid()
	var fluid_tex = Texture3D.new()
	fluid_tex.create(fluid_manager.FLUID_GRID_SIZE_X, fluid_manager.FLUID_GRID_SIZE_Y, fluid_manager.FLUID_GRID_SIZE_Z, Image.FORMAT_RGBAF, 0)

	for z in range(fluid_manager.FLUID_GRID_SIZE_Z):
		var fluid_img = Image.new()
		fluid_img.create(fluid_manager.FLUID_GRID_SIZE_X, fluid_manager.FLUID_GRID_SIZE_Y, false, Image.FORMAT_RGBAF)
		fluid_img.fill(Color.black)
		fluid_img.lock()

		for x in range(fluid_manager.FLUID_GRID_SIZE_X):
			for y in range(fluid_manager.FLUID_GRID_SIZE_Y):
				var fluid = fluid_manager.get_fluid(fluid_grid, Vector3(x, y, z))
				if fluid:
					var pos = fluid.position / world_size
					fluid_img.set_pixel(x, y, Color(pos.x, pos.y, 1, 1))

		fluid_img.unlock()
		fluid_tex.set_layer_data(fluid_img, z)
	$Canvas.material.set_shader_param("fluid_tex", fluid_tex)

	var solid_manager = $"../SolidManager"
	var solid_grid = solid_manager.solid_grid
	var solid_tex = ImageTexture.new()
	var solid_img = Image.new()
	solid_img.create(solid_manager.SOLID_GRID_SIZE_X, solid_manager.SOLID_GRID_SIZE_Y, false, Image.FORMAT_RGBAF)
	solid_img.fill(Color.black)
	solid_img.lock()
	for x in range(solid_manager.SOLID_GRID_SIZE_X):
		for y in range(solid_manager.SOLID_GRID_SIZE_Y):
			var solid = solid_manager.get_cell(x, y)
			solid_img.set_pixel(x, y, Color(solid, 0, 0, 0))
	solid_img.unlock()
	solid_tex.create_from_image(solid_img, 0)
	$Canvas.material.set_shader_param("solid_tex", solid_tex)
