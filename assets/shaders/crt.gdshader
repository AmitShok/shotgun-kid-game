shader_type canvas_item;
render_mode unshaded;
// A CRT modelled the way 16-bit era art was drawn for: the beam blurs each line horizontally
// across neighbouring game pixels (so dither patterns and alternating columns melt into
// in-between colours), each row of game pixels is one scanline whose beam swells when bright,
// and bright pixels bleed a little glow. Works on the game's own 640x360 pixel grid at any
// window size. Everything is stationary: no rolling bars, flicker or noise.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 game_size = vec2(640.0, 360.0);
uniform float curvature : hint_range(0.0, 0.02) = 0.008;
// Horizontal beam width in game pixels: ~0.5 melts 1px dithers, lower is sharper.
uniform float beam_blur : hint_range(0.2, 0.9) = 0.52;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.55;
uniform float mask_strength : hint_range(0.0, 0.3) = 0.10;
uniform float glow : hint_range(0.0, 0.6) = 0.22;
uniform float color_fringe : hint_range(0.0, 1.0) = 0.25;
uniform float brightness : hint_range(0.8, 1.6) = 1.18;

vec3 game_pixel(vec2 cell) {
 cell = clamp(cell, vec2(0.0), game_size - 1.0);
 return texture(screen_texture, (cell + 0.5) / game_size).rgb;
}
// One scanline (row) reconstructed horizontally with a gaussian beam.
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
 vec2 uv = SCREEN_UV + centered * dot(centered, centered) * curvature;
 vec2 src = uv * game_size;
 float row = floor(src.y);
 float y_in = fract(src.y) - 0.5;
 // Slight horizontal colour misconvergence, like a real tube's three guns.
 float fringe = color_fringe * 0.35;
 vec3 line = vec3(beam_row(row, src.x + fringe).r, beam_row(row, src.x).g, beam_row(row, src.x - fringe).b);
 // The beam is taller where the line is bright: highlights bloom, darks stay crisp and dark.
 float lum = dot(line, vec3(0.299, 0.587, 0.114));
 float width = mix(0.24, 0.46, clamp(lum * 1.3, 0.0, 1.0));
 float profile = exp(-(y_in * y_in) / (2.0 * width * width));
 vec3 color = line * mix(1.0, profile * 1.35, scanline_strength);
 // Glow: bright neighbours (in game pixels) spill a little light around themselves.
 vec3 near = (beam_row(row - 1.0, src.x) + beam_row(row + 1.0, src.x)
            + game_pixel(vec2(floor(src.x) - 2.0, row)) + game_pixel(vec2(floor(src.x) + 2.0, row))) * 0.25;
 color += max(near - vec3(0.45), vec3(0.0)) * glow;
 // Aperture-grille phosphor stripes at screen resolution.
 float column = mod(floor(FRAGCOORD.x), 3.0);
 vec3 mask = vec3(1.0 - mask_strength);
 if (column < 1.0) mask.r = 1.0;
 else if (column < 2.0) mask.g = 1.0;
 else mask.b = 1.0;
 float vignette = 1.0 - 0.24 * pow(length(centered) / 1.4142, 2.0);
 float inside = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
 COLOR = vec4(color * mask * vignette * brightness * inside, 1.0);
}
