shader_type canvas_item;

uniform bool active = false;

uniform vec4 outline_color : source_color = vec4(0.80, 0.0, 0.10, 1.0); // Farbe der Umrandung
uniform float outline_width = 4.0; // Breite der Umrandung
uniform float pulse_speed = 3.0; // Geschwindigkeit des Pulsierens

void fragment() {
	if (active) {
		vec2 uv = UV;
		// Die aktuelle Textur des Sprites laden
		vec4 texture_color = texture(TEXTURE, uv);
		
		// Berechnung der Distanz zum Rand
		vec2 texel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
		float dist_to_edge = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
		
		// Pulsierender Effekt
		float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
		
		// Wenn innerhalb der Umrandungsbreite, dann zeichne die Umrandung
		if (dist_to_edge < outline_width * texel_size.x) {
			COLOR = outline_color * pulse;
		} else {
			// Zeichne das Sprite selbst
			COLOR = texture_color;
		}
	}
}
