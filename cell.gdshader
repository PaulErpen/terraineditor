shader_type spatial;

uniform sampler2D displacement_texture;

void vertex() {
	// Called for every vertex the material is visible on.
	float height = texture(displacement_texture, UV).x;

	POSITION = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX.x, VERTEX.y + height, VERTEX.z, 1.0);

	vec2 texel_size = vec2(1.0 / 2.0, 1.0 / 2.0); // e.g., (1.0 / texture_width, 1.0 / texture_height)

    float height_x = texture(displacement_texture, UV + vec2(0.07, 0.0)).r;
    float height_y = texture(displacement_texture, UV + vec2(0.0, 0.07)).r;

    float dx = height_x - height;
    float dy = height_y - height;

    NORMAL = normalize(vec3(-dx, 1.0, -dy));
}

void fragment() {

}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
