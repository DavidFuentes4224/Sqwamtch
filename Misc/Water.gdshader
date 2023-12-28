shader_type spatial;
uniform sampler2D NOISE_PATTERN;
uniform sampler2D WATER_TEXTURE;
uniform float HeightOffset = 10.0;
uniform float Speed = 4.0;
uniform vec2 WaterDirection;

void vertex() {
	vec2 uv = WaterDirection * TIME * Speed * 0.001;
	float height = texture(NOISE_PATTERN,UV+uv).r;
	VERTEX.y = height * HeightOffset;
}

void fragment() {
	ALBEDO = texture(WATER_TEXTURE,UV).rgb;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
