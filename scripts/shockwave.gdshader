shader_type canvas_item;

uniform vec3 color : source_color;
uniform vec3 boundary_color : source_color;

uniform sampler2D noise : source_color;
uniform float value : hint_range(0.0, 1.0);

void fragment() {
	float transparency = 1.0 - (min(1.0, pow(value, 4.5)));
	
	float boundary = 0.0;
	
	vec2 uv = UV - 0.5;
	uv *= 2.0;
	float nois = texture(noise, UV).r;
	float grad = length(uv + (nois * 0.2));
	grad = smoothstep(value - 0.4, value, grad);
	float v = smoothstep(0.0, 0.1 + (nois * 0.2), grad) - smoothstep(0.2, 0.35, grad);
	
	boundary = step(0.1, v) - step(0.4, v);
	v = step(0.7, v);
	
	float total = 0.;
	
	for (int i = 0; i < 4; i++) {
		float nois2 = texture(noise, UV).r;
		float grad2 = length(uv + (nois2 * 0.2));
		grad2 = smoothstep(value - (float(i) * 0.1), value - 0.6, grad2);
		
		float r = smoothstep(0.0, 0.1 + (nois2 * 0.5), grad2) - smoothstep(0.2, 0.35, grad2);
		boundary += step(0.1, r) - step(0.25, r);
		r = step(0.85, r);

		
		total += r; 
		
	}
	
		
	float mask = texture(noise, UV * 0.4).r;
	mask = smoothstep(0.4, 0.45, mask);
	mask *= (1.0 - (transparency * 0.4));
	
	COLOR.a = total + v;
	COLOR.a *= transparency * mask;
	COLOR.rgb = mix(color, boundary_color, boundary);

	//COLOR.rgb = vec3(mask);
}
