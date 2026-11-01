shader_type canvas_item;
render_mode unshaded;
// Circular wipe: transparent inside the radius, solid tint outside. Radius is in screen heights.
uniform vec2 center = vec2(0.5);
uniform float radius = 2.0;
uniform float aspect = 1.7778;
uniform vec4 tint : source_color = vec4(0.07, 0.1, 0.17, 1.0);
void fragment() {
 vec2 d = (UV - center) * vec2(aspect, 1.0);
 COLOR = vec4(tint.rgb, tint.a * step(radius, length(d)));
}
