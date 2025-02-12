shader_type canvas_item;

uniform sampler2D dissolve_texture; // Noise texture for the dissolve effect
uniform float dissolve_amount : hint_range(0.0, 1.0); // 0 = visible, 1 = dissolved
uniform vec4 dissolve_color; // Glow color for edges

void fragment() {
    vec4 albedo = texture(TEXTURE, UV);
    float noise = texture(dissolve_texture, UV).r; // Get noise value

    if (noise < dissolve_amount) {
        discard; // Remove pixels where noise is less than dissolve amount
    }

    // Edge glow effect
    float edge = smoothstep(dissolve_amount - 0.05, dissolve_amount, noise);
    vec4 glow = edge * dissolve_color;

    COLOR = albedo + glow; // Apply glow effect
}
