// ==== Image (image) ====
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 rayOrigin = vec3(0.0, 0.0, -3.0);
    vec3 rayDirection = normalize(vec3(uv, 1.0));
    
    float totalDistance = 0.0;
    
    vec3 q = vec3(0.0), p = vec3(0.0);
    q.yz += 0.6;
    
    for(int i = 0; i < 64; i++) {
        p = q += (vec3(fragCoord, 0.0) / iResolution.y - 0.5) * rayDirection;
        vec3 rotatedPosition = p;
        
        float accumulatedScale = 1.0;
        float currentScaleFactor = 1.0;
        float u = 1.0;
        float v = 1.0;
        
        for (int fractalIteration = 0; fractalIteration < 9; fractalIteration++) {
            u += length(rotatedPosition);
            v += float(fractalIteration + 1);
            float angle = float(fractalIteration) + sin(1.0 / u + iTime) / v;
            
            float c = cos(angle);
            float s = sin(angle);
            mat2 rot = mat2(c, -s, s, c);
            rotatedPosition.xy *= rot;
            
            float squaredDistanceToOrigin = dot(rotatedPosition, rotatedPosition);
            currentScaleFactor = max(0.95, 9.0 / squaredDistanceToOrigin);
            accumulatedScale *= currentScaleFactor;
            vec3 scaledPosition = abs(rotatedPosition) * currentScaleFactor;
            vec3 foldedPosition = abs(scaledPosition - vec3(1.0, 1.2, 3.0));
            rotatedPosition = vec3(1.5, 4.0, 3.0) - foldedPosition;
        }
        
        float distanceEstimate = (length(rotatedPosition) - 1.0) / abs(accumulatedScale);
        if(distanceEstimate < 0.001 || totalDistance > 20.0) {
            break;
        }
        totalDistance += distanceEstimate;
    }
    
    vec3 color = vec3(1.0 - totalDistance / 20.0);
    fragColor = vec4(color, 1.0);
}
