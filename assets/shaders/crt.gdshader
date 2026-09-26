shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float curvature : hint_range(0.0, 0.02) = 0.008;
uniform float scanline_strength : hint_range(0.0, 0.3) = 0.16;
uniform float color_fringe : hint_range(0.0, 1.5) = 0.8;
void fragment() {
 vec2 centered = SCREEN_UV * 2.0 - 1.0;
 vec2 uv = SCREEN_UV + centered * dot(centered, centered) * curvature;
 vec2 separation = vec2(SCREEN_PIXEL_SIZE.x * color_fringe, 0.0);
 vec3 color = vec3(texture(screen_texture, uv + separation).r,
                   texture(screen_texture, uv).g,
                   texture(screen_texture, uv - separation).b);
 // A little bright-pixel bleed suggests glowing phosphors without blurring the scene.
 vec2 pixel = SCREEN_PIXEL_SIZE;
 vec3 halo = (texture(screen_texture, uv + vec2(pixel.x, 0.0)).rgb
            + texture(screen_texture, uv - vec2(pixel.x, 0.0)).rgb
            + texture(screen_texture, uv + vec2(0.0, pixel.y)).rgb
            + texture(screen_texture, uv - vec2(0.0, pixel.y)).rgb) * 0.25;
 color += max(halo - vec3(0.35), vec3(0.0)) * 0.12;
 // Three-pixel spacing avoids the half-pixel sampling cancellation of a two-pixel cosine.
 // Both patterns are stationary: no flashing, rolling bars, or temporal noise.
 float scan = 1.0 - scanline_strength + scanline_strength * cos(FRAGCOORD.y * 2.0943951);
 float column = mod(floor(FRAGCOORD.x), 3.0);
 vec3 phosphor = vec3(0.88);
 if (column < 1.0) phosphor.r = 1.0;
 else if (column < 2.0) phosphor.g = 1.0;
 else phosphor.b = 1.0;
 float vignette = 1.0 - 0.26 * pow(length(centered) / 1.4142, 2.0);
 float inside = step(0.0, uv.x)*step(uv.x, 1.0)*step(0.0, uv.y)*step(uv.y, 1.0);
 COLOR = vec4(color * scan * phosphor * vignette * 1.22 * inside, 1.0);
}
