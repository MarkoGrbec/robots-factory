shader_type canvas_item;

uniform float a: hint_range(1.0, 250.0, 0.01) = 50.0;
uniform float b: hint_range(1.0, 100.0, 0.01) = 50.0;
uniform float c: hint_range(1.0, 100.0, 0.01) = 50.0;
uniform float d: hint_range(1.0, 100.0, 0.01) = 50.0;
uniform float speed: hint_range(0.1, 5.0, 0.01) = 0.05;

void fragment() {
	vec2 uv = -UV;
	float color = 1.0 - fract((a * uv.x + b * uv.y) * fract(c * uv.x) + TIME * speed) * d;
	COLOR = vec4(color);
}
