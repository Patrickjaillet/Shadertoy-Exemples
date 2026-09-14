
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
