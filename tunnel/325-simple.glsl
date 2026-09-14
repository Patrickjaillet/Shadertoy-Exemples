// ==== Image (image) ====
// https://github.com/Patrickjaillet
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 resolution = iResolution;
    
    vec3 cameraTarget = vec3(0.0, 29.3, -26.0);
    vec3 viewDirection = normalize(cameraTarget);
    vec3 upVector = vec3(0.0, 1.0, 0.0);
    
    vec3 cameraRight = normalize(cross(viewDirection, upVector));
    vec3 cameraUp = cross(cameraRight, viewDirection);
    
    vec2 uv = (fragCoord - 0.5 * resolution.xy) / resolution.y;
    vec3 rayDirectionLocal = normalize(vec3(uv, 1.0));
    
    mat3 cameraMatrix = mat3(cameraRight, cameraUp, viewDirection);
    vec3 rayDirection = cameraMatrix * rayDirectionLocal;
    
    vec3 rayOrigin = vec3(0.0, -17.0, 1.0);
    vec3 colorAccumulator = vec3(0.0);
    
    float distanceFieldScale = 1.0;
    float currentRadius = 0.0;
    float fractalScale;
    
    for (int i = 0; i < 80; i++) {
        colorAccumulator += min(distanceFieldScale * fractalScale, 0.6 - distanceFieldScale) * 0.075;
        rayOrigin += rayDirection * distanceFieldScale * currentRadius * 0.3;
        
        currentRadius = length(rayOrigin);
        
        vec3 logSphericalCoords = vec3(
            log(currentRadius) - iTime * 0.5,
            exp(-rayOrigin.y / currentRadius + 0.5),
            atan(rayOrigin.x, rayOrigin.z)
        );
        
        distanceFieldScale = logSphericalCoords.y - 1.0;
        
        for (fractalScale = 8.0; fractalScale < 1000.0; fractalScale *= 2.0) {
            vec3 sinComponent = sin(logSphericalCoords.yzx * fractalScale);
            vec3 cosComponent = 0.5 - cos(logSphericalCoords * fractalScale);
            distanceFieldScale -= abs(dot(sinComponent, cosComponent)) / fractalScale * 0.5;
        }
    }
    
    vec3 numerator = colorAccumulator * (1.95 * colorAccumulator + 0.03);
    vec3 denominator = colorAccumulator * (2.11 * colorAccumulator + 0.43) + 0.19;
    vec3 toneMappedColor = numerator / denominator;
    
    fragColor = vec4(toneMappedColor, 1.0);
}

/* GOLFED

void mainImage(out vec4 O, vec2 U) {
    vec3 R = iResolution,
         w = normalize(vec3(0, 29.3, -26)),
         u = normalize(cross(w, vec3(0, 1, 0))),
         d = mat3(u, cross(u, w), w) * normalize(vec3((U - .5 * R.xy) / R.y, 1)),
         q = vec3(0, -17, 1),
         c = vec3(0), p;
    float e = 1., r = 0., s, j;
    for (int i = 0; i < 80; i++) {
        c += min(e * s, .6 - e) * .075;
        q += d * e * r * .3;
        r = length(q);
        p = vec3(log(r) - iTime * .5, exp(-q.y / r + .5), atan(q.x, q.z));
        e = p.y - 1.;
        for (s = 8.; s < 1e3; s *= 2.)
            e -= abs(dot(sin(p.yzx * s), .5 - cos(p * s))) / s * .5;
    }
    O = vec4((c * (1.95 * c + .03)) / (c * (2.11 * c + .43) + .19), 1);
}

*/
