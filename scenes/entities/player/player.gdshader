shader_type canvas_item;

/*
Shader script for player sprites.
Currently added blink animation after hits
and color changing as well as sprite-stretching
for whip-attack-charge animations.
(January 2024)
*/

// uniform attribute to control blink status
uniform bool doBlink = false;

// uniform attribute to control stretch/shrink status
uniform bool doStretch = false;
uniform bool widenX = false;
uniform float stretchProgress = 0.0;

// 3-dimensional color values for white (blink) and purple (charge attack)
const vec3 whiteColor = vec3(1.0, 1.0, 1.0);
const vec3 purpleColor = vec3(0.3, 0.0, 0.4);


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
		targetColor = vec4(whiteColor, currentAlpha);
	} else if (doStretch) {
		float purpleColorOverlay = 0.0;
		if (stretchProgress > 0.4) {
			purpleColorOverlay = 0.4;
		} else {
			purpleColorOverlay = stretchProgress;
		}
		targetColor = mix(originalColor, vec4(purpleColor, currentAlpha), purpleColorOverlay);
	} else {
		targetColor = originalColor;
	}
	
	COLOR = targetColor;
}


void vertex() {
	
	if (doStretch) {
		float scaleFactor = widenX ? mix(1.0, 1.15, stretchProgress) : mix(1.0, 0.9, stretchProgress);
		VERTEX.x *= scaleFactor;
	}
}

