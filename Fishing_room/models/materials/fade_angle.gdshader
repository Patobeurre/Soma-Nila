shader_type spatial;
render_mode blend_mix;

// Uniform for your custom texture
uniform sampler2D albedo_texture : source_color;
uniform vec4 main_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Controls how sharp the fade is
uniform float fade_power : hint_range(0.1, 10) = 2.0;

void fragment() {
    // Get view direction (from camera to fragment)
    vec3 view_dir = normalize(-VERTEX);

    // Calculate how much the surface is facing the camera
    float facing = dot(NORMAL, view_dir);

    // Clamp to [0,1] instead of saturate()
    float alpha = pow(clamp(facing, 0.0, 1.0), fade_power);

    // Sample the texture
    vec4 tex_color = texture(albedo_texture, UV);

    // Apply fade to the texture's alpha
    ALBEDO = main_color.rgb;
	//ALBEDO = tex_color.rgb;
    ALPHA = tex_color.a * alpha;
}