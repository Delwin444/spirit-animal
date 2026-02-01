shader_type canvas_item;

uniform vec3 tint_col : source_color;
uniform vec2 position;
uniform float radius;
uniform float intensity;
varying vec2 world_pos;

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 col = texture(TEXTURE, UV);

    float sd = (1.0 - clamp(sdCircle(world_pos - position, radius) / 1000., 0.0, 1.0)) / 2.;
	
	vec3 tinted = vec3(col.r + (sd * (tint_col.r - .5) * 4.), col.g + (sd * (tint_col.g - .5) * 4.), col.b + (sd * (tint_col.b - .5) * 4.));

    COLOR = vec4(tinted, col.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
