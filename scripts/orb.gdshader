shader_type canvas_item;

uniform float custom_time;
uniform float time_speed : hint_range(0.1, 80.0) = 1.5;
uniform vec4 main_color = vec4(0.7, 0.2, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.1, 5.0) = 1.2;
uniform float distortion_amount : hint_range(0.0, 0.8) = 0.2;

void fragment() {
    vec2 uv = UV;
  
    // Ensure time moves even if Engine.time_scale is slow
    float animated_time = custom_time * time_speed;

    // Wave effect using custom_time
    float wave = sin(custom_time * time_speed + uv.x * 20.0) * 0.2;
    
    // Distort UV for magical effect
    uv.y += wave * distortion_amount;
    
    // Glow based on distance from center
    float dist = length(uv - vec2(0.5));
    float glow = smoothstep(0.5, 0.2, dist) * glow_intensity;
    
    // Final color output
    vec4 color = main_color;
    color.a *= glow;
    
    COLOR = color;
}
