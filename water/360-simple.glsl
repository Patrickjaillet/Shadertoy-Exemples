// ==== Image (image) ====
// ==========================================================
// NAME : ORGANIC PLASMA TUNNEL
// ==========================================================
// DESCRIPTION : A fluid, 2D tunnel simulation using polar 
// coordinates and trigonometric interference patterns to 
// create deep, organic gradients.
// ==========================================================
// Credits : Patrick JAILLET
// https://shaderstudio.xo.je
// https://renderforge.ct.ws

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // 1. COORDINATE NORMALIZATION
    // We transform the pixel coordinates so that (0,0) is in the center.
    // Dividing by iResolution.y ensures a 1:1 aspect ratio, preventing stretching.
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    
    // 2. POLAR COORDINATE CONVERSION
    // Instead of using X and Y, we use:
    // dist: The distance from the center (creates the depth of the tunnel).
    // angle: The rotation around the center (creates the walls).
    float t = iTime * 0.5;
    float dist = length(uv);
    float angle = atan(uv.y, uv.x);
    
    // 3. INTERFERENCE PATTERN GENERATION
    // We create a "Plasma" look by overlapping two sine waves:
    // Wave 1: Moves inward based on distance (the tunnel flow).
    // Wave 2: Rotates based on the angle (the wall ripples).
    float pattern = sin(10.0 * dist - t) * 0.5 + 0.5;
    pattern += sin(8.0 * angle + t) * 0.3;
    
    // 4. NATURAL COLOR PALETTE
    // To achieve an organic, earthy feel, we use deep Sapphires, Ambers, and Emeralds.
    // These avoid the "electronic" look in favor of something more biological or fluid.
    vec3 color1 = vec3(0.1, 0.3, 0.4); // Deep Sapphire Blue
    vec3 color2 = vec3(0.8, 0.6, 0.4); // Soft Amber
    vec3 color3 = vec3(0.2, 0.5, 0.3); // Forest Emerald Green
    
    // 5. COLOR MIXING
    // We blend the colors based on our interference pattern and the distance.
    // This creates the shifting "plasma" effect where colors seem to flow into each other.
    vec3 finalColor = mix(color1, color2, pattern);
    finalColor = mix(finalColor, color3, sin(dist * 3.0 - t) * 0.5 + 0.5);
    
    // 6. DEPTH & VIGNETTING
    // We use smoothstep to darken the edges of the screen and the center.
    // This creates a "vignette" that simulates depth and draws the eye into the tunnel.
    finalColor *= smoothstep(1.5, 0.2, dist);
    
    // 7. FINAL OUTPUT
    // The vec4 represents (Red, Green, Blue, Alpha).
    fragColor = vec4(finalColor, 1.0);
}
