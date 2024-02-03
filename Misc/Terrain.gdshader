shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

group_uniforms Masks;
uniform sampler2D NOISE_PATTERN;
uniform sampler2D NOISE_PATTERN_NORMAL:hint_normal;
uniform sampler2D TEXTURE_MASK:source_color;
uniform float PathThreshold:hint_range(0.0,0.5)= 0.1;
uniform float PathScale:hint_range(0.0, 2.0, 0.1);

group_uniforms Textures;
uniform sampler2D TERRAIN_TOP:source_color;
uniform sampler2D TERRAIN_SECONDARY:source_color;
uniform sampler2D TERRAIN_PATH:source_color;
uniform sampler2D TERRAIN_SIDE:source_color;

group_uniforms Scale;
uniform float TextureScale : hint_range(1,20);
uniform float HeightInfulence : hint_range(1,4000);
uniform float TriPlanar_Blend : hint_range(0,15);

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
	tex_position = UV;
	float height = texture(NOISE_PATTERN, UV).r;
  	VERTEX.y += height * HeightInfulence;
	vec4 normal = texture(NOISE_PATTERN_NORMAL, UV);
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
	
	vec2 terrainTexturePos = vert_position.xz;
	vec3 terrainColor = vec3(0.0);
	vec3 terrainMask = texture(TEXTURE_MASK, UV).rgb;
	
	vec3 topPrimary = texture(TERRAIN_TOP, terrainTexturePos).rgb;
	vec3 topSecondary = texture(TERRAIN_SECONDARY, terrainTexturePos).rgb;
	vec3 topColor = mix(topPrimary, topSecondary, terrainMask.b);
	terrainColor = topColor;
		
	bool usePath = step(PathThreshold, terrainMask.g) > 0.0;
	if (usePath)
	{
		vec3 pathColor = texture(TERRAIN_PATH, terrainTexturePos).rgb;
		float mixPower = smoothstep(0.5, 1.0, terrainMask.g * PathScale);
		terrainColor = mix(topColor, pathColor, mixPower);
	}
	
	//terrainColor = mix(vec3(1), vec3(1.0,0.0,0.0) * terrainMask.b, 0.5);
	vec3 sideColorX = texture(TERRAIN_SIDE, vert_position.yz).rgb;
	vec3 sideColorZ = texture(TERRAIN_SIDE, vert_position.xy).rgb;
	
	vec3 normalIWS = abs(vert_normal_IWS);
	vec3 normalWeights = normalIWS / (normalIWS.x + normalIWS.y + normalIWS.z);
	
	ALBEDO = (sideColorX * normalWeights.x) + (sideColorZ * normalWeights.z) + (terrainColor * normalWeights.y);
}
