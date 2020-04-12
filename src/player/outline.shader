shader_type canvas_item;

uniform float outline_width = 2.0;
uniform vec4 outline_color: hint_color;
uniform int layers = 5;
uniform float fineness = 1.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);

	if (col.a < 0.9 && outline_width != 0.0) {
		vec2 ps = TEXTURE_PIXEL_SIZE;
		float maxa;

		for (int layer = 1; layer <= layers; layer++) {
			maxa = 0.0;

			for (float x = -1.0; x <= 1.0; x+=fineness) {
				for (float y = -1.0; y <= 1.0; y+=fineness) {
					if (x == 0.0 && y == 0.0) {
						continue;
					}
					maxa = max(texture(TEXTURE, UV + vec2(float(x), float(y)) * ps * float(layer) * outline_width).a, maxa);
				}
			}
			if (maxa > 0.2) {
				maxa = float(layers - layer + 1) / float(layers);
				break;
			}
		}

		COLOR = mix(vec4(0.0, 0.0, 0.0, 0.0), outline_color, maxa);
	} else {
		COLOR = col;
	}

}