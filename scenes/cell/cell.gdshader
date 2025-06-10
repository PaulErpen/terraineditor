shader_type spatial;

uniform float brush_radius = 3.0;
uniform vec2 brush_position = vec2(0.0);

uniform float height_scale = 10.0;
uniform sampler2D displacement_texture;
uniform float normal_sample_scale = 0.02;

varying float height;

float sample_height(vec2 uv) {
	ivec2 texel_size = textureSize(displacement_texture, 0);
	ivec2 iuv = ivec2(
		int(round(uv.x * float(texel_size.x - 1))),
		int(round(uv.y * float(texel_size.y - 1)))
	);
	float height_value = texelFetch(displacement_texture, iuv, 0).r;
	return height_value;
}

vec3 calculate_normal(vec2 uv) {
	// Calculate the normal based on the height map.
	// float height_top = sample_height(uv + vec2(sin(0), cos(0)) * normal_sample_scale);
	// float height_right = sample_height(uv + vec2(sin(0.66 * PI), cos(0.66 * PI)) * normal_sample_scale);
	// float height_left = sample_height(uv + vec2(sin(1.33 * PI), cos(1.33 * PI)) * normal_sample_scale);
// 
	// vec3 top = vec3(sin(0), height_top, cos(0));
	// vec3 right = vec3(sin(0.66 * PI), height_right, cos(0.66 * PI));
	// vec3 left = vec3(sin(1.33 * PI), height_left, cos(1.33 * PI));
	// vec3 normal = normalize(cross(right - top, left - top));
	return vec3(0.0, 1.0, 0.0);
}

void vertex() {
	// Called for every vertex the material is visible on.
	height = sample_height(UV);

	POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX.x, VERTEX.y + height * height_scale, VERTEX.z, 1.0);

    NORMAL = calculate_normal(UV);
}

void fragment() {
	float dist = distance(UV, brush_position);
	float scaled_radius = brush_radius / float(textureSize(displacement_texture, 0).x);
	
	float height_color = (height + 1.0) / 2.0;
	
	if (scaled_radius < dist && dist < scaled_radius + 0.01) {
		ALBEDO = vec3(clamp(1.0 + height_color, 0.0, 1.0));
	} else {
		ALBEDO = vec3(height_color);
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
