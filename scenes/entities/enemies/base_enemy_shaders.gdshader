shader_type canvas_item;

// uniform attribute to control blink status
uniform bool doBlink = false;
const vec3 whiteColor = vec3(1.0, 1.0, 1.0);

// uniform attribute to control frozen status
uniform bool doFrozenSlowedDown = false;
const vec3 iceBlueColor = vec3(0.498039, 1, 0.831373);

void fragment() {
	vec4 originalColor = texture(TEXTURE, UV);
	
	vec4 targetColor;
	
	// get alpha value of pixel
	float currentAlpha = originalColor.a;
	
	if (doBlink) {
		// reduce alpha value for visible pixels slightly
		if (currentAlpha >= 0.5) {
			currentAlpha -= 0.3;
		}
		targetColor = mix(originalColor, vec4(whiteColor, currentAlpha), 0.6);
		
	} else if (doFrozenSlowedDown) {
		targetColor = mix(originalColor, vec4(iceBlueColor, currentAlpha), 0.4);
	} else {
		targetColor = originalColor;
	}
	
	COLOR = targetColor;
}
