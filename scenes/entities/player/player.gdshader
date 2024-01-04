shader_type canvas_item;

// uniform attribute to control blink status
uniform bool doBlink = false;

// 3-dimensional color values for white
const vec3 whiteColor = vec3(1.0, 1.0, 1.0);


void fragment() {
	
	vec4 originalColor = texture(TEXTURE, UV);
	
	vec4 targetColor;
	
	// get alpha value of pixel
	float current_alpha = originalColor.a;
	
	if (doBlink == true) {
		targetColor = vec4(whiteColor, current_alpha);
	} else {
		targetColor = originalColor;
	}
	
	COLOR = targetColor;
	
}
