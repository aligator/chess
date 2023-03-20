shader_type canvas_item;
uniform vec4 override_color : source_color = vec4(1.0);
uniform vec4 flash_color : source_color = vec4(1.0);
uniform float flash_speed : hint_range(0.0, 10.0) = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(mix(color.rgb, override_color.rgb, 1.0), flash_color.rgb, cos(TIME * flash_speed));
	COLOR = color;
}
