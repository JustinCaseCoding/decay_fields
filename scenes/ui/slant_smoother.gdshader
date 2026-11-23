shader_type canvas_item;

uniform float slant : hint_range(0.0, 1.0) = 0.15;
uniform float right_edge = 450.0;

void fragment() {
	float d = VERTEX.x + slant * VERTEX.y - right_edge;
	float aa = fwidth(d);
	COLOR.a *= smoothstep(0.0, aa, -d);
}