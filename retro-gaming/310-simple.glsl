// ==== Image (image) ====
void mainImage(out vec4 O, vec2 U) {
    vec2 u = (U - 0.6 * iResolution.xy) / iResolution.y;
    u.y = -u.y;// https://github.com/Patrickjaillet
    float t = iTime, a = t * 0.15, e = 1.0, R = 0.0, s, j, i;
    vec3 ro = vec3(sin(a) * 4.3, 0.0, cos(a) * 3.4),
         f = normalize(-ro),
         r = normalize(cross(f, vec3(0.6, 1, 0))),
         d = mat3(r, cross(r, f), f) * normalize(vec3(u, 1.35)),
         q = ro,
         H = vec3(0.1),
         p, h;
    for (i = 0.; i < 90.; i++) {
        float l = min(e * s, 0.6 - e) * 0.075;
        s = 8.0;
        q += d * e * R * 0.25;
        R = length(q);
        p = vec3(log(R + 1e-4) * 1.6 - t * 0.35, acos(clamp(q.y / R, -1.0, 1.0)) * 2.0 - 1.0, atan(q.x, q.z));
        e = p.y - 1.0 + 0.64 * sin(p.z * 3.0 + t * 0.5);
        for (j = 0.; j < 7.; j++) {
            if (s > 1e3) break;
            e += mix(-abs(dot(cos(p.zxy * s), 1.0 - sin(p * s))) / s * 0.15, -abs(dot(sin(p.yzx * s), 0.5 - cos(p * s))) / s, 0.5);
            s *= 2.0;
        }
        h = 0.5 + 0.5 * cos(6.28318 * (vec3(0.52, 0.32, 0.68) + p.z * 0.15 + p.x * 0.05));
        H += l * h;
    }
    vec3 c = clamp((H * (1.95 * H + 0.03)) / (H * (2.11 * H + 0.43) + 0.19), 0.0, 1.0);
    O = vec4(vec3(dot(c, vec3(0.2126, 0.7152, 0.0722))) * (1.0 - 0.35 * dot(u, u)), 1.0);
}

/* ORIGINAL

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 normalizedCoordinates = (fragCoord - 0.6 * iResolution.xy) / iResolution.y;
    normalizedCoordinates.y = -normalizedCoordinates.y;
    
    float time = iTime;
    float cameraAngle = time * 0.15;
    
    vec3 rayOrigin = vec3(sin(cameraAngle) * 4.3, 0.0, cos(cameraAngle) * 3.4);
    vec3 viewDirection = normalize(-rayOrigin);
    vec3 referenceUp = vec3(0.6, 1.0, 0.0);
    
    vec3 cameraRight = normalize(cross(viewDirection, referenceUp));
    vec3 cameraUp = cross(cameraRight, viewDirection);
    
    vec3 rayDirectionLocal = normalize(vec3(normalizedCoordinates, 1.35));
    mat3 cameraMatrix = mat3(cameraRight, cameraUp, viewDirection);
    vec3 rayDirection = cameraMatrix * rayDirectionLocal;
    
    vec3 samplePosition = rayOrigin;
    vec3 accumulatedColor = vec3(0.1);
    
    float distanceFieldScale = 1.0;
    float currentRadius = 0.0;
    float fractalScale;
    
    for (float iteration = 0.0; iteration < 90.0; iteration++) {
        float stepIntensity = min(distanceFieldScale * fractalScale, 0.6 - distanceFieldScale) * 0.075;
        fractalScale = 8.0;
        
        samplePosition += rayDirection * distanceFieldScale * currentRadius * 0.25;
        currentRadius = length(samplePosition);
        
        vec3 sphericalCoords = vec3(
            log(currentRadius + 1e-4) * 1.6 - time * 0.35,
            acos(clamp(samplePosition.y / currentRadius, -1.0, 1.0)) * 2.0 - 1.0,
            atan(samplePosition.x, samplePosition.z)
        );
        
        distanceFieldScale = sphericalCoords.y - 1.0 + 0.64 * sin(sphericalCoords.z * 3.0 + time * 0.5);
        
        for (float octave = 0.0; octave < 7.0; octave++) {
            if (fractalScale > 1000.0) {
                break;
            }
            
            float noiseLayerA = -abs(dot(cos(sphericalCoords.zxy * fractalScale), 1.0 - sin(sphericalCoords * fractalScale))) / fractalScale * 0.15;
            float noiseLayerB = -abs(dot(sin(sphericalCoords.yzx * fractalScale), 0.5 - cos(sphericalCoords * fractalScale))) / fractalScale;
            
            distanceFieldScale += mix(noiseLayerA, noiseLayerB, 0.5);
            fractalScale *= 2.0;
        }
        
        vec3 paletteOffset = vec3(0.52, 0.32, 0.68);
        vec3 colorPalette = 0.5 + 0.5 * cos(6.28318530718 * (paletteOffset + sphericalCoords.z * 0.15 + sphericalCoords.x * 0.05));
        
        accumulatedColor += stepIntensity * colorPalette;
    }
    
    vec3 numerator = accumulatedColor * (1.95 * accumulatedColor + 0.03);
    vec3 denominator = accumulatedColor * (2.11 * accumulatedColor + 0.43) + 0.19;
    vec3 tonemappedColor = clamp(numerator / denominator, 0.0, 1.0);
    
    float luminance = dot(tonemappedColor, vec3(0.2126, 0.7152, 0.0722));
    float vignette = 1.0 - 0.35 * dot(normalizedCoordinates, normalizedCoordinates);
    
    fragColor = vec4(vec3(luminance) * vignette, 1.0);
}

*/
