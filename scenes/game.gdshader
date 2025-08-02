shader_type canvas_item;

uniform float noise_intensity : hint_range(0, 1) = 0.3;
uniform float noise_speed : hint_range(0, 10) = 1.0;

void fragment() {
    // Get the original texture color (or white if no texture)
    vec4 tex_color = texture(TEXTURE, UV);
    if (tex_color.a == 0.0) {
        tex_color = vec4(1.0); // Fallback if texture is missing/transparent
    }

    // Generate noise (0 to 1 range)
    float noise = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453 + TIME * noise_speed);

    // Apply noise while clamping to valid color range
    tex_color.rgb += (noise - 0.5) * noise_intensity;
    tex_color.rgb = clamp(tex_color.rgb, 0.0, 1.0); // Prevent overflow

    COLOR = tex_color;
}