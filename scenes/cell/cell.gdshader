shader_type spatial;

uniform float brush_radius = 3.0;
uniform vec2 brush_position = vec2(0.0);

uniform float height_scale = 10.0;
uniform sampler2D displacement_texture;
uniform float normal_sample_scale = 5.0;

varying float height;
varying vec2 tex_uv;

float sample_height(ivec2 iuv) {
	float height_value = texelFetch(displacement_texture, iuv, 0).r;
	return height_value;
}

ivec2 get_iuv(vec2 uv) {
	ivec2 texel_size = textureSize(displacement_texture, 0);
	ivec2 iuv = ivec2(
		int(round(1.0 + uv.x * float(texel_size.x - 3))),
		int(round(1.0 + uv.y * float(texel_size.y - 3)))
	);
	return iuv;
}

vec3 calculate_normal(ivec2 iuv) {
	// Calculate the normal based on the height map.
	float height_top = sample_height(ivec2(iuv.x, iuv.y + 1));
	float height_right = sample_height(ivec2(iuv.x + 1, iuv.y));
	float height_left = sample_height(ivec2(iuv.x - 1, iuv.y - 1));
	vec3 top = vec3(sin(0), height_top, cos(0));
	vec3 right = vec3(sin(0.66 * PI), height_right, cos(0.66 * PI));
	vec3 left = vec3(sin(1.33 * PI), height_left, cos(1.33 * PI));
	vec3 normal = normalize(cross(right - top, left - top));
	return normal;
}

void vertex() {
	// Called for every vertex the material is visible on.
	ivec2 iuv = get_iuv(UV);
	height = sample_height(iuv);

	POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX.x, VERTEX.y + height * height_scale, VERTEX.z, 1.0);

    NORMAL = calculate_normal(iuv);

	float size = float(textureSize(displacement_texture, 0).x - 1);
	tex_uv = vec2(float(iuv.x), float(iuv.y)) / size;
}

void fragment() {
	float dist = distance(tex_uv, brush_position);
	float scaled_radius = brush_radius / float(textureSize(displacement_texture, 0).x - 3);

	float height_color = (height + 1.0) / 2.0;

	if (scaled_radius < dist && dist < scaled_radius + 0.01) {
		ALBEDO = vec3(clamp(0.0, 0.0, 0.0));
	} else {
		ALBEDO = vec3(1.0);
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
