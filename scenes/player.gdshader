shader_type canvas_item;

uniform float noise_intensity : hint_range(0, 1) = 0.3;
uniform float noise_speed : hint_range(0, 10) = 1.0;

void fragment() {
    // Generate time-varying noise
    float noise = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453 + TIME * noise_speed);
    COLOR = texture(TEXTURE, UV) + (noise - 0.5) * noise_intensity;
}