shader_type spatial;
uniform sampler2D TEXTURE:source_color;
uniform vec4 TopColor:source_color;
uniform vec4 BottomColor:source_color;
uniform float swaySpeed = 1.25;
uniform float swayDistance = 0.25;

varying vec3 vert;

void vertex() {
	VERTEX.x += sin(NODE_POSITION_WORLD.x + TIME * swaySpeed ) * (UV.y) * swayDistance;
	vert = VERTEX;
	NORMAL = vec3(0.0,1.0,0.0);
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 main = texture(TEXTURE, UV);
	ALBEDO = mix(BottomColor, TopColor, vert.y).rgb;
	ALPHA = main.a;
	NORMAL *= FRONT_FACING ? 1.0 : -1.0;
	SPECULAR = 0.5;
	ROUGHNESS = 1.0;
	// Called for every pixel the material is visible on.
}
