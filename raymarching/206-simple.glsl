// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Camera zoom on the screen
    float coordScale = 2.0;
    vec2 uv = (fragCoord * coordScale - iResolution.xy) / iResolution.y;
    float time = iTime;
    // https://patrickjaillet.github.io/sandefjord-software
    // Speed of the first scene rotation
    float rotSpeed1 = 0.2;
    float cosRot1 = cos(time * rotSpeed1);
    float sinRot1 = sin(time * rotSpeed1);
    mat2 rot1 = mat2(cosRot1, -sinRot1, sinRot1, cosRot1);
    
    // Speed of the second scene rotation
    float rotSpeed2 = 0.15;
    // Offset to separate the two camera rotations
    float rotOffset2 = 0.3;
    float cosRot2 = cos(time * rotSpeed2 + rotOffset2);
    float sinRot2 = sin(time * rotSpeed2 + rotOffset2);
    mat2 rot2 = mat2(cosRot2, -sinRot2, sinRot2, cosRot2);
    
    // Fix by Elsio : https://www.shadertoy.com/user/Elsio
    // ---------------------------------------------------
    // Modification: integration of dynamic rotation based on iTime (Appolonian Fold)
    vec2 rotInnerVec = cos(3.14/2. + iTime*.1 + vec2(0,33));
    mat2 rotInner = mat2(rotInnerVec.x, -rotInnerVec.y, rotInnerVec.y, rotInnerVec.x);
    // Base brightness of the dark background
    float initialFragColor = 0.1;
    fragColor = vec4(initialFragColor);
    // Starting distance of the rendering ray
    float totalDistance = 0.0;
    
    // Number of calculations per pixel (image quality)
    float maxRaySteps = 32.0;
    for (float i = 0.0; i < maxRaySteps; i++) {
        vec3 rayPosition = vec3(uv * totalDistance, totalDistance);
        
        rayPosition.xz *= rot1;
        rayPosition.yz *= rot2;
        
        // Forward speed of the camera in a straight line
        float cameraSpeed = 0.6;
        rayPosition.z += time * cameraSpeed;
        
        // Geometric offset to prevent everything from being perfectly centered
        float spaceOffset = 1.0;
        rayPosition += spaceOffset;
        
        // Maximum distance threshold of the shape
        float baseOrbitDistance = 9.0;
        float minOrbitDistance = baseOrbitDistance;
        // Starting size of the fractal
        float baseFractalScale = 9.0;
        float fractalScale = baseFractalScale;
        // Current step distance
        float stepDistance = 0.0;
        
        // Number of pattern repetitions inside the fractal
        int maxFractalIterations = 7;
        for (int j = 0; j < maxFractalIterations; j++) {
            // Spacing between each shape repetition
            float modPeriod = 2.0;
            // Offset to center the repetition
            float modOffset = 1.0;
            rayPosition = mod(rayPosition - modOffset, modPeriod) - modOffset;
            rayPosition.yz *= rotInner;
            
            minOrbitDistance = min(minOrbitDistance, length(rayPosition));
            
            // Power of the spherical distortion
            float inversionFactor = 0.6;
            stepDistance = dot(rayPosition, rayPosition) * inversionFactor;
            
            fractalScale /= stepDistance;
            rayPosition /= stepDistance;
        }
        
        // Global scale inversion
        float scaleInversion = 1.0;
        stepDistance = scaleInversion / fractalScale;
        totalDistance += stepDistance;
        
        // How much distance affects the color shifts
        float hueScaleDistance = 0.08;
        // Color shifting speed over time
        float hueScaleTime = 0.04;
        float colorHue = fract(minOrbitDistance + totalDistance * hueScaleDistance + time * hueScaleTime);
        
        // Red phase position in the color palette
        float redPhase = 1.0;
        // Green phase position in the color palette
        float greenPhase = 2.0 / 3.0;
        // Blue phase position in the color palette
        float bluePhase = 1.0 / 3.0;
        vec3 phaseOffsets = vec3(redPhase, greenPhase, bluePhase);
        
        // Frequency of the color bands (rainbow effect)
        float waveFrequency = 20.0;
        // Color saturation and boost control
        float waveOffset = 3.0;
        vec3 p = abs(fract(colorHue + phaseOffsets) * waveFrequency - waveOffset);
        
        // Lower limit to prevent total pitch blackness
        float clampMin = 0.2;
        // Upper limit to prevent severe color burning
        float clampMax = 1.0;
        // Balance between white highlights and pure color
        float mixFactor = 0.7;
        // Overall light power multiplier (glow/HDR intensity)
        float colorIntensity = 2.6;
        vec3 rgbColor = colorIntensity * mix(vec3(1.0), clamp(p - 1.0, clampMin, clampMax), mixFactor);
        
        // Strength of the glow halo effect
        float glowIntensity = 0.014;
        // Glow fade rate on the edges of the shapes
        float falloffStep = 1200.0;
        // Thickness of the background fog
        float falloffDistance = 0.15;
        fragColor.rgb += glowIntensity / exp(stepDistance * falloffStep + totalDistance * falloffDistance) * rgbColor;
    }
    
    vec3 x = fragColor.rgb;
    
    // White balance contrast (ACES cinematic filter)
    float aces_a = 2.51;
    // Shadow adjustment (ACES cinematic filter)
    float aces_b = 0.03;
    // Midtone brightness (ACES cinematic filter)
    float aces_c = 1.68;
    // Overall contrast adjustment (ACES cinematic filter)
    float aces_d = 0.59;
    // Highlight saturation correction (ACES cinematic filter)
    float aces_e = 0.14;
    // Minimum screen safety boundary
    float clampFloor = 0.0;
    // Maximum screen safety boundary
    float clampCeil = 1.0;
    
    fragColor.rgb = clamp((x * (aces_a * x + aces_b)) / (x * (aces_c * x + aces_d) + aces_e), clampFloor, clampCeil);
    
    // Final output transparency (fully opaque)
    float alphaChannel = 1.0;
    fragColor.a = alphaChannel;
}
