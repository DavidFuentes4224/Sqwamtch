shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

group_uniforms Textures;
uniform sampler2D NOISE_PATTERN;
uniform sampler2D NOISE_PATTERN_NORMAL:hint_normal;
uniform sampler2D TERRAIN_TOP:source_color;
uniform sampler2D TERRAIN_SECONDARY:source_color;
uniform sampler2D TERRAIN_SIDE:source_color;

group_uniforms Scale;
uniform float TextureScale : hint_range(1,20);
uniform float UVx;
uniform float UVy;
uniform float HeightInfulence : hint_range(1,4000);
uniform float TriPlanar_Blend : hint_range(0,15);
uniform float Secondary_Blend : hint_range(0,2);

varying vec2 tex_position;
varying vec3 vert_position;
varying vec3 vert_normal_IWS;

vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

vec3 unpack_normal_map(vec4 rgba)
{
	vec3 n = rgba.xzy * 2.0 - vec3(1.0);
	n.z *= -1.0;
	return n;
}

void vertex() {
	vec2 uv = vec2(UV.x + UVx, UV.y + UVy);
	tex_position = uv;
	float height = texture(NOISE_PATTERN, uv).x;
  	VERTEX.y += height * HeightInfulence;
	vec4 normal = texture(NOISE_PATTERN_NORMAL, uv);
	NORMAL = unpack_normal_map(normal);
	vert_position = (MODEL_MATRIX * vec4(VERTEX, 1.0f)).xyz * (1.0/TextureScale) * 0.5;
	vert_position *=vec3(1.0,-1.0, 1.0);
	vert_normal_IWS = MODEL_NORMAL_MATRIX * NORMAL;
	vert_normal_IWS = pow(abs(vert_normal_IWS),vec3(TriPlanar_Blend));
	vert_normal_IWS/=dot(vert_normal_IWS,vec3(1.0));
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 normal = unpack_normal_map(texture(NOISE_PATTERN_NORMAL, tex_position));
	normal = normalize(normal);
	NORMAL = (VIEW_MATRIX * vec4(normal, 0.0)).xyz;

	vec3 topColor = texture(TERRAIN_TOP, vert_position.xz).rgb;
	vec3 topSecondary = texture(TERRAIN_SECONDARY, vert_position.xz).rgb;
	
	vec3 sideColorX = texture(TERRAIN_SIDE, vert_position.yz).rgb * 0.8;
	vec3 sideColorZ = texture(TERRAIN_SIDE, vert_position.xy).rgb * 0.8;
	
	vec3 normalIWS = abs(vert_normal_IWS);
	vec3 normalWeights = normalIWS / (normalIWS.x + normalIWS.y + normalIWS.z);
	
	float angle = atan(normalIWS.z, normalIWS.x);
	float blendFactor = (angle + PI) / (2.0 * PI);
	
	vec3 topWeight = mix(topColor, topSecondary, clamp((blendFactor * Secondary_Blend),0.0 ,1.0));
	ALBEDO = (sideColorX * normalWeights.x) + (sideColorZ * normalWeights.z) + (topWeight * normalWeights.y);
}
