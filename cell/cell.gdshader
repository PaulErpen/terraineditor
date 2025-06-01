shader_type spatial;

uniform float height_scale = 10.0;
uniform sampler2D displacement_texture;
uniform float normal_sample_scale = 0.02;

varying vec3 normal_buff;

float sample_height(vec2 uv) {
	ivec2 texel_size = textureSize(displacement_texture, 0);
	ivec2 texel_coord = ivec2(uv * vec2(texel_size));
	texel_coord = clamp(texel_coord, ivec2(0), texel_size - ivec2(1));
	return texelFetch(displacement_texture, texel_coord, 0).r;
}

vec3 calculate_normal(vec2 uv) {
	// Calculate the normal based on the height map.
	float height_top = sample_height(uv + vec2(sin(0), cos(0)) * normal_sample_scale);
	float height_right = sample_height(uv + vec2(sin(0.66 * PI), cos(0.66 * PI)) * normal_sample_scale);
	float height_left = sample_height(uv + vec2(sin(1.33 * PI), cos(1.33 * PI)) * normal_sample_scale);

	vec3 top = vec3(sin(0), height_top, cos(0));
	vec3 right = vec3(sin(0.66 * PI), height_right, cos(0.66 * PI));
	vec3 left = vec3(sin(1.33 * PI), height_left, cos(1.33 * PI));
	vec3 normal = normalize(cross(right - top, left - top));
	return normal;
}

void vertex() {
	// Called for every vertex the material is visible on.
	float height = sample_height(UV);

	POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX.x, VERTEX.y + height * height_scale, VERTEX.z, 1.0);

    NORMAL = calculate_normal(UV);

	normal_buff = vec3(height);
}

void fragment() {
	ALBEDO = normal_buff.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
