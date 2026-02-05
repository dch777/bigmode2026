shader_type canvas_item;

uniform float noise_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float seed;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = round(UV * 32.0) / 32.0;
    float noise = random(vec2(round(uv.y * 32.0 + TIME * (1.0 - UV.x) + seed))) * 2.0 - 1.0;

    COLOR.a += noise * noise_intensity;
	//COLOR.a = UV.x;
	//COLOR.a *= -4.0 * UV.y * (UV.y - 1.0);
}
