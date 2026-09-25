shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
void fragment() {
 vec2 centered = SCREEN_UV * 2.0 - 1.0;
 vec2 uv = SCREEN_UV + centered * dot(centered, centered) * 0.003;
 vec2 separation = vec2(SCREEN_PIXEL_SIZE.x * 0.35, 0.0);
 vec3 color = vec3(texture(screen_texture, uv + separation).r,
                   texture(screen_texture, uv).g,
                   texture(screen_texture, uv - separation).b);
 // Stable scanlines and phosphor texture; no flashing or temporal noise.
 float scan = 0.95 + 0.05 * cos(FRAGCOORD.y * 3.14159265);
 float phosphor = 0.985 + 0.015 * cos(FRAGCOORD.x * 2.0943951);
 float vignette = 1.0 - 0.13 * pow(length(centered) / 1.4142, 2.0);
 float inside = step(0.0, uv.x)*step(uv.x, 1.0)*step(0.0, uv.y)*step(uv.y, 1.0);
 COLOR = vec4(color * scan * phosphor * vignette * 1.035 * inside, 1.0);
}
