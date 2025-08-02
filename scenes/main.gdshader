    shader_type canvas_item;

    void fragment() {
        // Get the original color of the pixel
        COLOR = texture(TEXTURE, UV);

        // Calculate the grayscale value (average of RGB channels)
        float avg = (COLOR.r * 1.0);

        // Set the RGB channels to the grayscale value, keeping the original alpha
        COLOR.rgb = vec3(avg);
    }