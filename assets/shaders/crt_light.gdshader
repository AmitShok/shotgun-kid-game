shader_type canvas_item;
render_mode unshaded;
// The light CRT: the same beam model as crt.gdshader, gentler. Dithers still soften, but
// scanlines are faint and there is no glow or curvature to speak of.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 game_size = vec2(640.0, 360.0);
uniform float beam_blur : hint_range(0.2, 0.9) = 0.42;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.22;

vec3 game_pixel(vec2 cell) {
 cell = clamp(cell, vec2(0.0), game_size - 1.0);
 return texture(screen_texture, (cell + 0.5) / game_size).rgb;
}
vec3 beam_row(float row, float x) {
 float fx = x - 0.5;
 float i = floor(fx);
 float f = fx - i;
 vec3 sum = vec3(0.0);
 float total = 0.0;
 for (int k = -1; k <= 2; k++) {
  float d = float(k) - f;
  float w = exp(-(d * d) / (2.0 * beam_blur * beam_blur));
  sum += game_pixel(vec2(i + float(k), row)) * w;
  total += w;
 }
 return sum / total;
}
void fragment() {
 vec2 centered = SCREEN_UV * 2.0 - 1.0;
 vec2 uv = SCREEN_UV + centered * dot(centered, centered) * 0.003;
 vec2 src = uv * game_size;
 float y_in = fract(src.y) - 0.5;
 vec3 line = beam_row(floor(src.y), src.x);
 float lum = dot(line, vec3(0.299, 0.587, 0.114));
 float width = mix(0.30, 0.50, clamp(lum * 1.3, 0.0, 1.0));
 float profile = exp(-(y_in * y_in) / (2.0 * width * width));
 vec3 color = line * mix(1.0, profile * 1.2, scanline_strength);
 float vignette = 1.0 - 0.12 * pow(length(centered) / 1.4142, 2.0);
 float inside = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
 COLOR = vec4(color * vignette * 1.06 * inside, 1.0);
}
