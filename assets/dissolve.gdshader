shader_type canvas_item;

uniform sampler2D noise;
uniform float value : hint_range(0, 1);
uniform vec2 center_offset;
uniform float custom_time;

void fragment() {
	
	//float n = texture(noise, 1.0 - vec2(UV.x, mod(UV.y + TIME * 2.5, 1.0)) ).r;
	//n = smoothstep(0.4, 0.8, n);
	float t = custom_time;  
	vec2 uv = UV + vec2(sin(t), cos(t)) * 0.05; 
	float nois = texture(noise, UV).r * ((value * 3.0));
	
	float grad = smoothstep(value - 0.2, value, length(uv - 0.5 + center_offset));
	
	float m = smoothstep(nois * 0.5, nois + 0.4, grad);
	
	float flame = step(0.2, m) - step(1., m); 
	
	COLOR.a *= m;

	COLOR.rgb = mix(COLOR.rgb, vec3(1., 0.3, 0.2) * 2.0, flame);
}
