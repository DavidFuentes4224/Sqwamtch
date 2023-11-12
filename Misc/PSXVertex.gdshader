shader_type spatial;
render_mode vertex_lighting, diffuse_lambert_wrap;

uniform sampler2D image_texture: source_color;
uniform vec2 uv_scrolling_velocity = vec2(0.0);
uniform float vertex_snapping_offset : hint_range(0,1.0) = 0.69;
uniform bool jitter_z_coordinate = true;
uniform bool jitter_depth_independent = true;
uniform bool affine_texture_mapping = true;
uniform float alpha_scissor: hint_range(0.0, 1.0) = 1.0;

void vertex() {
    NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
}

void fragment() {
	vec2 uv = UV;
	ALBEDO = texture(image_texture, uv).rgb * COLOR.rgb;
}
