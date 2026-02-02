shader_type particles;

uniform vec2 window_size;
uniform vec2 explosion;
uniform bool is_exploding = false;

float seed(float init) {
    return fract(sin(dot(vec2(init), vec2(12.9898,78.233))) * 43758.5453123);
}

float random(float r) {
	return seed(1000.0 * r);
}

void start() {
	TRANSFORM = EMISSION_TRANSFORM;
	
	CUSTOM.y = seed(TIME + (1000.0 * CUSTOM.y));
	TRANSFORM[0].xy = vec2(0.5 * CUSTOM.y + 0.5, 0.0);
	TRANSFORM[1].xy = vec2(0.0, 0.5 * CUSTOM.y + 0.5);
	
	CUSTOM.y = random(CUSTOM.y);
	TRANSFORM[3].x += 2.0 * EMITTER_VELOCITY.x + window_size.x * CUSTOM.y - window_size.x / 2.0;
	CUSTOM.y = seed(CUSTOM.y);
	TRANSFORM[3].y += 2.0 * EMITTER_VELOCITY.y + window_size.y * CUSTOM.y - window_size.y / 2.0;
	
	CUSTOM.y = random(CUSTOM.y);
	CUSTOM.y = random(CUSTOM.y);
	VELOCITY.x += 50.0 * CUSTOM.y - 25.0;
	CUSTOM.y = random(CUSTOM.y);
	VELOCITY.y += 50.0 * CUSTOM.y - 25.0;
	
	if (is_exploding) {
		vec2 dir = normalize(TRANSFORM[3].xy - explosion);
		VELOCITY.xy += dir * 1000.0;
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
		CUSTOM.z = 0.0;
	} else {
		VELOCITY -= EMITTER_VELOCITY * 0.1 * CUSTOM.y;
		COLOR = vec4(0.75, 0.8, 0.86, 1.0);
		CUSTOM.z = 1.0;
	}
}

void process() {
	if (RESTART || CUSTOM.x > 1.0) {
		CUSTOM.x = 0.0;
	} else {
		CUSTOM.x += DELTA / LIFETIME;
	}
		
	CUSTOM.y = random(CUSTOM.y);
	VELOCITY *= 0.95;
	if (!is_exploding) {
		VELOCITY -= EMITTER_VELOCITY * 0.1 * CUSTOM.y;
		COLOR.a = 9.0 * (CUSTOM.x + 0.02) * exp(6.0 * -CUSTOM.x);
	} else {
		vec2 dir = normalize(TRANSFORM[3].xy - explosion);
		VELOCITY.xy += dir * 10.0;
		VELOCITY.xy += dir * 1000.0 * CUSTOM.z;
		CUSTOM.z = 0.0;
	}
}
